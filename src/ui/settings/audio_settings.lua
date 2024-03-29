local channels = {
	"Main",
	"Rain",
	"Weather",
	"Track",
	"Wipers",
	"Car Components",
	"Wind",
	"Tyres",
	"Surfaces",
	"Dirt",
	"Engine",
	"Transmission",
	"Opponents",
}

table.sort(channels)

function audioSettings()
	setCursorY(60)

	for k, v in ipairs(channels) do
		local id = string.replace(v, " ", "")

		setCursorX(10)

		local value, changed =
			ui.slider("##" .. id, ac.getAudioVolume(ac.AudioChannel[id]) * 100, 0, 100, v .. ": %.0f")

		if changed then
			ac.setAudioVolume(ac.AudioChannel[id], value / 100)
		end
	end
end
