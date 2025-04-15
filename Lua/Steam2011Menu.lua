-- stuff for a would-be GoldSrc menu when i get the time
-- Hopefully this structure looks good for the others
local kombiHL1LocalWindows = {
	["Options"] =
	{
		["options"] =
			{
			type = "tabs",
			x = 10,
			y = 9,
			w = 25,
			h = 8,
			args =
				{
				contents =
					{
					{label = "Graphics", icon = "STEAM2011ICO"},
					"Gameplay" -- legacy system
					}
				}
			},
		["graphicssettings"] =
			{
			type = "input",
			x = 10,
			y = 18,
			visible = false,
			args =
				{
				options =
					{
						{
							type = "radio",
							x = 6,
							y = 0,
							label = "Prefer Command-Based Inputs",
							tooltip = "Toggles if inputs use commands,\nRather than the vanilla buttons.\nRecommended ON if you've played\nHalf-Life before.",
							placeholder = false
						},
						{
							type = "button",
							x = 6,
							y = 12,
							label = "Reset HUD Visibility Status",
							tooltip = "Automatically re-enables every HUD element.\nUse this if necessary!!"
						},
						{
						type = "dropdown",
						x = 6,
						y = 20,
						label = "Random Dropdown",
						tooltip = "Broke ass wagie",
						options = {
							"Sonic the Hedgehog",
							"Sonic the Hedgehog 2",
							"Sonic the Hedgehog CD",
							"Sonic the Hedgehog Spinball",
							"Sonic the Hedgehog 3",
							"Sonic & Knuckles",
							"Knuckles' Chaotix",
							},
						placeholder = "Sonic the Hedgehog Spinball" -- both should be valid
						},
						{
						type = "radio",
						x = 6,
						y = 50,
						label = "Random Selection",
						tooltip = "What the fuck why is this here\nWho ordered it\nWhy order it",
						options = {
							"Sonic Adventure",
							"Sonic Adventure 2",
							"Sonic Heroes",
							"Sonic Advance",
							"Sonic Advance 2",
							"Sonic Advance 3",
							},
						placeholder = 1 -- both should be valid
						},
						/*
						{
						type = "checkbox",
						x = 6,
						y = 100,
						tooltip = "Sonic found dead in Toronto",
						options = {
							"Sonic Adventure",
							"Sonic Adventure 2",
							"Sonic Heroes",
							"Sonic Advance",
							"Sonic Advance 2",
							"Sonic Advance 3",
							},
						placeholder = {1, 6} -- ...or index via {"Sonic Adventure", "Sonic Advance 3"} like the madman you are
						},
						{
						type = "password", -- acts like HTML <input type="password">
						x = 6,
						y = 110,
						label = "Stupid fucking text input that acts like a password box",
						tooltip = "FUUUCK!! I HATE IT!!!"
						},
						{
						type = "text", -- acts like HTML <input type="text">
						x = 6,
						y = 120,
						label = "Based fucking text input that acts like a text box",
						tooltip = "FUUUCK!! I LOVE IT!!!",
						placeholder = "i love luigi actually"
						},
						{
						type = "slider",
						x = 6,
						y = 120,
						label = "Lubed up slider",
						length = 60,
						min = 0,
						max = 100,
						default = 50
						},
						*/
				}
			},
			func = function(player)
				if player.currenttab["Options"]["options"] == "Graphics"
					graphicssettings.visible = true
				else
					graphicssettings.visible = false
				end
			end
		}
	}
}

local gldsrcwindowflags = 0

local function drawBaseWindow(v, x, y, w, h, invert)
	if not w or not h return end
	if invert
		v.drawFill(x, y, w, h, 91)
		v.drawFill(x, y, w-1, h-1, 95)
		v.drawFill(x+1, y+1, w-2, h-2, 93)
	else
		v.drawStretched(x*FRACUNIT, y*FRACUNIT, max(w,0)*FRACUNIT, max(h,0)*FRACUNIT, v.cachePatch("HL1WINDOWCLR2"), gldsrcwindowflags)
		v.drawStretched(x*FRACUNIT, y*FRACUNIT, max(w-1,0)*FRACUNIT, max(h-1,0)*FRACUNIT, v.cachePatch("HL1WINDOWCLR1"), gldsrcwindowflags)
		v.drawStretched(max(x+1,0)*FRACUNIT, max(y+1,0)*FRACUNIT, max(w-2,0)*FRACUNIT, max(h-2,0)*FRACUNIT, v.cachePatch("HL1WINDOWCLR3"), gldsrcwindowflags)
	end
end

-- Utility function to draw a tooltip near the mouse cursor
local function drawTooltip(v, tooltipText, offsetX, offsetY)
	offsetX = offsetX or 0 -- horizontal offset from the mouse cursor
	offsetY = offsetY or 0 -- vertical offset from the mouse cursor

	local mouseX, mouseY = input.getCursorPosition()
	mouseX = mouseX / (v.width() / 320)
	mouseY = mouseY / (v.height() / 200)

	local padding = 2

	-- Split tooltip text into lines
	local lines = {}
	for line in tooltipText:gmatch("([^\n]*)\n?") do
		if line ~= "" or #lines == 0 then
			table.insert(lines, line)
		end
	end

	-- Calculate max width and total height based on lines
	local maxLineWidth = 0
	for _, line in ipairs(lines) do
		local lineWidth = v.stringWidth(line, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
		if lineWidth > maxLineWidth then
			maxLineWidth = lineWidth
		end
	end

	local lineHeight = 8 -- Approximate height for "thin" font
	local tipWidth = maxLineWidth + padding * 2
	local tipHeight = (#lines * lineHeight) + padding * 2

	-- Draw the tooltip background using drawBaseWindow
	drawBaseWindow(v, mouseX + offsetX, mouseY + offsetY, tipWidth, tipHeight, false)

	-- Draw each line of the tooltip
	for i, line in ipairs(lines) do
		v.drawString(
			mouseX + offsetX + padding,
			mouseY + offsetY + padding + (i - 1) * lineHeight,
			line,
			gldsrcwindowflags|V_ALLOWLOWERCASE,
			"thin"
		)
	end
end

local function processWindowExtra(data, level, baseX, baseY)
	local results = {}
	level = level or 0

	for key, value in pairs(data or {}) do
		if type(value) == "table" then
			local itemX = value.x
			local itemY = value.y

			-- Process known structure types
			if value.type == "tabs" and value.args and value.args.contents then
				table.insert(results, { key = key, type = "tabs", contents = value.args.contents, x = itemX, y = itemY, w = value.w or 0, h = value.h or 0 })
			elseif value.type == "input" then
				-- Process input types (radio, button, dropdown, etc.)
				for _, option in ipairs(value.args.options or {}) do
					table.insert(results, { 
						key = key, 
						type = "input", 
						subtype = option.type, 
						label = option.label or option.type, 
						options = option.options,
						x = itemX+option.x, y = itemY+option.y, 
						tooltip = option.tooltip,
						placeholder = option.placeholder,
						min = option.min,
						max = option.max,
						default = option.default
					})
				end
			else
				-- Recurse into extra structs for nested structures
				local nestedResults = processWindowExtra(value, level + 1, itemX, itemY)
				for _, nestedResult in ipairs(nestedResults) do
					table.insert(results, nestedResult)
				end
			end
		else
			-- Handle non-table values (primitives)
			table.insert(results, { key = key, type = type(value), value = value, x = baseX, y = baseY })
		end
	end

	return results
end

-- Get item dimensions based on type, subtype, and content.
local function getItemDimensions(v, item)
    -- If width and height are already provided, use them.
    if item.w and item.h then
        return item.w, item.h
    end

    -- Determine dimensions based on subtype if defined.
    if item.subtype then
        if item.subtype == "button" then
            local width = v.stringWidth(item.label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin") + 6
            return width, 13
        elseif item.subtype == "dropdown" then
            -- Here, we assume a fixed dropdown width and an added height to account for the label.
            return 120, 22  -- e.g., 15 for the dropdown plus extra room for the label.
        elseif item.subtype == "checkbox" then
            local textWidth = v.stringWidth(item.label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
            return 20 + 5 + textWidth, 20  -- 20 for the box, plus 5px gap before the text.
        elseif item.subtype == "radio" then
            local textWidth = v.stringWidth(item.label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
            return 20 + 5 + textWidth, 14  -- 20 for radio icon and extra space for the text.
        elseif item.subtype == "text" or item.subtype == "password" then
            return 100, 20  -- Default values if not provided.
        elseif item.subtype == "slider" then
            return 120, 20
        end
    elseif item.type == "tabs" then
        -- Calculate the total width as the sum of each tab's width.
        local totalWidth = 0
        local maxHeight = 0
        for _, tab in ipairs(item.contents or {}) do
            local label = tab.label or tab or ""
            local w = v.stringWidth(label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin") + 3
            totalWidth = totalWidth + w
            maxHeight = math.max(maxHeight, 10)  -- Assume a default height for each tab.
        end
        return totalWidth, maxHeight
    end

    return item.w or 100, item.h or 20
end

-- Revised isMouseOver to use the auto-generated dimensions.
local function isMouseOver(v, x, y, w, h)
    local mouseX, mouseY = input.getCursorPosition()
    mouseX, mouseY = mouseX/(v.width()/320), mouseY/(v.height()/200)
    return mouseX >= x and mouseX <= (x + w) and mouseY >= y and mouseY <= (y + h)
end

-- Process mouse events: now we automatically calculate dimensions for each item.
local function processMouseEvents(v, contents, player)
    if (mouse.buttons & MB_BUTTON1) then
        for _, item in ipairs(contents) do
            local itemWidth, itemHeight = getItemDimensions(v, item)
            if isMouseOver(v, item.x, item.y, itemWidth, itemHeight) then
                if type(item.onPress) == "function" then
                    item.onPress(item, player)
                    break
                end
            end
        end
    end
end

rawset(_G, "kombiDrawGoldsrcWindow", function(v, player, x, y, w, h, title, icon, buttons, windowextra)
	drawBaseWindow(v, x, y, w, h+10)
	if v.patchExists(icon)
		local picon = v.cachePatch(icon)
		v.drawScaled((x+2)*FRACUNIT, (y+2)*FRACUNIT, FixedDiv(10*FRACUNIT, picon.width*FRACUNIT), picon)
		v.drawString(x+14, y+4, tostring(title), gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
	else
		v.drawString(x+2, y+2, tostring(title), gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
	end

	local contents = processWindowExtra(windowextra, 0, x, y+15)

	for _, item in ipairs(contents) do
		if item.type == "tabs" then
			/*
			local tabX = item.x
			local tabY = item.y
			drawBaseWindow(v, tabX-1, tabY+8, item.w+2, item.h)
			-- Draw tab contents
			for _, tab in ipairs(item.contents) do
				local tabWidth = v.stringWidth(tab.label or tab, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin") + 3
				drawBaseWindow(v, tabX-1, tabY-1, tabWidth, 10)
				local highlight = isMouseOver(v, tabX-1, tabY-1, tabWidth, 10) and V_BROWNMAP or V_GRAYMAP
				v.drawString(tabX, tabY, tab.label or tab, highlight|gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
				tabX = tabX + tabWidth
			end
			*/
		elseif item.type == "input" then
			-- ... But what are you trying to index, exactly?
			if item.subtype == "radio" then
				v.drawScaled(item.x*FRACUNIT, item.y*FRACUNIT, 2*FRACUNIT/3, v.cachePatch("HL1CHECKBOXTRUE"), gldsrcwindowflags)
				v.drawString(item.x + 12, item.y + 1, item.label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
			elseif item.subtype == "button" then
				local btnWidth = v.stringWidth(item.label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin") + 6
				drawBaseWindow(v, item.x, item.y, btnWidth, 13)
				v.drawString(item.x + 3, item.y + 3, item.label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
			elseif item.subtype == "dropdown" then
				drawBaseWindow(v, item.x, item.y + 7, 120, 15, true)
				v.drawString(item.x, item.y, item.label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
				v.drawString(item.x + 3, item.y + 11, "Dropdown Placeholder", gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
			elseif item.subtype == "checkbox" then
				-- Draw checkbox placeholder
				drawBaseWindow(v, item.x, item.y, 20, 20)
				v.drawString(item.x + 25, item.y, item.label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
			elseif item.subtype == "password" or item.subtype == "text" then
				-- Draw text input
				drawBaseWindow(v, item.x, item.y, item.w or 100, item.h or 20)
				v.drawString(item.x + 5, item.y + 5, item.label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
				if item.placeholder then
					v.drawString(item.x + 5, item.y + 20, item.placeholder, gldsrcwindowflags|V_ALLOWLOWERCASE|V_GRAYMAP, "thin")
				end
			elseif item.subtype == "slider" then
				-- Draw slider placeholder
				drawBaseWindow(v, item.x, item.y, 120, 20)
				v.drawString(item.x + 5, item.y + 5, item.label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
			end
		end
	end

	-- Check for any item under the mouse that has a tooltip.
    local tooltipToShow = nil
    for _, item in ipairs(contents) do
        if item.tooltip then
            local itemWidth, itemHeight = getItemDimensions(v, item)
            if isMouseOver(v, item.x, item.y, itemWidth, itemHeight) then
                tooltipToShow = item.tooltip
                break  -- Stop at the first tooltip found, or you could determine which one has priority.
            end
        end
    end

    -- Draw the tooltip at a fixed "top" position relative to the window.
    if tooltipToShow then
        -- For demonstration, we position it at the same horizontal offset as the window's x position and
        -- just above the window (adjust y as desired).
        drawTooltip(v, tooltipToShow)
    end

	processMouseEvents(v, contents, player)  -- Pass in the player if needed.
end)
/*
hud.add(function(v,player)
	kombiDrawGoldsrcWindow(v,player,0,0,150,190,"Options","STEAM2011ICO","close",kombiHL1LocalWindows["Options"])
	input.setMouseGrab(false)
end)
*/