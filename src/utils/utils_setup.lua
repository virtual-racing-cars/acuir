setupSpinners = {}

local electronicsSetupItems = {
	"MGUK_DELIVERY",
	"MGUK_RECOVERY",
	"MGUH_MODE",
	"ABS",
	"TRACTION_CONTROL",
}

-- ac.log(ac.getSetupSpinners())

local populatedTabs = {}

local pairedItems = {}

function loadSetupSpinners()
	for i in ipairs(setupSpinners) do
		setupSpinners[i] = nil
	end

	for k, v in pairs(ac.getSetupSpinners()) do
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
		local format = name .. (multiplier == 1 and ": %.0f " or ": %.1f ") .. (units == "%" and "%%" or units)
		local items = v["items"] or {}
		local xPos = setupINI:get(id, "POS_X", 0.5)
		local yPos = setupINI:get(id, "POS_Y", 0)

		table.findFirst(electronicsSetupItems, function(item, index, callbackData)
			if id == item then
				tab = "ELECTRONICS"
				yPos = index - 1
			end
		end)

		if tab == "ELECTRONICS" then
			yPos = math.round(yPos)
		end

		if v.name == "COMPOUND" then
			tab = "TYRES"
			min = 0
			max = #items - 1
		end

		if v.name == "GEARSET" then
			name = "GEAR SETS"
			tab = "GEARS"
			min = 0
			max = #items - 1
		end

		if v.name == "FUEL" then
			tab = "FUEL"
		end

		if not table.contains(populatedTabs, tab) then
			table.insert(populatedTabs, tab)
		end

		local uid = bit.tohex(ac.checksumXXH(stringify({ tab, xPos, yPos })))

		table.insert(setupSpinners, SPINNER(id, tab, name, min, max, step, multiplier, items, format, xPos, yPos, uid))

		if not pairedItems[uid] then
			pairedItems[uid] = { id }
		else
			table.insert(pairedItems[uid], 1, id)
		end
	end

	for uid, uidPairs in pairs(pairedItems) do
		if #uidPairs > 1 then
			for _k, parent in pairs(setupSpinners) do
				if parent.uid == uid then
					if parent.id == uidPairs[1] then
						ac.log(parent.id)
						parent.idPairs = uidPairs
						ac.log(parent.idPairs)
					else
						parent.child = true
					end
				end
			end
		end
	end

	for k, v in pairs(tabs) do
		if not table.contains(populatedTabs, v) then
			table.removeItem(tabs, v)
		end
	end
end
