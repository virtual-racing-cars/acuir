local audioBlip = ui.MediaPlayer(ac.dirname() .. "\\menu_nav_2.mp3")

local focuseItem = ""

audioBlip:setLooping(false)
audioBlip:setVolume(0.2)
audioBlip:setPlaybackRate(2)
local function playAudio()
	audioBlip:play()
end

function audioDriver()
	if ui.getHoveredID() ~= focuseItem and ui.getHoveredID() ~= 0 and not ui.mouseClicked(ui.MouseButton.Left) then
		audioBlip:setVolume(0.2)
		audioBlip:setPlaybackRate(2)
		playAudio()
	end
	focuseItem = ui.getHoveredID()

	if ui.anyItemHovered() and ui.mouseClicked(ui.MouseButton.Left) then
		audioBlip:setVolume(1)
		audioBlip:setPlaybackRate(0.5)
		playAudio()
	end
end

function audioTrigger()
	audioBlip:setVolume(0.2)
	audioBlip:setPlaybackRate(2)
	playAudio()
end
