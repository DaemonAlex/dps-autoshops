-- Pure price maths, shared so the server and the tests use the same function.
AutoShops = AutoShops or {}

---@param vehicleValue number|nil
---@param full { price: number, percentVehVal: number }
---@param multiplier number
---@return integer
function AutoShops.SimpleRepairPrice(vehicleValue, full, multiplier)
    local value = tonumber(vehicleValue) or 0
    if value < 0 then value = 0 end
    local fullPrice = full.price + value * full.percentVehVal
    return math.floor(fullPrice * multiplier + 0.5)
end

---@param names string[]
---@return string
function AutoShops.OpenShopsText(names)
    if #names == 0 then return '' end
    return 'Please visit or request a tow to: ' .. table.concat(names, ', ')
end
