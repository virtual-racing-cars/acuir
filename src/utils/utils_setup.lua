local car = ac.getCar(0)

setupSpinners = {}

local electronicsSetupItems = {
	"MGUK_DELIVERY",
	"MGUK_RECOVERY",
	"MGUH_MODE",
}

function loadSetupSpinners()
	for i in ipairs(setupSpinners) do
		setupSpinners[i] = nil
	end

	local compoundCount = 1

	for k, v in pairs(ac.getSetupSpinners()) do
		if v.name == "COMPOUND" then
			compoundCount = #v.items
		end

		local id = v["name"]

		local ext = setupINI:get(id, "EXT_CONTROLLER", "")

		if id == "" and ext ~= "" then
			return
		end

		local tab = setupINI:get(id, "TAB", "")
		local name = v["label"]
		local min = v["min"]
		local max = v["max"]
		local step = v["step"]
		local multiplier = v["displayMultiplier"] or 1
		local units = v["units"] or ""

		local lut = setupINI:get(id, "LUT", "")
		local format = name .. (multiplier == 1 and ": %.0f " or ": %.1f ") .. (units == "%" and "%%" or units)

		if lut ~= "" then
			local lutFile = ac.DataLUT11.carData(0, lut)
			local minimumBounds, maximumBounds = lutFile:bounds()

			min = 0
			max = #lutFile - 1
			step = 1

			-- format = name .. ": " .. lutFile:get(ac.getSetupSpinnerValue(id, 0))
		end

		local xPos = setupINI:get(id, "POS_X", 0.5)
		local yPos = setupINI:get(id, "POS_Y", 0.18)

		table.findFirst(electronicsSetupItems, function(item, index, callbackData)
			if id == item then
				tab = "ELECTRONICS"
				yPos = index
			end
		end)

		table.insert(
			setupSpinners,
			SPINNER(
				id,
				tab,
				name,
				min,
				max,
				step,
				multiplier,
				format,
				xPos,
				yPos,
				ac.checksumXXH(stringify({ tab, xPos, yPos }))
			)
		)
	end

	table.insert(
		setupSpinners,
		SPINNER("FUEL", "FUEL", "FUEL", 0, car.maxFuel, 1, 1, "FUEL" .. ": %.0f " .. "L", 0.5, 0)
	)

	table.insert(
		setupSpinners,
		SPINNER(
			"COMPOUND",
			"TYRES",
			"COMPOUND",
			0,
			compoundCount - 1,
			1,
			1,
			ac.getTyresLongName(0, car.compoundIndex),
			0.5,
			0
		)
	)

	for _cK, childV in pairs(setupSpinners) do
		if childV.name == "" or childV.name == "MGUK-Delivery" then
			for _pK, parentV in pairs(setupSpinners) do
				if parentV.uid == childV.uid then
					table.insert(parentV.idPairs, childV.id)
				end
			end
		end
	end
end
