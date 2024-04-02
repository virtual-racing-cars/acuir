local car = ac.getCar()

local setupSpinnersWindowSize = vec2(500 * UI_SCALE_X / 100, 605 * UI_SCALE_Y / 100)
local setupSpinnersWindowHeaderSize = vec2(830 * UI_SCALE_X / 100, 50 * UI_SCALE_Y / 100)

local textBoxSize = vec2(300, 18)
local textBoxFont = 15 * UI_SCALE_Y / 100

local carINI = ac.INIConfig.carData(0, "car.ini")
local kgPerL = carINI:get("FUEL_EXT", "KG_PER_LITER", 0.7339)

local infoText = {
	function()
		return 1, 1, "Camber: ", math.round(car.wheels[0].camber, 2)
	end,
	function()
		return 1, 2, "Caster: ", math.round(car.caster, 2)
	end,
	function()
		return 1, 3, "Toe: ", math.round(car.wheels[0].toeIn, 2)
	end,
	function()
		return 1, 4, "Pressure (cold): ", math.round(car.wheels[0].tyreStaticPressure, 2) .. " psi"
	end,
	function()
		return 1, 5, "Pressure (hot): ", math.round(car.wheels[0].tyrePressure, 2) .. " psi"
	end,
	function()
		return 1, 6, "Temp: ", math.round(car.wheels[0].tyreCoreTemperature, 2) .. "°C"
	end,
	function()
		return 1, 8, "Camber: ", math.round(car.wheels[2].camber, 2)
	end,
	function()
		return 1, 9, "Toe: ", math.round(car.wheels[2].toeIn, 2)
	end,
	function()
		return 1, 10, "Pressure (cold): ", math.round(car.wheels[2].tyreStaticPressure, 2) .. " psi"
	end,
	function()
		return 1, 11, "Pressure (hot): ", math.round(car.wheels[2].tyrePressure, 2) .. " psi"
	end,
	function()
		return 1, 12, "Temp: ", math.round(car.wheels[2].tyreCoreTemperature, 2) .. "°C"
	end,
	function()
		return 5.280, 1, "Camber: ", math.round(car.wheels[1].camber, 2)
	end,
	function()
		return 5.280, 2, "Caster: ", math.round(car.caster, 2)
	end,
	function()
		return 5.280, 3, "Toe: ", -math.round(car.wheels[1].toeIn, 2)
	end,
	function()
		return 5.280, 4, "Pressure (cold): ", math.round(car.wheels[1].tyreStaticPressure, 2) .. " psi"
	end,
	function()
		return 5.280, 5, "Pressure (hot): ", math.round(car.wheels[1].tyrePressure, 2) .. " psi"
	end,
	function()
		return 5.280, 6, "Temp: ", math.round(car.wheels[1].tyreCoreTemperature, 2) .. "°C"
	end,
	function()
		return 5.280, 8, "Camber: ", math.round(car.wheels[3].camber, 2)
	end,
	function()
		return 5.280, 9, "Toe: ", -math.round(car.wheels[3].toeIn, 2)
	end,
	function()
		return 5.280, 10, "Pressure (cold): ", math.round(car.wheels[3].tyreStaticPressure, 2) .. " psi"
	end,
	function()
		return 5.280, 11, "Pressure (hot): ", math.round(car.wheels[3].tyrePressure, 2) .. " psi"
	end,
	function()
		return 5.280, 12, "Temp: ", math.round(car.wheels[3].tyreCoreTemperature, 2) .. "°C"
	end,

	function()
		return 3.2, 2, "Front Height: ", math.round(car.rideHeight[0] * 1000, 1) .. " mm"
	end,
	function()
		return 3.2, 3, "Rear Height: ", math.round(car.rideHeight[1] * 1000, 1) .. " mm"
	end,
	function()
		return 3.2, 5, "Plank Wear: ", math.round(car.maxRelativePlankWear * 1000, 2) .. " mm"
	end,
	function()
		return 3.2, 7, "CoG Height: ", math.round(car.cgHeight, 3)
	end,
	function()
		return 3.2,
			8,
			"Weight Balance F: ",
			math.round(
				(car.wheels[0].load + car.wheels[1].load)
					/ (car.wheels[0].load + car.wheels[1].load + car.wheels[2].load + car.wheels[3].load)
					* 100,
				1
			) .. "%"
	end,
	function()
		return 3.2, 10, "Mass: ", math.round(car.mass + (car.fuel * kgPerL) + car.ballast, 2) .. " kg"
	end,
	function()
		return 3.2, 11, "(", math.round(car.fuel * kgPerL, 2) .. " kg from fuel)"
	end,
	function()
		return 3.2, 12, "(", math.round(car.ballast, 2) .. " kg from ballast)"
	end,
}

function CarStatusWindow()
	setCursorX(1209)
	setCursorY(15)
	childWindow(
		"setup_info_window",
		setupSpinnersWindowSize,
		false,
		ui.WindowFlags.NoScrollWithMouse + ui.WindowFlags.NoScrollbar,
		function()
			ui.pushFont(ui.Font.Main)
			ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.uiPrimaryColor, 0, ui.CornerFlags.None)
			ui.drawRect(vec2(0, 0), ui.availableSpace(), rgbm(1, 1, 1, 0.25), 0, ui.CornerFlags.None)

			ui.drawRectFilled(
				vec2(0, 0),
				setupSpinnersWindowHeaderSize,
				rgbm(0.1, 0.1, 0.1, 0.5),
				0,
				ui.CornerFlags.None
			)

			ui.dwriteTextAligned(
				"Car Status",
				35 * UI_SCALE_Y / 100,
				ui.Alignment.Center,
				ui.Alignment.Start,
				ui.availableSpace(),
				false,
				rgbm.colors.white
			)

			for k, v in ipairs(infoText) do
				local column, position, label, value, font = v()

				if not font then
					font = "Default"
				end
				ui.pushDWriteFont("font")

				setCursorY(40 + (20 * position))
				setCursorX(-140 + 150 * column)

				ui.dwriteTextAligned(
					label .. value,
					textBoxFont,
					ui.Alignment.Start,
					ui.Alignment.Start,
					vec2(200, 22),
					false,
					rgbm.colors.white
				)
				ui.popDWriteFont()
			end

			ui.popFont()
		end
	)
end
