-- Generic serializer and deserializer for files written in the Lua format.

-- List of types that we do not store directly.
local DENIED_TYPES = {
	["function"] = true,
	["thread"]   = true,
	["proto"]    = true,
	["upval"]    = true,
	["no value"] = true,  -- ...Why would you store this? HOW?
	["nil"]      = true,
}

-- Helper function to serialize individual values.
local function serializeValue(value, indent)
	indent = indent or ""
	local tp = type(value)
	-- If the type is in our deny list, store a placeholder.
	if DENIED_TYPES[tp] then
		return string.format("%q", "<unstorable: " .. tp .. ">")
	end

	if tp == "number" or tp == "boolean" then
		return tostring(value)
	elseif tp == "string" then
		return string.format("%q", value)
	elseif tp == "table" then
		return serializeTable(value, indent)
	elseif tp == "userdata" then
		-- If you stoop so low as to store userdata, then
		-- You should probably reconsider what you're doing.
		local udType = (userdataType and userdataType(value)) or "userdata"
		return string.format("%q", "<userdata: " .. udType .. ">")
	else
		-- Fallback for any other types.
		return string.format("%q", "<unsupported: " .. tp .. ">")
	end
end

-- Recursive function to serialize a table (supports nested tables)
local function serializeTable(tbl, indent)
	indent = indent or ""
	local str = "{\n"
	local nextIndent = indent .. "\t"
	for key, value in pairs(tbl) do
		-- Serialize keys: if key is a valid identifier, we can write it directly;
		-- otherwise we use the bracket notation.
		local keyStr
		if type(key) == "string" and key:match("^[%a_][%w_]*$") then
			keyStr = key
		else
			keyStr = "[" .. string.format("%q", key) .. "]"
		end
		str = str .. nextIndent .. keyStr .. " = " .. serializeValue(value, nextIndent) .. ",\n"
	end
	str = str .. indent .. "}"
	return str
end

-- Helper to trim whitespace
local function trim(s)
	return s:match("^%s*(.-)%s*$")
end

-- Helper to remove simple line comments (starting with --).
-- This removes text from a double-dash to the end of the line.
local function removeComments(s)
	-- Remove full-line and inline comments.
	return s:gsub("%s*%-%-.-\n", "\n")
end

-- Finds the position of the matching closing brace for a table literal.
local function findMatchingBrace(s, startPos)
	local pos = startPos
	local count = 0
	while pos <= #s do
		local char = s:sub(pos, pos)
		if char == "{" then
			count = count + 1
		elseif char == "}" then
			count = count - 1
			if count == 0 then
				return pos
			end
		end
		pos = pos + 1
	end
	return nil  -- No matching brace found.
end

-- Custom parser to deserialize a table from a string.
-- Custom parser to deserialize a table from a string.
local function deserializeTable(str)
	local tbl = {}
	str = trim(str)
	-- Remove comments.
	str = removeComments(str)
	-- Remove outer braces if present.
	if str:sub(1,1) == "{" and str:sub(-1,-1) == "}" then
		str = trim(str:sub(2, -2))
	end
	local pos = 1
	while pos <= #str do
		-- Try to find a key.
		local key, keyPatternEnd
		
		-- First, attempt to match a bare identifier key (e.g. key = "value").
		local s, e, k = str:find("^([%a_][%w_]*)%s*=%s*", pos)
		if s then
			key = k
			keyPatternEnd = e
		else
			-- If no match, attempt to match bracketed string keys (e.g. ["key"] = "value").
			s, e, k = str:find('%[%s*"(.-)"%s*%]%s*=%s*', pos)
			if s then
				key = k
				keyPatternEnd = e
			end
		end

		-- If no key was found, exit the loop.
		if not key or not keyPatternEnd then break end
		pos = keyPatternEnd + 1

		-- Skip any whitespace.
		local ws = str:sub(pos):match("^(%s+)")
		if ws then pos = pos + #ws end

		local firstChar = str:sub(pos, pos)
		local value
		-- Deserialize nested table.
		if firstChar == "{" then
			local endPos = findMatchingBrace(str, pos)
			if not endPos then error("Malformed table: no matching '}' found") end
			local subTableStr = str:sub(pos, endPos)
			value = deserializeTable(subTableStr)
			pos = endPos + 1
		-- Deserialize string values (including our placeholders).
		elseif firstChar == "\"" then
			local valStart, valEnd, valStr = str:find('("(.-)")', pos)
			if not valStart then error("Malformed string value for key: " .. key) end
			-- Remove the surrounding quotes.
			value = valStr
			pos = valEnd + 1
		-- Deserialize booleans by checking for the literal words "true" and "false".
		elseif str:sub(pos, pos+3) == "true" then
			value = true
			pos = pos + 4
		elseif str:sub(pos, pos+4) == "false" then
			value = false
			pos = pos + 5
		-- Otherwise, assume a number.
		else
			local valStart, valEnd, numStr = str:find("([-+]?[%d%.]+)", pos)
			if not valStart then error("Malformed numeric value for key: " .. key) end
			value = tonumber(numStr)
			pos = valEnd + 1
		end

		tbl[key] = value

		-- Skip optional comma and whitespace.
		local commaPattern = "^(%s*,%s*)"
		local commaMatch = str:sub(pos):match(commaPattern)
		if commaMatch then
			pos = pos + #commaMatch
		else
			local ws2 = str:sub(pos):match("^(%s+)")
			if ws2 then pos = pos + #ws2 end
		end
	end
	return tbl
end

-- Clean a table by removing nil keys.
local function cleanTable(tbl)
	if type(tbl) ~= "table" then return {} end
	local cleaned = {}
	for k, v in pairs(tbl) do
		if k ~= nil then
			cleaned[k] = v
		else
			print("Warning: Removed nil key from table")
		end
	end
	return cleaned
end

-- Generic function to load a table from a file.
-- If the file is not present, it returns the provided default table.
rawset(_G, "loadTableFromFile", function(filePath, defaultData)
	local file = io.openlocal(filePath)
	if file then
		local data = file:read("*a")
		file:close()
		-- Deserialize the table from the file and clean it.
		local parsed = cleanTable(deserializeTable(data) or {})
		return parsed
	else
		return defaultData or {}
	end
end)

-- Generic function to save a table to a file.
rawset(_G, "saveTableToFile", function(filePath, tbl)
	if io then
		local file = io.openlocal(filePath, "w+")
		if file then
			file:write(serializeTable(tbl))
			file:close()
		else
			print("Error: Could not open file for writing: " .. filePath)
		end
	end
end)