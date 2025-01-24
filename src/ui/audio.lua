local focuseItem = 0

local delayTimer = 0
local delayTime = 0.1

local function playAudio(file)
	if delayTimer > os.clock() then
		return
	end
	ac.AudioEvent.fromFile({ filename = "assets\\sfx\\%s.mp3" % file, use3D = false, loop = false }, false):resume()
	delayTimer = os.clock() + delayTime
	ac.log("hi")
end

function audioDriver()
	if ui.anyItemHovered() and ui.mouseClicked(ui.MouseButton.Left) then
		playAudio("gui_click")
		return
	end

	if ui.getHoveredID() ~= focuseItem and ui.getHoveredID() ~= 0 and not ui.mouseClicked(ui.MouseButton.Left) then
		playAudio("gui_nav")
	end
	focuseItem = ui.getHoveredID()
end

function audioTrigger()
	playAudio("gui_nav")
end
