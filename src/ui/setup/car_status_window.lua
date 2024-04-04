local car = ac.getCar(0)

local setupSpinnersWindowSize = vec2(570 * UI_SCALE_X / 100, 730 * UI_SCALE_Y / 100)
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
		return 1, 4, "Travel: ", math.round(car.wheels[0].suspensionTravel * 1000, 2) .. " mm"
	end,
	function()
		return 1, 5, "Load: ", math.round(car.wheels[0].load, 0) .. " N"
	end,
	function()
		return 1, 6, "Pressure: ", math.round(car.wheels[0].tyreStaticPressure, 2) .. " psi"
	end,
	function()
		return 1, 7, "Pressure (hot): ", math.round(car.wheels[0].tyrePressure, 2) .. " psi"
	end,
	function()
		return 1, 8, "Core Temp: ", math.round(car.wheels[0].tyreCoreTemperature, 2) .. "°C"
	end,
	function()
		return 1, 21, "Camber: ", math.round(car.wheels[2].camber, 2)
	end,
	function()
		return 1, 22, "Toe: ", math.round(car.wheels[2].toeIn, 2)
	end,
	function()
		return 1, 23, "Travel: ", math.round(car.wheels[2].suspensionTravel * 1000, 2) .. " mm"
	end,
	function()
		return 1, 24, "Load: ", math.round(car.wheels[2].load, 0) .. " N"
	end,
	function()
		return 1, 25, "Pressure (cold): ", math.round(car.wheels[2].tyreStaticPressure, 2) .. " psi"
	end,
	function()
		return 1, 26, "Pressure (hot): ", math.round(car.wheels[2].tyrePressure, 2) .. " psi"
	end,
	function()
		return 1, 27, "Core Temp: ", math.round(car.wheels[2].tyreCoreTemperature, 2) .. "°C"
	end,
	function()
		return 3, 1, "Camber: ", math.round(car.wheels[1].camber, 2)
	end,
	function()
		return 3, 2, "Caster: ", math.round(car.caster, 2)
	end,
	function()
		return 3, 3, "Toe: ", -math.round(car.wheels[1].toeIn, 2)
	end,
	function()
		return 3, 4, "Travel: ", math.round(car.wheels[1].suspensionTravel * 1000, 2) .. " mm"
	end,
	function()
		return 3, 5, "Load: ", math.round(car.wheels[1].load, 0) .. " N"
	end,
	function()
		return 3, 6, "Pressure (cold): ", math.round(car.wheels[1].tyreStaticPressure, 2) .. " psi"
	end,
	function()
		return 3, 7, "Pressure (hot): ", math.round(car.wheels[1].tyrePressure, 2) .. " psi"
	end,
	function()
		return 3, 8, "Core Temp: ", math.round(car.wheels[1].tyreCoreTemperature, 2) .. "°C"
	end,
	function()
		return 3, 21, "Camber: ", math.round(car.wheels[3].camber, 2)
	end,
	function()
		return 3, 22, "Toe: ", -math.round(car.wheels[3].toeIn, 2)
	end,
	function()
		return 3, 23, "Travel: ", math.round(car.wheels[3].suspensionTravel * 1000, 2) .. " mm"
	end,
	function()
		return 3, 24, "Load: ", math.round(car.wheels[3].load, 0) .. " N"
	end,
	function()
		return 3, 25, "Pressure (cold): ", math.round(car.wheels[3].tyreStaticPressure, 2) .. " psi"
	end,
	function()
		return 3, 26, "Pressure (hot): ", math.round(car.wheels[3].tyrePressure, 2) .. " psi"
	end,
	function()
		return 3, 27, "Core Temp: ", math.round(car.wheels[3].tyreCoreTemperature, 2) .. "°C"
	end,

	function()
		return 1.8, 10, "Front Height: ", "~" .. math.round(car.rideHeight[0] * 1000, 1) .. " mm"
	end,

	function()
		return 1.8, 12, "CoG Height: ", math.round(car.cgHeight, 3)
	end,
	function()
		return 1.8,
			13,
			"WB Front: ",
			math.round(
				(car.wheels[0].load + car.wheels[1].load)
					/ (car.wheels[0].load + car.wheels[1].load + car.wheels[2].load + car.wheels[3].load)
					* 100,
				1
			) .. "%"
	end,
	function()
		return 1.8, 14, "Mass: ", math.round(car.mass + (car.fuel * kgPerL) + car.ballast, 2) .. " kg"
	end,
	function()
		return 1.8, 15, "", "(" .. math.round(car.fuel * kgPerL, 2) .. " kg from fuel)"
	end,
	function()
		return 1.8, 16, "", "(" .. math.round(car.ballast, 2) .. " kg from ballast)"
	end,
	function()
		return 1.8, 17, "Plank Wear: ", "~" .. math.round(car.maxRelativePlankWear * 1000, 1) .. " mm"
	end,
	function()
		return 1.8, 19, "Rear Height: ", "~" .. math.round(car.rideHeight[1] * 1000, 1) .. " mm"
	end,
}

function CarStatusWindow()
	setCursorX(1665)
	setCursorY(0)
	contentWindow(
		"setup_info_window",
		"CAR STATUS",
		setupSpinnersWindowSize,
		ui.WindowFlags.NoScrollWithMouse + ui.WindowFlags.NoScrollbar,
		function()
			for k, v in ipairs(infoText) do
				local column, position, label, value = v()

				setCursorY(40 + (24 * position))

				local x = -140 + 150 * column

				setCursorX(-130 + 150 * column)

				ui.text(label)

				setCursorY(40 + (24 * position))
				setCursorX(x + 164)

				ui.text(value)
			end
		end
	)
end
