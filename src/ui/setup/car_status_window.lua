local car = ac.getCar()

local setupSpinnersWindowSize = vec2(540 * UI_SCALE_X / 100, 660 * UI_SCALE_Y / 100)
local setupSpinnersWindowHeaderSize = vec2(830 * UI_SCALE_X / 100, 50 * UI_SCALE_Y / 100)

local textBoxSize = vec2(300, 18)
local textBoxFont = 20 * UI_SCALE_Y / 100
ac.log(textBoxFont)

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
		return 1, 6, "Core Temp: ", math.round(car.wheels[0].tyreCoreTemperature, 2) .. "°C"
	end,
	function()
		return 1, 22, "Camber: ", math.round(car.wheels[2].camber, 2)
	end,
	function()
		return 1, 23, "Toe: ", math.round(car.wheels[2].toeIn, 2)
	end,
	function()
		return 1, 24, "Pressure (cold): ", math.round(car.wheels[2].tyreStaticPressure, 2) .. " psi"
	end,
	function()
		return 1, 25, "Pressure (hot): ", math.round(car.wheels[2].tyrePressure, 2) .. " psi"
	end,
	function()
		return 1, 26, "Core Temp: ", math.round(car.wheels[2].tyreCoreTemperature, 2) .. "°C"
	end,
	function()
		return 2.8, 1, "Camber: ", math.round(car.wheels[1].camber, 2)
	end,
	function()
		return 2.8, 2, "Caster: ", math.round(car.caster, 2)
	end,
	function()
		return 2.8, 3, "Toe: ", -math.round(car.wheels[1].toeIn, 2)
	end,
	function()
		return 2.8, 4, "Pressure (cold): ", math.round(car.wheels[1].tyreStaticPressure, 2) .. " psi"
	end,
	function()
		return 2.8, 5, "Pressure (hot): ", math.round(car.wheels[1].tyrePressure, 2) .. " psi"
	end,
	function()
		return 2.8, 6, "Core Temp: ", math.round(car.wheels[1].tyreCoreTemperature, 2) .. "°C"
	end,
	function()
		return 2.8, 22, "Camber: ", math.round(car.wheels[3].camber, 2)
	end,
	function()
		return 2.8, 23, "Toe: ", -math.round(car.wheels[3].toeIn, 2)
	end,
	function()
		return 2.8, 24, "Pressure (cold): ", math.round(car.wheels[3].tyreStaticPressure, 2) .. " psi"
	end,
	function()
		return 2.8, 25, "Pressure (hot): ", math.round(car.wheels[3].tyrePressure, 2) .. " psi"
	end,
	function()
		return 2.8, 26, "Core Temp: ", math.round(car.wheels[3].tyreCoreTemperature, 2) .. "°C"
	end,

	function()
		return 1.6, 9, "Front Height: ", "~" .. math.round(car.rideHeight[0] * 1000, 1) .. " mm"
	end,
	function()
		return 1.6, 11, "Rear Height: ", "~" .. math.round(car.rideHeight[1] * 1000, 1) .. " mm"
	end,
	function()
		return 1.6, 13, "CoG Height: ", math.round(car.cgHeight, 3)
	end,
	function()
		return 1.6,
			15,
			"WB Front: ",
			math.round(
				(car.wheels[0].load + car.wheels[1].load)
					/ (car.wheels[0].load + car.wheels[1].load + car.wheels[2].load + car.wheels[3].load)
					* 100,
				1
			) .. "%"
	end,
	function()
		return 1.6, 17, "Mass: ", math.round(car.mass + (car.fuel * kgPerL) + car.ballast, 2) .. " kg"
	end,
	function()
		return 1.6, 18, "", "(" .. math.round(car.fuel * kgPerL, 2) .. " kg from fuel)"
	end,
	function()
		return 1.6, 19, "", "(" .. math.round(car.ballast, 2) .. " kg from ballast)"
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
				local column, position, label, value = v()

				setCursorY(40 + (22 * position))

				local x = -110 + 150 * column

				setCursorX(-140 + 150 * column)

				ui.text(label)

				setCursorY(40 + (22 * position))
				setCursorX(x + 130)

				ui.text(value)
			end
		end
	)
end
