Config = {}

-- The player-run repair shops. When anyone in one of these jobs is on duty, the
-- automatic shops stop doing full repairs and point people to the open shops.
Config.ShopJobs = { 'bennys', 'lscustoms', 'bayareacustoms', 'sandymechanic' }

-- The automatic shops. Each key is also a self-service location in jg-mechanic's
-- Config.MechanicLocations, so JG runs the full repair when nobody is on duty.
Config.Shops = {
    auto_lamesa   = { label = 'La Mesa',          coords = vec3(731.81, -1088.82, 22.17) },
    auto_lsia     = { label = 'LSIA',             coords = vec3(-1155.54, -2007.18, 13.18) },
    auto_harmony  = { label = 'Harmony',          coords = vec3(1175.04, 2640.22, 37.75) },
    auto_beekers  = { label = "Beeker's Garage",  coords = vec3(110.99, 6626.40, 31.79) },
    auto_lombardt = { label = 'Lombardt Bay',     coords = vec3(-87.69, 8103.82, 5.39) },
}

-- Same numbers as the JG self-service repair (jg-mechanic config, mods.repair).
Config.FullRepair = { price = 500, percentVehVal = 0.01 }

-- Damon 2026-10-11: while a mechanic is on duty the simple repair costs 1.5x the full repair.
Config.SimpleMultiplier = 1.5

-- Enough to drive to a shop, not a real repair.
Config.SimpleRepair = { engine = 600.0, body = 600.0, seconds = 8 }

-- How close the player and the car must be to the shop.
Config.MaxShopDistance = 15.0
Config.MaxVehicleDistance = 8.0

-- Used when a car has no dealership or Qbox price (same fallback as JG).
Config.FallbackVehicleValue = 50000
