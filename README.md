<p align="center"><img src=".github/dps-logo.svg" alt="DelPerroSands" width="360"></p>

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
| [dps-insurance](https://github.com/DaemonAlex/dps-insurance) | Ties m-Insurance into the MDT, impound, hospital and medical chart, and raises premiums for incidents other scripts report. Pairs with dps-medical and dps-fuel. |
| [dps-studio](https://github.com/DaemonAlex/dps-studio) | Build rooms, doors and portals in game from one panel (`/studio`), with owners and managers so staff do not have to support them. |
| [dps-shops](https://github.com/DaemonAlex/dps-shops) | Shop clerks who greet, react to robberies, talk back through dps-ainpcs and remember trouble, plus player-owned stores with delivery runs. Pairs with dps-ainpcs. |
| [dps-fleet](https://github.com/DaemonAlex/dps-fleet) | Vehicle browser and workshop on one panel: extras, liveries and mods for emergency vehicles. |
| [dps-parking](https://github.com/DaemonAlex/dps-parking) | Parking with valet, impound, violations and reserved spots. |
| [dps-vehiclepersistence](https://github.com/DaemonAlex/dps-vehiclepersistence) | Vehicles stay where they were parked. Pairs with dps-parking. |
| [dps-towjob](https://github.com/DaemonAlex/dps-towjob) | Queue-based tow job with jg-mechanic integration. |
| [dps-services](https://github.com/DaemonAlex/dps-services) | Request a tow and follow it live on the lb-phone and lb-tablet. Pairs with dps-towjob. |
| [dps-cityworker](https://github.com/DaemonAlex/dps-cityworker) | City infrastructure job and career. |
| [dps-ainpcs](https://github.com/DaemonAlex/dps-ainpcs) | NPCs you can talk to, with trust, quests and intel. Other scripts can make their own NPCs talk (dps-shops clerks). |
| [dps-badpeds](https://github.com/DaemonAlex/dps-badpeds) | Police interaction with NPCs: stops, arrests, intel and jail records. |
| [dps-gangwars](https://github.com/DaemonAlex/dps-gangwars) | Ambient gang NPCs, territory population and war reinforcements. |
| [dps-rotations](https://github.com/DaemonAlex/dps-rotations) | Moves dealers, harvests and other spots on a fixed schedule. |
| [dps-trains](https://github.com/DaemonAlex/dps-trains) | The train system. Pairs with dps-trains-stock, dps-traintools and dps-transitapp. |
| [dps-transitapp](https://github.com/DaemonAlex/dps-transitapp) | Live train arrival boards on the lb-phone. |
| [dps-faceplant](https://github.com/DaemonAlex/dps-faceplant) | City help, reports and staff tools on the lb-phone and lb-tablet. |
| [dps-chat](https://github.com/DaemonAlex/dps-chat) | A command box for voice-only servers. No chat feed. |
| [dps-filmmode](https://github.com/DaemonAlex/dps-filmmode) | One key hides every HUD layer and gives a smooth free camera for recording. |
| [dps-fuel](https://github.com/DaemonAlex/dps-fuel) | Gas station drive-offs for the ox_fuel nozzle: ripped hose, pump fire, station camera and a police call, by odds. Pairs with dps-insurance. |
| [dps-voice](https://github.com/DaemonAlex/dps-voice) | Spoken lines for NPCs, station announcements, dispatch and shops, from local voice models first. Pairs with dps-ainpcs. |
| [dps-bags](https://github.com/DaemonAlex/dps-bags) | Real bags for ox_inventory: the bag you carry shows on your character. |
| [dps-items](https://github.com/DaemonAlex/dps-items) | Item rules for ox_inventory: locked items, glovebox seats and an exploit watch. |
| [dps-furniture](https://github.com/DaemonAlex/dps-furniture) | Puts streamed furniture packs into the qs-housing furniture shop. |
| [dps-shellbrowser](https://github.com/DaemonAlex/dps-shellbrowser) | Staff tool to look at every qs-housing shell and set its door. |
| [dps-signs](https://github.com/DaemonAlex/dps-signs) | Rotates city messages across the SmartSigns road boards. |
| [dps-stationclear](https://github.com/DaemonAlex/dps-stationclear) | Hides map props that are in the way and keeps stray game peds off chosen spots. |
| [dps-citymap](https://github.com/DaemonAlex/dps-citymap) | A ready-made map of the whole city, cut into tiles for in-game screens. |
| [dps-cayo](https://github.com/DaemonAlex/dps-cayo) | Switches on the game's own Cayo Perico island, and nothing else. |
| [dps-aviation](https://github.com/DaemonAlex/dps-aviation) | Flight behaviour: aircraft idle instead of cutting out, sane taxi speed, a real start sequence. |
| [dps-airlines](https://github.com/DaemonAlex/dps-airlines) | Airlines job: passenger flights, cargo, charters, flight school and maintenance. |
| [dps-traintools](https://github.com/DaemonAlex/dps-traintools) | Rider tools for trains: board, sit, get off at a stop, ambient passengers. Pairs with dps-trains. |
| [dps-trains-stock](https://github.com/DaemonAlex/dps-trains-stock) | Train models and carriage sets for the train system. No scripts. Pairs with dps-trains. |
| [dps-traintracks](https://github.com/DaemonAlex/dps-traintracks) | Extra train track data. No scripts. Pairs with dps-trains. |
| [dps-crossings](https://github.com/DaemonAlex/dps-crossings) | Level crossings that close when a train comes. Pairs with dps-trains. |
| [dps-transit](https://github.com/DaemonAlex/dps-transit) | Passenger rail planning and scheduling (older system; dps-trains runs today). |
| [dps-maritime](https://github.com/DaemonAlex/dps-maritime) | Dock work and boat deliveries with progression. |
| [dps-maritime-maps](https://github.com/DaemonAlex/dps-maritime-maps) | Map files for the Jetsam docks, the map half of dps-maritime. |
| [dps-proracing](https://github.com/DaemonAlex/dps-proracing) | Circuit racing with lobbies, an AI practice grid and lap times. |
| [dps-carmenu](https://github.com/DaemonAlex/dps-carmenu) | Staff vehicle browser and spawner over the live Qbox vehicle list. |
| [dps-clothingbrowser](https://github.com/DaemonAlex/dps-clothingbrowser) | Staff tool to browse, identify and export clothing and uniforms. |
| [dps-lootpeds](https://github.com/DaemonAlex/dps-lootpeds) | Loot dead NPCs, with loot tables per model. |
| [dps-hookers](https://github.com/DaemonAlex/dps-hookers) | Adults-only RP (18+), adapted from MH Hookers by MaDHouSe. |
| [dps-weatherbridge](https://github.com/DaemonAlex/dps-weatherbridge) | Lets qb-weathersync and Renewed-Weathersync scripts work with night_natural_disasters. |
| [dps-fixes](https://github.com/DaemonAlex/dps-fixes) | Small server fixes kept in one resource. |
| [dps-bucketfix](https://github.com/DaemonAlex/dps-bucketfix) | Puts players back in the main world after spawning. |
| [dps-unfocus](https://github.com/DaemonAlex/dps-unfocus) | One key that frees a player stuck in a menu. |
| [dps-welcomecam](https://github.com/DaemonAlex/dps-welcomecam) | Aims the first camera a new player sees. |
| [dps-handlingdump](https://github.com/DaemonAlex/dps-handlingdump) | Developer tool: saves the stock handling of every vanilla vehicle. |
| [dps-weaponsounds](https://github.com/DaemonAlex/dps-weaponsounds) | Custom weapon sounds (planning; no code yet). |
| [dps-events](https://github.com/DaemonAlex/dps-events) | Playtime reward events (planning; no code yet). |
