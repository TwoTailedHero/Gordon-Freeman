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
							x = 70,
							y = 80,
							label = "Stupid Memleak Fix",
							tooltip = "Toggles special FX like squash and stretch.\nAutomatically set depending on what version of SRB2 you run.",
							placeholder = MODVERSION < 55 -- Are we running a version unsupporting of common sense in clearing unused RAM?
						},
						/*
						{
							type = "button",
							x = 70,
							y = 90,
							label = "Reset HUD Visibility Status",
							tooltip = "Automatically re-enables every HUD element.\nUse this if necessary!!"
						},
						{
						type = "dropdown",
						x = 70,
						y = 100,
						label = "Random Dropdown",
						tooltip = "We found this dropdown in the bargain bin.\nDunno what to do with it, so it's here if it's important to anybody.",
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
						x = 70,
						y = 100,
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
						{
						type = "checkbox",
						x = 170,
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
						x = 70,
						y = 110,
						label = "Stupid fucking text input that acts like a password box",
						tooltip = "FUUUCK!! I HATE IT!!!"
						},
						{
						type = "text", -- acts like HTML <input type="text">
						x = 70,
						y = 120,
						label = "Based fucking text input that acts like a password box",
						tooltip = "FUUUCK!! I LOVE IT!!!",
						placeholder = "i love luigi actually"
						},
						{
						type = "slider",
						x = 70,
						y = 120,
						label = "Lubed up slider",
						-- no tooltip for this one fuck you
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
						label = label or "\$option.type\", 
						option = option,
						x = itemX, y = itemY, 
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

local function isMouseOver(v, x, y, w, h)
	local mouseX, mouseY = input.getCursorPosition()
	mouseX, mouseY = $1/(v.width()/320),$2/(v.height()/200)
	return mouseX >= x and mouseX <= x + w and mouseY >= y and mouseY <= y + h
end

rawset(_G, "kombiDrawGoldsrcWindow", function(v, x, y, w, h, title, icon, buttons, windowextra)
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
			-- That's well good and all, but what the hell are we trying to give as input, anyways?
			if item.subtype == "radio" then
				-- Draw radio button
				v.drawScaled(item.x*FRACUNIT, item.y*FRACUNIT, 2*FRACUNIT/3, v.cachePatch("HL1CHECKBOXTRUE"), gldsrcwindowflags)
				v.drawString(item.x + 20, item.y, item.label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
			elseif item.subtype == "button" then
				-- Draw button
				drawBaseWindow(v, item.x, item.y, 100, 20) -- Button placeholder
				v.drawString(item.x + 5, item.y + 5, item.label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
			elseif item.subtype == "dropdown" then
				-- Draw dropdown
				drawBaseWindow(v, item.x, item.y, 120, 20) -- Dropdown placeholder
				v.drawString(item.x + 5, item.y + 5, item.label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
			elseif item.subtype == "checkbox" then
				-- Draw checkbox (multiple selections)
				drawBaseWindow(v, item.x, item.y, 20, 20) -- Checkbox placeholder
				v.drawString(item.x + 25, item.y, item.label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
				-- Indicate checked options (like a list of selected ones)
			elseif item.subtype == "password" or item.subtype == "text" then
				-- Handle text input (password or plain text)
				drawBaseWindow(v, item.x, item.y, item.w, item.h)
				v.drawString(item.x + 5, item.y + 5, item.label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
				-- Draw placeholder if available
				if item.placeholder then
					v.drawString(item.x + 5, item.y + 20, item.placeholder, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
				end
			elseif item.subtype == "slider" then
				-- Handle slider input
				drawBaseWindow(v, item.x, item.y, 120, 20) -- Slider placeholder
				-- You could add a slider graphic here or similar interaction mechanism
				v.drawString(item.x + 5, item.y + 5, item.label, gldsrcwindowflags|V_ALLOWLOWERCASE, "thin")
			end
		end
	end
end)

hud.add(function(v,player)
	-- kombiDrawGoldsrcWindow(v,0,0,50,50,"Options","STEAM2011ICO","close",kombiHL1LocalWindows["Options"])
	-- input.setMouseGrab(false)
end)