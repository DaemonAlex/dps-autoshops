-- Runs every tests/test_*.lua. Run from the repo root: lua5.4 tests/run.lua
package.path = 'tests/?.lua;' .. package.path

local passed, failed = 0, 0
function Check(name, cond)
    if cond then passed = passed + 1 else failed = failed + 1; print('FAIL ' .. name) end
end

local files = {}
local pipe = io.popen('ls tests/test_*.lua 2>/dev/null')
for line in pipe:lines() do files[#files + 1] = line end
pipe:close()
table.sort(files)
for i = 1, #files do dofile(files[i]) end

print(('%d passed, %d failed'):format(passed, failed))
os.exit(failed == 0 and 0 or 1)
