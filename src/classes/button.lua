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

	return clicked
end
