local car = ac.getCar(0)
local cphys = ac.getCarPhysics(0)

function gearWindow()
	cui.setCursorX(0)
	cui.setCursorY(50)

	ui.dwriteTextAligned(
		"Max Gear Speeds",
		20 * cui.scaleY(),
		ui.Alignment.Center,
		ui.Alignment.Center,
		vec2(790, 150) * cui.scaleY()
	)

	for i = 0, car.gearCount - 1 do
		cui.setCursorX(0)
		local maxGearSpeed = math.round(
			(math.pi * car.wheels[2].tyreRadius * 2 * (car.rpmLimiter - 0))
				/ (60 * cphys.gearRatios[i + 2] * cphys.finalRatio)
				* 3.6
		)
		ui.dwriteTextAligned(
			string.format("Gear %s: %s KMH", i + 1, maxGearSpeed),
			20 * cui.scaleY(),
			ui.Alignment.Center,
			ui.Alignment.Center,
			vec2(790, 50) * cui.scaleY()
		)
	end
end
