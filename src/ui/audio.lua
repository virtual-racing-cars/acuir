local delayTimer = 0
local delayTime = 0.125

local peak = 0.5

local function playAudio(file)
	if delayTimer > os.clock() then
		return
	end
	local audioEvent =
		ac.AudioEvent.fromFile({ filename = "assets\\sfx\\%s.mp3" % file, use3D = false, loop = false }, false)

	-- audioEvent.volume = 0.125 * (1 + 30 * peak)
	audioEvent.volume = 0.125
	audioEvent:resume()
	delayTimer = os.clock() + delayTime
end

function audioDriver(dt)
	-- local mediaPeak = ac.mediaCurrentPeak()
	-- mediaPeak = math.min(math.max(mediaPeak.x, mediaPeak.y), 0.5)
	-- peak = math.applyLag(peak, mediaPeak, mediaPeak > peak and 0.997 or 0, dt)

	if ui.anyItemHovered() and ui.mouseClicked(ui.MouseButton.Left) then
		playAudio("gui_click")
	end
end

function audioTrigger()
	if ui.anyItemHovered() and ui.mouseClicked(ui.MouseButton.Left) then
		playAudio("gui_click")
		return
	end

	playAudio("gui_nav")
end
