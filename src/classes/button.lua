local menuNav = ui.MediaPlayer(ac.dirname() .. "\\menu_nav_2.mp3")
local menuClick = ui.MediaPlayer(ac.dirname() .. "\\menu_nav_2.mp3")

local menuNavTrigged = false
local menuClickTrigged = false
local menuItem = ""

menuClick:setLooping(false)
menuClick:setPitch(3)
menuClick:setVolume(0.3)
menuNav:setLooping(false)
menuNav:setVolume(0.1)

function ui.modernButtonAdvanced(label, size, flags, icon, iconSize)
	local clicked = ui.modernButton(label, size, flags, icon, iconSize)

	if flags ~= ui.ButtonFlags.Disabled then
		if ui.itemHovered(ui.HoveredFlags.None) and not menuNavTrigged then
			menuNav:play()
			menuNavTrigged = true
			menuItem = label
		elseif not ui.itemHovered(ui.HoveredFlags.None) and menuNavTrigged and menuItem == label then
			menuNavTrigged = false
		end

		if ui.itemActivated() then
			menuClick:play()
		end
	end

	return clicked
end

local activeLabel = ""
function ui.buttonAdvanced(label, size, flags)
	if activeLabel == label then
		ui.pushStyleColor(ui.StyleColor.Button, SETTINGS.uiColor2)
		ui.pushStyleColor(ui.StyleColor.ButtonHovered, SETTINGS.uiColor2)
	end
	local clicked = ui.button(label, size, flags)

	if activeLabel == label then
		ui.popStyleColor(2)
	end

	if ui.itemActive() then
		activeLabel = label
	end

	if flags ~= ui.ButtonFlags.Disabled then
		if ui.itemHovered(ui.HoveredFlags.None) and not menuNavTrigged then
			menuNav:play()
			menuNavTrigged = true
			menuItem = label
		elseif not ui.itemHovered(ui.HoveredFlags.None) and menuNavTrigged and menuItem == label then
			menuNavTrigged = false
		end

		if ui.itemActivated() then
			menuClick:play()
		end
	end

	return clicked
end

function ui.arrowButtonAdvanced(id, direction, size, flags)
	local clicked = ui.arrowButton("##" .. direction .. id, ui.Direction[direction], size, flags)

	if ui.itemHovered(ui.HoveredFlags.None) and not menuNavTrigged then
		menuNav:play()
		menuNavTrigged = true
		menuItem = id
	elseif not ui.itemHovered(ui.HoveredFlags.None) and menuNavTrigged and menuItem == id then
		menuNavTrigged = false
	end

	if ui.itemActivated() then
		menuClick:play()
	end

	return clicked
end
