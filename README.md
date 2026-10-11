# dps-autoshops

DelPerroSands automatic repair shops.

- **No mechanic on duty** at a player-run shop: the five automatic shops (La Mesa, LSIA, Harmony, Beeker's Garage, Lombardt Bay) run the normal JG Mechanic self-service menu.
- **A mechanic on duty** at Benny's, Los Santos Customs, Bay Area Customs or the Sandy Shores shop: the automatic shop shows *"Please visit or request a tow to:"* with the open shops, and offers only a simple repair (engine and body back to 600, enough to drive). It costs 1.5 times the full self-service repair (Damon, 2026-10-11).

## How it fits

- The five shops are `type = "self-service"` entries in `jg-mechanic/config/config.lua` (`auto_*`).
- `jg-mechanic/client/cl-locations.lua` (a file JG leaves open for edits) calls `exports["dps-autoshops"]:TakeOver(name)` on zone enter and `Leave()` on exit. When `TakeOver` returns false, JG carries on as normal.
- The server counts on-duty players with `qbx_core:GetDutyCountJob` and prices the car the same way JG does (dealership price, then the Qbox vehicle list, then 50,000).
- The server checks the player and the car are at the shop before charging. Bank first, then cash.

## Config

`config.lua`: shop jobs, shop spots, the full-repair numbers (same as JG), the 1.5 multiplier, the simple-repair health levels.

## Tests

```
lua5.4 tests/run.lua
```
