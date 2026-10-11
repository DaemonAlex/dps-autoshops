-- CLIENT: jg-mechanic's zone file calls TakeOver when a player enters an automatic shop.
-- Nobody on duty at a player-run shop: return false and JG opens its normal self-service menu.
-- Someone on duty: show where to go, and offer only a simple repair.

local active -- shop id while the player stands in a taken-over automatic shop

local function leave()
    if not active then return end
    active = nil
    lib.hideTextUI()
end

local function simpleRepair()
    local shopId = active
    if not shopId then return end

    local vehicle = cache.vehicle
    if not vehicle or cache.seat ~= -1 then
        lib.notify({ type = 'error', description = 'Sit in the driver seat of the car to repair it.' })
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local quote = lib.callback.await('dps-autoshops:server:quote', false, shopId, netId)
    if not quote or not quote.ok then
        lib.notify({ type = 'error', description = quote and quote.error or 'Repair not available.' })
        return
    end

    local answer = lib.alertDialog({
        header = 'Simple repair',
        content = ('Enough to drive to a shop, not a full repair.  \nPrice: **$%d**'):format(quote.price),
        centered = true,
        cancel = true,
        labels = { confirm = 'Pay', cancel = 'No' },
    })
    if answer ~= 'confirm' then return end

    if not lib.progressBar({
        duration = Config.SimpleRepair.seconds * 1000,
        label = 'Patching it up...',
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    }) then return end

    local paid = lib.callback.await('dps-autoshops:server:pay', false, shopId, netId)
    if not paid or not paid.ok then
        lib.notify({ type = 'error', description = paid and paid.error or 'Payment failed.' })
        return
    end
    if not DoesEntityExist(vehicle) then return end

    SetVehicleEngineHealth(vehicle, math.max(GetVehicleEngineHealth(vehicle), Config.SimpleRepair.engine))
    SetVehicleBodyHealth(vehicle, math.max(GetVehicleBodyHealth(vehicle), Config.SimpleRepair.body))
    SetVehicleUndriveable(vehicle, false)
    lib.notify({ type = 'success', description = ('Patched up for $%d. Get it to a shop for a proper repair.'):format(paid.price) })
end

lib.addKeybind({
    name = 'dps_autoshop_repair',
    description = 'Simple repair at an automatic shop',
    defaultKey = 'E',
    onPressed = function()
        if active then simpleRepair() end
    end,
})

---@param shopId string jg-mechanic location id
---@return boolean handled true when this script took over the zone
exports('TakeOver', function(shopId)
    if not Config.Shops[shopId] then return false end
    local status = lib.callback.await('dps-autoshops:server:status', false, shopId)
    if not status or not status.open or #status.open == 0 then return false end

    active = shopId
    lib.notify({
        title = Config.Shops[shopId].label .. ' auto repair',
        description = AutoShops.OpenShopsText(status.open),
        type = 'inform',
        duration = 10000,
    })
    lib.showTextUI('[E] Simple repair (enough to reach a shop)')
    return true
end)

exports('Leave', leave)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then leave() end
end)
