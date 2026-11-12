# dps-autoshops

Automatic repair shops for DelPerroSands. They do a full repair when no mechanic is on duty. When
a mechanic is on duty they do a small patch-up and tell you which shop is open.

## What it is for

A player with a broken car needs a repair at any hour. Player mechanics need customers when they
are on duty. Self-service shops that are always open take that work away from them. This script
makes the automatic shops step back when a real mechanic is working, and still gets a stranded
player moving again.

## What it does

- **No mechanic on duty** at a player-run shop: the five automatic shops (Benny's, La Mesa, LSIA,
  Harmony, Beeker's Garage) run the normal JG Mechanic self-service menu.
- **A mechanic on duty** at Los Santos Customs, Bay Area Customs or the Sandy Shores shop: the
  automatic shop shows *"Please visit or request a tow to:"* with the open shops, and offers only
  a simple repair (engine and body back to 600, enough to drive). It costs 1.5 times the full
  self-service repair (Damon, 2026-10-11).
- **Simple repair.** Sit in the driver seat and press E. You see the price, confirm, wait 8
  seconds, and the car can drive again. It never lowers the health of a car that is already
  above 600.

## How it fits

- The five shops are `type = "self-service"` entries in `jg-mechanic/config/config.lua` (`bennys`
  and the four `auto_*` shops).
- `jg-mechanic/client/cl-locations.lua` (a file JG leaves open for edits) calls
  `exports["dps-autoshops"]:TakeOver(name)` on zone enter and `Leave()` on exit. When `TakeOver`
  returns false, JG carries on as normal.
- The server counts on-duty players with `qbx_core:GetDutyCountJob` and prices the car the same
  way JG does (dealership price, then the Qbox vehicle list, then 50,000).
- The server checks the player and the car are at the shop before charging. Bank first, then cash.
- The server export `exports['dps-autoshops']:OpenShops()` returns the labels of the player-run
  shops that have a mechanic on duty. Other scripts can use it.

## On its own, and with other scripts

**On its own.** With only the free requirements the script starts, and the `OpenShops` export
works, but no player sees anything. The shop zones come from jg-mechanic. Without it nothing
calls `TakeOver`.

**With a paid mechanic script (jg-mechanic).** This is how it is meant to run. JG owns the shop
zones and the full self-service repair. When a player drives into an automatic shop, JG asks this
script first. If a mechanic is on duty, the player gets the list of open shops and the simple
repair. If nobody is on duty, JG opens its own menu as normal. The only change inside JG is two
lines in `cl-locations.lua`, a file JG leaves open for edits. A JG update can replace that file,
so check those two lines after you update JG.

**With a paid dealership script (jg-dealerships).** The price of a repair depends on the value of
the car. The script reads that value from the `dealership_vehicles` table, the same place JG
looks. It only reads the table. If the table is missing a car, the Qbox vehicle list is used,
then a flat 50,000.

**With a tow script ([dps-towjob](https://github.com/DaemonAlex/dps-towjob),
[dps-services](https://github.com/DaemonAlex/dps-services)).** The message tells the player to
visit an open shop or request a tow to one. This script does not call the tow scripts. The player
makes the request on the phone.

## Requirements

- `ox_lib`
- `oxmysql`
- `qbx_core`
- `jg-mechanic` (paid), with the automatic shops set up as self-service locations
- A `dealership_vehicles` table (from jg-dealerships) for car prices

## Install

1. Put the folder in your resources and add `ensure dps-autoshops` after `ox_lib`, `oxmysql` and
   `qbx_core`.
2. In `jg-mechanic/config/config.lua`, add each automatic shop as a `type = "self-service"`
   location. Use the same key as in this script's `Config.Shops`.
3. In `jg-mechanic/client/cl-locations.lua`, call `exports["dps-autoshops"]:TakeOver(name)` when
   the player enters a location and stop there if it returns true. Call
   `exports["dps-autoshops"]:Leave()` when the player leaves.
4. Set `Config.ShopJobs` to the jobs of your player-run shops.
5. Restart `dps-autoshops` and `jg-mechanic`.

## Config

`config.lua`: shop jobs, shop spots, the full-repair numbers (same as JG), the 1.5 multiplier, the simple-repair health levels.

| Setting | Meaning |
|---|---|
| `Config.ShopJobs` | Jobs of the player-run shops. One person on duty in any of them switches the automatic shops to simple repair. |
| `Config.Shops` | The automatic shops. The key must match the jg-mechanic location. Each has a label and a spot. |
| `Config.FullRepair` | Base price and share of the car's value. Keep these the same as the JG self-service repair. |
| `Config.SimpleMultiplier` | The simple repair costs the full repair price times this. Default 1.5. |
| `Config.SimpleRepair` | Engine and body health after the repair, and how many seconds it takes. |
| `Config.MaxShopDistance` | How far the player can be from the shop spot. |
| `Config.MaxVehicleDistance` | How far the car can be from the player. |
| `Config.FallbackVehicleValue` | The value used for a car with no known price. |

## Tests

```
lua5.4 tests/run.lua
```

## Recent changes

- **12 November 2026.** README: what it is for, how it works alone and with paid scripts, other
  DPS scripts. The shop list now matches `config.lua`: Benny's is an automatic shop, and
  Lombardt Bay is no longer in the list.
- **25 October 2026.** Synced with the live server.
- **11 October 2026.** First version. Full self-service when no mechanic is on duty. A simple
  repair at 1.5 times the price and a list of open shops when one is.

## Author

Made by [DaemonAlex](https://github.com/DaemonAlex) for DelPerroSands.

## Other DPS scripts

All of these are made for DelPerroSands and run together on one Qbox server. Each one works on
its own. The ones marked "pairs with" do more when both are running.

| Script | What it does |
|---|---|
| [dps-inventory](https://github.com/DaemonAlex/dps-inventory) | The inventory: ox_inventory with equipment slots, backpacks, armour plates and a self status panel, in the DelPerroSands colours. |
| [dps-medical](https://github.com/DaemonAlex/dps-medical) | Patient records, illness and diagnostic tests. A companion to wasabi_ambulance. Pairs with dps-inventory: symptoms and diagnoses show on the status panel. |
| [dps-insurance](https://github.com/DaemonAlex/dps-insurance) | Ties m-Insurance into the MDT, impound, hospital and medical chart. Pairs with dps-medical. |
| [dps-studio](https://github.com/DaemonAlex/dps-studio) | Build rooms, doors and portals in game from one panel (`/studio`), with owners and managers so staff do not have to support them. |
| [dps-shops](https://github.com/DaemonAlex/dps-shops) | Shop clerks who greet and react to a robbery, then player-owned shops. |
| [dps-fleet](https://github.com/DaemonAlex/dps-fleet) | Vehicle browser and workshop on one panel: extras, liveries and mods for emergency vehicles. |
| [dps-parking](https://github.com/DaemonAlex/dps-parking) | Parking with valet, impound, violations and reserved spots. |
| [dps-vehiclepersistence](https://github.com/DaemonAlex/dps-vehiclepersistence) | Vehicles stay where they were parked. Pairs with dps-parking. |
| [dps-towjob](https://github.com/DaemonAlex/dps-towjob) | Queue-based tow job with jg-mechanic integration. |
| [dps-services](https://github.com/DaemonAlex/dps-services) | Request a tow and follow it live on the lb-phone and lb-tablet. Pairs with dps-towjob. |
| [dps-cityworker](https://github.com/DaemonAlex/dps-cityworker) | City infrastructure job and career. |
| [dps-ainpcs](https://github.com/DaemonAlex/dps-ainpcs) | NPCs you can talk to, with trust, quests and intel. |
| [dps-badpeds](https://github.com/DaemonAlex/dps-badpeds) | Police interaction with NPCs: stops, arrests, intel and jail records. |
| [dps-gangwars](https://github.com/DaemonAlex/dps-gangwars) | Ambient gang NPCs, territory population and war reinforcements. |
| [dps-rotations](https://github.com/DaemonAlex/dps-rotations) | Moves dealers, harvests and other spots on a fixed schedule. |
| [dps-trains](https://github.com/DaemonAlex/dps-trains) | The train system. Pairs with dps-trains-stock, dps-traintools and dps-transitapp. |
| [dps-transitapp](https://github.com/DaemonAlex/dps-transitapp) | Live train arrival boards on the lb-phone. |
| [dps-faceplant](https://github.com/DaemonAlex/dps-faceplant) | City help, reports and staff tools on the lb-phone and lb-tablet. |
| [dps-chat](https://github.com/DaemonAlex/dps-chat) | A command box for voice-only servers. No chat feed. |
| [dps-filmmode](https://github.com/DaemonAlex/dps-filmmode) | One key hides every HUD layer and gives a smooth free camera for recording. |
