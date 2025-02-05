local carShortName = ac.INIConfig.carData(0, "car.ini"):get("INFO", "SHORT_NAME", "S")

local car = ac.getCar(0)

local lapCount = 0

local lapTimes = {}

local setupSpinnersWindowSize = vec2(830 * cui.scaleX() / 100, 605 * cui.scaleY() / 100)
local setupSpinnersWindowHeaderSize = vec2(830 * cui.scaleX() / 100, 25 * cui.scaleY() / 100)

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
	setCursorX(15)
	setCursorY(15)

	cui.childWindow(
		"leaderboard_page",
		setupSpinnersWindowSize,
		false,
		ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
		function()
			ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.Appearance.uiColor1, 0, ui.CornerFlags.None)
			ui.drawRectFilled(
				vec2(0, 0),
				setupSpinnersWindowHeaderSize,
				settings.Appearance.uiColor1,
				0,
				ui.CornerFlags.None
			)

			setCursorY(0)
			ui.dwriteTextAligned(
				"Driver",
				18 * cui.scaleY() / 100,
				ui.Alignment.Start,
				ui.Alignment.Start,
				ui.availableSpace(),
				false,
				rgbm.colors.white
			)

			setCursorY(35)

			for i, c in ac.iterateCars.leaderboard() do
				local buttonString = string.format(
					"%s | %s | %s | %s | %s",
					ac.getDriverName(c.index),
					ac.getCarName(c.index),
					ac.getTyresName(c.index, c.compoundIndex),
					c.lapCount,
					ac.lapTimeToString(c.bestLapTimeMs)
				)

				ui.modernButtonAdvanced("##driverleaderboard" .. i, vec2(ui.availableSpaceX(), 30))

				ui.sameLine()
				setCursorX(10)
				ui.image(countryFlagDir .. "\\" .. ac.getDriverNationCode(c.index) .. ".png", vec2(30, 30))
				ui.sameLine()

				ui.dwriteTextAligned(
					ac.getDriverName(c.index),
					18 * cui.scaleY() / 100,
					ui.Alignment.Start,
					ui.Alignment.Start,
					vec2(ui.availableSpaceX() / 5, 20),
					false,
					rgbm.colors.white
				)

				ui.sameLine()
				ui.dwriteTextAligned(
					carShortName,
					18 * cui.scaleY() / 100,
					ui.Alignment.Start,
					ui.Alignment.Start,
					vec2(ui.availableSpaceX() / 4, 20),
					false,
					rgbm.colors.white
				)

				ui.sameLine()
				ui.dwriteTextAligned(
					ac.getTyresName(c.index, c.compoundIndex),
					18 * cui.scaleY() / 100,
					ui.Alignment.Start,
					ui.Alignment.Start,
					vec2(ui.availableSpaceX() / 3, 20),
					false,
					rgbm.colors.white
				)

				ui.sameLine()
				ui.dwriteTextAligned(
					c.lapCount,
					18 * cui.scaleY() / 100,
					ui.Alignment.Start,
					ui.Alignment.Start,
					vec2(ui.availableSpaceX() / 2, 20),
					false,
					rgbm.colors.white
				)

				ui.sameLine()
				ui.dwriteTextAligned(
					ac.lapTimeToString(c.bestLapTimeMs),
					18 * cui.scaleY() / 100,
					ui.Alignment.Start,
					ui.Alignment.Start,
					vec2(ui.availableSpaceX() / 1, 20),
					false,
					rgbm.colors.white
				)
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
