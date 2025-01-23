local audioBlip = ui.MediaPlayer("assets\\audio\\menu_nav.mp3")
local focuseItem = ""

-- ac.loadSoundbank("assets\\audio\\tatuusfa1.bank")

-- local audioEvent = ac.AudioEvent("cars/tatuusfa1/horn", false)

-- ac.loadSoundbank(
-- 	ac.getFolder(ac.FolderID.ContentCars) .. "\\" .. ac.getCarID(0) .. "\\sfx\\vrc_formula_alpha_2024_csp.bank"
-- )
-- local audioEvent = ac.AudioEvent("cars/vrc_formula_alpha_2024_csp/tones_int", false)
-- audioEvent.volume = 0.2
-- audioEvent.pitch = 0.2
-- audioEvent.cameraInteriorMultiplier = 1
-- audioEvent.cameraExteriorMultiplier = 1
-- audioEvent.cameraTrackMultiplier = 1
-- audioEvent:setDistanceMax(500)
-- audioEvent:setVolumeChannel(ac.AudioChannel.Main)

audioBlip:setLooping(false)
audioBlip:setVolume(0.5)
audioBlip:setPlaybackRate(3)
audioBlip:setLooping(false)

-- local state = true

local function playAudio()
	if audioBlip:ended() or not audioBlip:playing() then
		audioBlip:play()
	end
	-- audioEvent:start()
	-- state = not state

	-- audioEvent:setPosition(ac.getCar(0).position)
	-- audioEvent:setParam("state", 1)
	-- audioEvent:setParam("variation", 0.5)
	-- audioEvent:setParam("stateWheel", 1)
	-- audioEvent:setParam("state", 1)

	-- audioEvent:stop()
	-- audioEvent:start()
	-- ac.log(audioEvent:isPlaying())
end

function audioDriver()
	if ui.getHoveredID() ~= focuseItem and ui.getHoveredID() ~= 0 and not ui.mouseClicked(ui.MouseButton.Left) then
		audioBlip:setVolume(0.5)
		audioBlip:setPitch(1)
		playAudio()
	end
	focuseItem = ui.getHoveredID()

	if ui.anyItemHovered() and ui.mouseClicked(ui.MouseButton.Left) then
		audioBlip:setVolume(2)
		audioBlip:setPitch(0.2)
		playAudio()
	end

	-- ac.log(audioEvent:isPaused())
	-- ac.log(audioEvent:isValid())
end

function audioTrigger()
	audioBlip:setVolume(0.5)
	playAudio()
end
