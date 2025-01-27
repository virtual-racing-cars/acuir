local sim = ac.getSim()

function playerListButton(car, xPos, yPos, width, height)
	ui.pushDWriteFont(ui.DWriteFont("Rajdhani"):weight(ui.DWriteFont.Weight.SemiBold))

	ui.setCursorX(xPos)
	ui.setCursorY(yPos)
	if ui.invisibleButton("##playerlistbutton" .. car.index, vec2(width, height)) then
		ac.focusCar(car.index)
	end

	local evenCar = car.racePosition % 2 == 0
	ui.drawRectFilled(
		vec2(xPos, yPos),
		vec2(xPos + width, yPos + height),
		evenCar and SETTINGS.uiColor1 / 4 or SETTINGS.uiColor1 / 2
	)

	ui.drawRectFilled(
		vec2(xPos, yPos),
		vec2(xPos + width / 15, yPos + height),
		sim.focusedCar == car.index and SETTINGS.uiColor2 or SETTINGS.uiColor1
	)

	ui.setCursorX(xPos)
	ui.setCursorY(yPos)
	ui.dwriteTextAligned(car.racePosition, height / 2, ui.Alignment.End, ui.Alignment.Center, vec2(width / 20, height))

	ui.setCursorX(xPos + width / 12)
	ui.setCursorY(yPos)
	ui.dwriteTextAligned(
		ac.getDriverName(car.index),
		height / 2,
		ui.Alignment.Start,
		ui.Alignment.Center,
		vec2(width, height)
	)

	if car.isInPitlane then
		ui.setCursorX(xPos + width - width / 15)
		ui.setCursorY(yPos)

		ui.drawRectFilled(vec2(xPos + width - width / 15, yPos), vec2(xPos + width, yPos + height), SETTINGS.uiColor3)

		ui.dwriteTextAligned(
			"P",
			height / 2,
			ui.Alignment.Center,
			ui.Alignment.Center,
			vec2(width / 15, height),
			false,
			rgbm.colors.black
		)
	end

	ui.setCursorX(xPos + width - (width / 15) * 2)
	ui.setCursorY(yPos)

	ui.dwriteTextAligned(
		ac.getTyresName(car.index, car.compoundIndex),
		height / 2,
		ui.Alignment.Center,
		ui.Alignment.Center,
		vec2(width / 15, height),
		false,
		rgbm.colors.white
	)

	ui.drawLine(vec2(xPos, yPos), vec2(xPos + width, yPos), rgbm.colors.black)
	ui.drawLine(vec2(xPos, yPos + height), vec2(xPos + width, yPos + height), rgbm.colors.black)

	ui.popDWriteFont()
end
