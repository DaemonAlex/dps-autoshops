-- Price maths and the on-duty message.
vec3 = function(x, y, z) return { x = x, y = y, z = z } end
dofile('config.lua')
dofile('shared/price.lua')

local full = Config.FullRepair
local m = Config.SimpleMultiplier

-- Damon 2026-10-11: 1.5x the full JG repair ($500 + 1% of value)
Check('multiplier is 1.5', m == 1.5)
Check('$20,000 car: (500 + 200) x 1.5 = 1050', AutoShops.SimpleRepairPrice(20000, full, m) == 1050)
Check('$0 car: 500 x 1.5 = 750', AutoShops.SimpleRepairPrice(0, full, m) == 750)
Check('missing value counts as 0', AutoShops.SimpleRepairPrice(nil, full, m) == 750)
Check('negative value counts as 0', AutoShops.SimpleRepairPrice(-5, full, m) == 750)
Check('fallback $50,000 car: 1500', AutoShops.SimpleRepairPrice(Config.FallbackVehicleValue, full, m) == 1500)
Check('rounds to whole dollars', AutoShops.SimpleRepairPrice(12345, full, m) == math.floor((500 + 123.45) * 1.5 + 0.5))

Check('message with two shops', AutoShops.OpenShopsText({ "Benny's Original Motor Works", 'Los Santos Customs' })
    == "Please visit or request a tow to: Benny's Original Motor Works, Los Santos Customs")
Check('no message when nobody is open', AutoShops.OpenShopsText({}) == '')

-- Every automatic shop has a label and coordinates; the three player-run shop jobs are listed.
local n = 0
for id, shop in pairs(Config.Shops) do
    n = n + 1
    Check(id .. ' has a label', type(shop.label) == 'string' and shop.label ~= '')
    Check(id .. ' has coords', shop.coords and shop.coords.x and shop.coords.y and shop.coords.z)
end
Check('six automatic shops (Benny\'s + five GTA garages)', n == 6)
Check('three shop jobs (LS Customs, Bay Area, Sandy)', #Config.ShopJobs == 3)
local hasBennysJob = false
for _, j in ipairs(Config.ShopJobs) do if j == 'bennys' then hasBennysJob = true end end
Check('Benny\'s is not a player shop', not hasBennysJob)
