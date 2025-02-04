local cui = require("ui.cui")

local car = ac.getCar(0)
local cphys = ac.getCarPhysics(0)

local function getGearMaxSpeedKmh(gear)
	if ac.getCarMaxSpeedWithGear then
		return math.round(ac.getCarMaxSpeedWithGear(0, gear), 1)
	end

	if not cphys.gearRatio then
		return 0
	end

	return math.round(
		(math.pi * car.wheels[2].tyreRadius * 2 * (car.rpmLimiter - 0))
			/ (60 * cphys.gearRatios[gear + 1] * cphys.finalRatio)
			* 3.6
	)
end

local maxSpeed = nil

for i = -1, car.gearCount + 3 do
	ac.debug(i, math.round(ac.getCarMaxSpeedWithGear(0, i), 1))
end

function gearWindow(spinnerCount)
	local yMin = ui.windowHeight() / 4
	local yMax = ui.windowHeight() - yMin

	local xMin = ui.windowWidth() / 2 / 8
	local xMax = ui.windowWidth() / 2 - xMin

	local xPos = xMin
	local yPos = 0

	spinnerCount = 0

	-- if spinnerCount <= 0 then
	-- 	xMin = ui.windowWidth() / 2 - ui.windowWidth() / 4
	-- 	xMax = ui.windowWidth() / 2 - xMin
	-- 	xPos = ui.windowWidth() / 2 - (xMax - xMin) / 2
	-- 	ui.setCursor(vec2(xPos, yMin / 2))
	-- end

	ui.setCursor(vec2(xPos, yMin / 2))

	ui.dwriteTextAligned(
		"Max Gear Speeds KMH",
		50 * cui.scaleY(),
		ui.Alignment.Center,
		ui.Alignment.Start,
		vec2(xMax, yMin)
	)

	if not maxSpeed or maxSpeed == 0 then
		maxSpeed = getGearMaxSpeedKmh(car.gearCount) * 1.25
	end

	for i = 0, 10 do
		ui.dwriteDrawText(math.round(i / 10 * maxSpeed), 14 * cui.scaleY(), vec2(xMin + xMax / 10 * i, yMax))
		ui.pathLineTo(vec2(xMin + xMax / 10 * i, yMin))
		ui.pathLineTo(vec2(xMin + xMax / 10 * i, yMax))
		ui.pathStroke(rgbm(1, 1, 1, 0.3), false, 2)

		ui.dwriteDrawText(
			math.round(car.rpmLimiter - (car.rpmLimiter / 10) * i),
			14 * cui.scaleY(),
			vec2(xMin, yMin + (yMax - yMin) / 10 * i)
		)
		ui.pathLineTo(vec2(xMin, yMin + (yMax - yMin) / 10 * i))
		ui.pathLineTo(vec2(xMin + xMax, yMin + (yMax - yMin) / 10 * i))
		ui.pathStroke(rgbm(1, 1, 1, 0.3), false, 2)
	end

	local prevGearSpeed = 0
	for i = 1, car.gearCount do
		local maxGearSpeed = getGearMaxSpeedKmh(i)

		-- ac.debug(i, maxGearSpeed)

		local x1 = xMin + xMax * (prevGearSpeed / maxSpeed)
		local p1 = vec2(x1, math.max(yMin + (yMax - yMin) * (1 - (prevGearSpeed / maxGearSpeed)), yMin))
		local p2 = vec2(math.max(xMin + xMax * (maxGearSpeed / maxSpeed), x1), yMin)

		ui.pathLineTo(p1)
		ui.pathLineTo(p2)
		ui.pathStroke(rgbm.colors.red, false, 4)

		if maxGearSpeed > prevGearSpeed then
			ui.setCursor(p2 - vec2(20, 25) * cui.scaleY())
			ui.dwriteTextAligned(
				maxGearSpeed,
				18 * cui.scaleY(),
				ui.Alignment.Center,
				ui.Alignment.Start,
				vec2(40, 40) * cui.scaleY()
			)
		end

		prevGearSpeed = maxGearSpeed
	end
end
