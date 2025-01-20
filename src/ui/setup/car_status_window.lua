local car = ac.getCar(0)

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
		return 1, 25, "Camber: ", math.round(car.wheels[2].camber, 2)
	end,
	function()
		return 1, 26, "Toe: ", math.round(car.wheels[2].toeIn, 2)
	end,
	function()
		return 1, 27, "Travel: ", math.round(car.wheels[2].suspensionTravel * 1000, 2) .. " mm"
	end,
	function()
		return 1, 28, "Load: ", math.round(car.wheels[2].load, 0) .. " N"
	end,
	function()
		return 1, 29, "Pressure (cold): ", math.round(car.wheels[2].tyreStaticPressure, 2) .. " psi"
	end,
	function()
		return 1, 30, "Pressure (hot): ", math.round(car.wheels[2].tyrePressure, 2) .. " psi"
	end,
	function()
		return 1, 31, "Core Temp: ", math.round(car.wheels[2].tyreCoreTemperature, 2) .. "°C"
	end,
	function()
		return 2.95, 1, "Camber: ", math.round(car.wheels[1].camber, 2)
	end,
	function()
		return 2.95, 2, "Caster: ", math.round(car.caster, 2)
	end,
	function()
		return 2.95, 3, "Toe: ", -math.round(car.wheels[1].toeIn, 2)
	end,
	function()
		return 2.95, 4, "Travel: ", math.round(car.wheels[1].suspensionTravel * 1000, 2) .. " mm"
	end,
	function()
		return 2.95, 5, "Load: ", math.round(car.wheels[1].load, 0) .. " N"
	end,
	function()
		return 2.95, 6, "Pressure (cold): ", math.round(car.wheels[1].tyreStaticPressure, 2) .. " psi"
	end,
	function()
		return 2.95, 7, "Pressure (hot): ", math.round(car.wheels[1].tyrePressure, 2) .. " psi"
	end,
	function()
		return 2.95, 8, "Core Temp: ", math.round(car.wheels[1].tyreCoreTemperature, 2) .. "°C"
	end,
	function()
		return 2.95, 25, "Camber: ", math.round(car.wheels[3].camber, 2)
	end,
	function()
		return 2.95, 26, "Toe: ", -math.round(car.wheels[3].toeIn, 2)
	end,
	function()
		return 2.95, 27, "Travel: ", math.round(car.wheels[3].suspensionTravel * 1000, 2) .. " mm"
	end,
	function()
		return 2.95, 28, "Load: ", math.round(car.wheels[3].load, 0) .. " N"
	end,
	function()
		return 2.95, 29, "Pressure (cold): ", math.round(car.wheels[3].tyreStaticPressure, 2) .. " psi"
	end,
	function()
		return 2.95, 30, "Pressure (hot): ", math.round(car.wheels[3].tyrePressure, 2) .. " psi"
	end,
	function()
		return 2.95, 31, "Core Temp: ", math.round(car.wheels[3].tyreCoreTemperature, 2) .. "°C"
	end,

	function()
		return 1.8, 11, "Front Height: ", "~" .. math.round(car.rideHeight[0] * 1000, 1) .. " mm"
	end,

	function()
		return 1.8, 13, "CoG Height: ", math.round(car.cgHeight, 3)
	end,
	function()
		return 1.8,
			14,
			"WB Front: ",
			math.round(
				(car.wheels[0].load + car.wheels[1].load)
					/ (car.wheels[0].load + car.wheels[1].load + car.wheels[2].load + car.wheels[3].load)
					* 100,
				2
			) .. "%"
	end,
	function()
		return 1.8, 16, "Mass: ", math.round(car.mass + (car.fuel * kgPerL) + car.ballast, 2) .. " kg"
	end,
	function()
		return 1.8, 17, "", "(" .. math.round(car.fuel * kgPerL, 2) .. " kg from fuel)"
	end,
	function()
		return 1.8, 18, "", "(" .. math.round(car.ballast, 2) .. " kg from ballast)"
	end,
	function()
		return 1.8, 20, "Plank Wear: ", "~" .. math.round(car.maxRelativePlankWear * 1000, 1) .. " mm"
	end,
	function()
		return 1.8, 22, "Rear Height: ", "~" .. math.round(car.rideHeight[1] * 1000, 1) .. " mm"
	end,
}

local sim = ac.getSim()

function CarStatusWindow()
	for _, v in ipairs(infoText) do
		local column, position, label, value = v()
		ui.setCursorX(-130 + 150 * column)
		ui.setCursorY(80 + (24 * position))
		ui.dwriteText(label, 22)

		local x = -170 + 150 * column
		ui.setCursorX(x + 230)
		ui.setCursorY(80 + (24 * position))
		ui.dwriteText(value, 22)
	end
end
