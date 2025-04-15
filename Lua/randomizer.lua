-- Pseudorandom Numbers Library v1.1 (HUD-safe version)

-- Initial state values
local rngstate = {
	xx = 5197528,
	yy = 3154710,
	zz = 9406548,
	ww = 1028369
}

-- Sync state with leveltime so it desyncs predictably between maps
addHook("MapChange", function()
	rngstate.xx = $ + leveltime
end)

-- Run the PRNG every ThinkFrame
addHook("ThinkFrame", function()
	local t = rngstate.xx ^^ (rngstate.xx << 11)
	rngstate.xx = rngstate.yy
	rngstate.yy = rngstate.zz
	rngstate.zz = rngstate.ww
	rngstate.ww = rngstate.ww ^^ (rngstate.ww >> 19) ^^ t ^^ (t >> 8)
end)

-- Main RNG function
function A_Random()
	return rngstate.ww
end

-- Helpers
function A_RandomKey(n)
	return abs(A_Random() % n)
end

function A_RandomRange(a, b)
	return a + abs(A_Random() % (b - a + 1))
end

function A_RandomDatas()
	return rngstate
end