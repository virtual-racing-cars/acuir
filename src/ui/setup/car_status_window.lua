local car = ac.getCar()

local setupSpinnersWindowSize = vec2(800 * UI_SCALE_X / 100, 450 * UI_SCALE_Y / 100)
local setupSpinnersWindowHeaderSize = vec2(800 * UI_SCALE_X / 100, 50 * UI_SCALE_Y / 100)

function CarStatusWindow()
	setCursorX(350)
	setCursorY(570)
	childWindow("setup_info_window", setupSpinnersWindowSize, false, ui.WindowFlags.None, function()
		ui.pushFont(ui.Font.Main)
		ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.uiPrimaryColor, 0, ui.CornerFlags.None)
		ui.drawRect(vec2(0, 0), ui.availableSpace(), rgbm(1, 1, 1, 0.25), 0, ui.CornerFlags.None)

		setCursorX(30)
		setCursorY(100)
		ui.text("Camber: " .. math.round(car.wheels[0].camber, 2))
		setCursorX(30)
		ui.text("Caster: " .. math.round(car.caster, 2))
		setCursorX(30)
		ui.text("Toe: " .. math.round(car.wheels[0].toeIn, 2))
		setCursorX(30)
		ui.text("Pressure (cold): " .. math.round(car.wheels[0].tyreStaticPressure, 2) .. " psi")
		setCursorX(30)
		ui.text("Pressure (hot): " .. math.round(car.wheels[0].tyrePressure, 2) .. " psi")
		setCursorX(30)
		ui.text("Temp: " .. math.round(car.wheels[0].tyreCoreTemperature, 2))

		setCursorX(30)
		setCursorY(320)
		ui.text("Camber: " .. math.round(car.wheels[2].camber, 2))
		setCursorX(30)
		ui.text("Toe: " .. math.round(car.wheels[2].toeIn, 2))
		setCursorX(30)
		ui.text("Pressure (cold): " .. math.round(car.wheels[2].tyreStaticPressure, 2) .. " psi")
		setCursorX(30)
		ui.text("Pressure (hot): " .. math.round(car.wheels[2].tyrePressure, 2) .. " psi")
		setCursorX(30)
		ui.text("Temp: " .. math.round(car.wheels[2].tyreCoreTemperature, 2))

		setCursorX(700)
		setCursorY(100)
		ui.text("Camber: " .. math.round(car.wheels[1].camber, 2))
		setCursorX(700)
		ui.text("Caster: " .. math.round(car.caster, 2))
		setCursorX(700)
		ui.text("Toe: " .. -math.round(car.wheels[1].toeIn, 2))
		setCursorX(700)
		ui.text("Pressure (cold): " .. math.round(car.wheels[1].tyreStaticPressure, 2) .. " psi")
		setCursorX(700)
		ui.text("Pressure (hot): " .. math.round(car.wheels[1].tyrePressure, 2) .. " psi")
		setCursorX(700)
		ui.text("Temp: " .. math.round(car.wheels[1].tyreCoreTemperature, 2))

		setCursorX(700)
		setCursorY(320)
		ui.text("Camber: " .. math.round(car.wheels[3].camber, 2))
		setCursorX(700)
		ui.text("Toe: " .. -math.round(car.wheels[3].toeIn, 2))
		setCursorX(700)
		ui.text("Pressure (cold): " .. math.round(car.wheels[3].tyreStaticPressure, 2) .. " psi")
		setCursorX(700)
		ui.text("Pressure (hot): " .. math.round(car.wheels[3].tyrePressure, 2) .. " psi")
		setCursorX(700)
		ui.text("Temp: " .. math.round(car.wheels[3].tyreCoreTemperature, 2))

		setCursorX(360)
		setCursorY(125)
		ui.text("Front Height: " .. math.round(car.rideHeight[0] * 1000, 1) .. " mm")

		setCursorX(360)
		setCursorY(325)
		ui.text("Rear Height: " .. math.round(car.rideHeight[1] * 1000, 1) .. " mm")

		setCursorX(360)
		setCursorY(425)
		ui.text("Plank Wear: " .. math.round(car.maxRelativePlankWear * 1000, 2) .. " mm")

		ui.drawRectFilled(vec2(0, 0), setupSpinnersWindowHeaderSize, rgbm(0.1, 0.1, 0.1, 0.5), 0, ui.CornerFlags.None)

		setCursorY(0)
		ui.dwriteTextAligned(
			"Car Status",
			35 * UI_SCALE_Y / 100,
			ui.Alignment.Center,
			ui.Alignment.Start,
			setupSpinnersWindowHeaderSize,
			false,
			rgbm.colors.white
		)

		ui.popFont()
	end)
end
