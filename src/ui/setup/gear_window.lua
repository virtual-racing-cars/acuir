local settings = require("settings")
local cui = require("ui.cui")
local car = ac.getCar(0)
local cphys = ac.getCarPhysics(0)

local function getGearMaxSpeedKmh(gear)
	if ac.getCarMaxSpeedWithGear then
		return math.round(math.max(ac.getCarMaxSpeedWithGear(0, gear), 0))
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

local maxSpeedWithGear = {
	[0] = 0,
}

local maxSpeed = nil

function gearWindow(spinnerCount)
	local yMin = ui.windowHeight() / 5
	local yMax = ui.windowHeight() - yMin

	local xMin = ui.windowWidth() / 2 / 8
	local xMax = ui.windowWidth() / 2 + xMin / 2
	local width = xMax - xMin

	if spinnerCount <= 0 then
		xMin = ui.windowWidth() / 2 - width / 2
		xMax = ui.windowWidth() / 2 + width / 2
		ui.setCursor(vec2(ui.windowWidth() / 2 - width / 2, yMin * 0.7))
	else
		ui.setCursor(vec2(xMin, yMin * 0.7))
	end

	ui.dwriteTextAligned(
		"Max Gear Speeds KMH",
		30 * cui.scaleY(),
		ui.Alignment.Center,
		ui.Alignment.Start,
		vec2(width, yMin)
	)

	if not maxSpeed or maxSpeed == 0 then
		maxSpeed = getGearMaxSpeedKmh(car.gearCount) * 1.25
	end

	for i = 0, 10 do
		ui.setCursor(vec2(xMin + width / 10 * i - 32, yMax + 10))
		ui.dwriteTextAligned(
			math.round(i / 10 * maxSpeed),
			18 * cui.scaleY(),
			ui.Alignment.Center,
			ui.Alignment.Center,
			vec2(65, 20) * cui.scaleY()
		)
		ui.pathLineTo(vec2(xMin + width / 10 * i, yMin))
		ui.pathLineTo(vec2(xMin + width / 10 * i, yMax))
		ui.pathStroke(rgbm(1, 1, 1, 0.3), false, 3)

		ui.setCursor(vec2(xMin - 70, yMin + (yMax - yMin) / 10 * i) - 10)
		ui.dwriteTextAligned(
			math.round(car.rpmLimiter - (car.rpmLimiter / 10) * i),
			18 * cui.scaleY(),
			ui.Alignment.End,
			ui.Alignment.Center,
			vec2(65, 20) * cui.scaleY()
		)

		ui.pathLineTo(vec2(xMin, yMin + (yMax - yMin) / 10 * i))
		ui.pathLineTo(vec2(xMin + width, yMin + (yMax - yMin) / 10 * i))
		ui.pathStroke(rgbm(1, 1, 1, 0.3), false, 3)
	end

	for i = 1, car.gearCount do
		local maxGearSpeed = getGearMaxSpeedKmh(i)

		if maxGearSpeed > 0 then
			maxSpeedWithGear[i] = maxGearSpeed
		else
			maxGearSpeed = maxSpeedWithGear[i]
		end

		ac.debug(i, maxGearSpeed)

		local prevGearSpeed = maxSpeedWithGear[i - 1]

		local x1 = xMin + width * (prevGearSpeed / maxSpeed)
		local p1 = vec2(x1, math.max(yMin + (yMax - yMin) * (1 - (prevGearSpeed / maxGearSpeed)), yMin))
		local p2 = vec2(math.max(xMin + width * (maxGearSpeed / maxSpeed), x1), yMin)

		ui.pathLineTo(p1)
		ui.pathLineTo(p2)
		ui.pathStroke(settings.Appearance.uiColor2, false, 5)

		ui.setCursor(p1:setLerp(p1, p2, 0.5))
		ui.dwriteTextAligned(i, 18 * cui.scaleY(), ui.Alignment.Center, ui.Alignment.Start, vec2(15, 20) * cui.scaleY())

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
