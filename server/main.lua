-- SERVER: who is on duty at the player-run shops, the simple repair price, and payment.

---@return string[] labels of the shops with at least one mechanic on duty
local function openShops()
    local open = {}
    for _, job in ipairs(Config.ShopJobs) do
        local count = exports.qbx_core:GetDutyCountJob(job) or 0
        if count > 0 then
            local data = exports.qbx_core:GetJob(job)
            open[#open + 1] = data and data.label or job
        end
    end
    return open
end
exports('OpenShops', openShops)

---@param model integer
---@return number
local function vehicleValue(model)
    -- Same order as JG Mechanic: dealership price first, then the Qbox vehicle list.
    local price = MySQL.scalar.await('SELECT price FROM dealership_vehicles WHERE hashkey = ?', { model })
    if price then return price end
    local byHash = exports.qbx_core:GetVehiclesByHash()
    local shared = byHash and byHash[model]
    return (shared and shared.price) or Config.FallbackVehicleValue
end

---Checks the player is at an automatic shop with the car next to them.
---@return integer|nil vehicle, string|nil error
local function checkAtShop(src, shopId, netId)
    local shop = Config.Shops[shopId]
    if not shop then return nil, 'Not an automatic shop.' end

    local ped = GetPlayerPed(src)
    local pos = GetEntityCoords(ped)
    if #(pos - shop.coords) > Config.MaxShopDistance then return nil, 'You are not at the shop.' end

    local vehicle = NetworkGetEntityFromNetworkId(tonumber(netId) or 0)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return nil, 'No car found.' end
    if #(GetEntityCoords(vehicle) - pos) > Config.MaxVehicleDistance then return nil, 'The car is too far away.' end

    return vehicle
end

lib.callback.register('dps-autoshops:server:status', function(src, shopId)
    if not Config.Shops[shopId] then return nil end
    return { open = openShops() }
end)

lib.callback.register('dps-autoshops:server:quote', function(src, shopId, netId)
    local vehicle, err = checkAtShop(src, shopId, netId)
    if not vehicle then return { ok = false, error = err } end
    local price = AutoShops.SimpleRepairPrice(vehicleValue(GetEntityModel(vehicle)), Config.FullRepair, Config.SimpleMultiplier)
    return { ok = true, price = price }
end)

lib.callback.register('dps-autoshops:server:pay', function(src, shopId, netId)
    local vehicle, err = checkAtShop(src, shopId, netId)
    if not vehicle then return { ok = false, error = err } end

    local price = AutoShops.SimpleRepairPrice(vehicleValue(GetEntityModel(vehicle)), Config.FullRepair, Config.SimpleMultiplier)
    local reason = 'Simple repair (' .. Config.Shops[shopId].label .. ')'

    local account
    if (exports.qbx_core:GetMoney(src, 'bank') or 0) >= price then
        account = 'bank'
    elseif (exports.qbx_core:GetMoney(src, 'cash') or 0) >= price then
        account = 'cash'
    end
    if not account then return { ok = false, error = ('You need $%d.'):format(price) } end
    if not exports.qbx_core:RemoveMoney(src, account, price, reason) then
        return { ok = false, error = 'Payment failed.' }
    end

    lib.print.info(('simple repair: %s paid $%d (%s) at %s'):format(GetPlayerName(src), price, account, shopId))
    return { ok = true, price = price }
end)
