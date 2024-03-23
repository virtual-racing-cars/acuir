local car = ac.getCar(0)

local lapCount = 0

local lapTimes = {}

local setupPageWindowPos = vec2(100 * UI_SCALE_X / 100, 110 * UI_SCALE_Y / 100)

local countryFlagImages = {}
local countryFlagDir = ac.getFolder(ac.FolderID.Root) .. "\\content\\gui\\NationFlags"

ui.setAsynchronousImagesLoading(true)

io.scanDir(countryFlagDir, function(fileName, fileAttributes, callbackData)
	table.insert(countryFlagImages, countryFlagDir .. "\\" .. fileName)
end)

-- for i,c in ac.iterateCars() do
-- 	io.scanDir(ac.getCarID(i))
-- end

function TimeTablePage(sim)
	ui.setCursor(setupPageWindowPos)

	childWindow(
		"leaderboard_page",
		vec2(sim.windowWidth, sim.windowHeight - 110),
		false,
		ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
		function()
			setCursorX(10)
			setCursorY(10)

			ui.drawRectFilled(vec2(10, 0), vec2(700, 800), settings.uiPrimaryColor, 0, ui.CornerFlags.None)

			for i, c in ac.iterateCars.leaderboard() do
				local buttonString = string.format(
					"%s | %s | %s",
					ac.getDriverName(c.index),
					ac.getCarName(c.index),
					ac.lapTimeToString(c.bestLapTimeMs)
				)

				ui.image(countryFlagDir .. "\\" .. ac.getDriverNationCode(c.index) .. ".png", vec2(30, 30))
				ui.sameLine()
				ui.modernButtonAdvanced(buttonString, vec2(500, 30), ui.ButtonFlags.None)
			end

			if lapCount ~= car.lapCount then
				lapCount = car.lapCount

				local splits = {}

				for i = 0, #car.lastSplits - 1 do
					table.insert(splits, ac.lapTimeToString(car.lastSplits[i]))
				end

				table.insert(lapTimes, {
					car.lapCount,
					ac.getTyresName(car.index, car.compoundIndex),
					ac.lapTimeToString(car.previousLapTimeMs),
					table.concat(splits, ","),
					car.previousLapTimeMs - car.bestLapTimeMs,
				})
			end

			for i in ipairs(lapTimes) do
				setCursorX(20)
				ui.text(table.concat(lapTimes[i], " | "))
				ui.newLine(-15)
			end
		end
	)
end
