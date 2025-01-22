local sim = ac.getSim()

local setupsDir = ac.getFolder(ac.FolderID.UserSetups) .. "\\" .. ac.getCarID(0)

local refreshingSetups = false

local savedSetups = {}
local selectedSetup = { name = "", track = "", path = "", description = "", tags = "", creation = "" }
local saveSetup = { name = "", track = ac.getTrackID(), path = "", description = "", tags = "", creation = "" }
local loadedSetup = "generic - default"

local function loadSetups()
	refreshingSetups = true

	for track, _ in pairs(savedSetups) do
		for i in ipairs(savedSetups[track]) do
			savedSetups[track][i] = nil
		end
		savedSetups[track] = nil
	end

	io.scanDir(setupsDir, function(dirName)
		if settings.hideOtherTrackSetups then
			if dirName ~= ac.getTrackID() and dirName ~= "generic" then
				return
			end
		end

		io.scanDir(setupsDir .. "\\" .. dirName, function(fileName, fileAttributes)
			if string.find(fileName, ".sp") or string.find(fileName, ".txt") then
				return
			end

			if savedSetups[dirName] == nil then
				savedSetups[dirName] = {}
			end

			local tags = ""
			local description = ""

			local extraInfoFilePath, _ =
				string.replace(setupsDir .. "\\" .. dirName .. "\\" .. fileName, ".ini", ".txt")

			if io.fileExists(extraInfoFilePath) then
				local extraInfoFile = io.open(extraInfoFilePath, "r")
				for line in extraInfoFile:lines() do
					if string.startsWith(line, "[") then
						tags = string.replace(line, "[TAGS]", "")
					else
						description = description .. line .. "\n"
					end
				end

				extraInfoFile:close()
			end

			table.insert(savedSetups[dirName], {
				name = fileName,
				track = dirName,
				path = setupsDir .. "\\" .. dirName .. "\\" .. fileName,
				description = description,
				tags = tags,
				creationTime = os.date(
					"%A, %B %d, %Y %H:%M:%S",
					tonumber(string.trim(tostring(fileAttributes.creationTime), "LL"))
				),
			})
		end)
	end)

	refreshingSetups = false
end

loadSetups()

local function savedSetupsWindow()
	childWindow("saved_setups", vec2(ui.windowWidth() / 2, ui.windowHeight()), false, ui.WindowFlags.None, function()
		setCursorX(10)
		childWindow("saved_setups", vec2(ui.windowWidth() - 10, ui.windowHeight()), false, function()
			if refreshingSetups then
				ui.icon(ui.Icons.LoadingSpinner, ui.availableSpace())
			else
				for track, setups in pairs(savedSetups) do
					ui.treeNode(track, function()
						for i in ipairs(setups) do
							local setup = setups[i]
							local setupButtonFlags = ui.ButtonFlags.None

							if selectedSetup.path == setup.path then
								setupButtonFlags = ui.ButtonFlags.Active
							end

							local name = string.replace(setup.name, ".ini", "")

							ui.pushStyleVar(ui.StyleVar.ItemSpacing, 3)
							ui.pushStyleVar(ui.StyleVar.FramePadding, -25)
							if ui.modernButtonAdvanced(name, vec2(ui.windowWidth() - 20, 30), setupButtonFlags) then
								selectedSetup = {
									name = name,
									track = track,
									path = setup.path,
									description = setup.description,
									tags = setup.tags,
									creation = setup.creationTime,
								}

								saveSetup = {
									name = name,
									track = track,
									path = setup.path,
									description = setup.description,
									tags = setup.tags,
									creation = setup.creationTime,
								}
							end

							ui.popStyleVar(2)
						end
					end)
				end
			end
		end)
	end)
end

local function saveSetupWindow()
	ui.textAligned("Save Current Setup", vec2(0.5, 0.5), vec2(ui.availableSpaceX(), 30))

	ui.text("Name:")
	ui.sameLine(60)
	ui.setNextItemWidth(ui.availableSpaceX())
	saveSetup.name = ui.inputText("##SetupName", saveSetup.name, ui.InputTextFlags.None)

	ui.text("Track:")
	ui.sameLine(60)
	ui.setNextItemWidth(ui.availableSpaceX())
	ui.combo("##setupcombo", saveSetup.track, ui.ComboFlags.None, function()
		ui.bringWindowToFront()

		if ui.selectable("generic") then
			saveSetup.track = "generic"
		end

		io.scanDir(setupsDir, function(dirName)
			if dirName == "generic" then
				return
			end

			if ui.selectable(dirName) then
				saveSetup.track = dirName
			end
		end)
	end)

	ui.text("Tags:")
	ui.sameLine(60)
	ui.setNextItemWidth(ui.availableSpaceX())
	saveSetup.tags = ui.inputText("##SetupTags", saveSetup.tags, ui.InputTextFlags.None)

	ui.text("Notes:")
	ui.sameLine(60)
	saveSetup.description = ui.inputText(
		"##SetupDesc",
		saveSetup.description,
		ui.InputTextFlags.NoHorizontalScroll,
		vec2(ui.availableSpaceX(), 250 * UI_SCALE_Y / 100)
	)
end

local bottomBarButtonsIO = {
	{
		label = "BACK",
		enabled = true,
		func = function()
			storage.setupTab = "Tyres"
		end,
	},
	{
		label = "Save",
		enabled = true,
		func = function()
			if saveSetup.name ~= "" then
				saveSetup.path = setupsDir .. "\\" .. saveSetup.track .. "\\" .. saveSetup.name .. ".ini"
				ac.setActiveSetupName(saveSetup.name, saveSetup.track)
				ac.saveCurrentSetup(saveSetup.path)
				ui.toast(ui.Icons.Save, "Setup Saved: " .. saveSetup.name)
				loadedSetup = saveSetup.track .. " - " .. saveSetup.name

				if saveSetup.description ~= "" or saveSetup.tags ~= "" then
					local descriptionFile =
						io.open(setupsDir .. "\\" .. saveSetup.track .. "\\" .. saveSetup.name .. ".txt", "w+")

					if saveSetup.tags ~= "" and saveSetup.tags ~= nil then
						descriptionFile:write("[TAGS]" .. saveSetup.tags .. "\n")
					end
					if saveSetup.description ~= "" and saveSetup.description ~= nil then
						descriptionFile:write(saveSetup.description)
					end

					descriptionFile:close()
				end

				selectedSetup = table.clone(saveSetup, true)

				loadSetups()
			end
		end,
	},
	{
		label = "Load",
		enabled = true,
		func = function()
			ac.loadSetup(selectedSetup.path)
			loadedSetup = selectedSetup.track .. " - " .. selectedSetup.name
			ui.toast(ui.Icons.Download, "Setup loaded: " .. selectedSetup.name)
		end,
	},
	{
		label = "Compare",
		enabled = false,
		func = function() end,
	},

	{
		label = "Delete",
		enabled = true,
		func = function()
			io.deleteFile(saveSetup.path)
			io.deleteFile(string.trim(saveSetup.path, ".ini") .. ".sp")

			ui.toast(ui.Icons.Download, "Setup deleted: " .. saveSetup.name)

			saveSetup.name = ""
			saveSetup.path = ""
			saveSetup.tags = ""
			saveSetup.description = ""

			loadSetups()
		end,
	},
}

function ioTab()
	setCursorY(50)
	setCursorX(10)

	contentWindow(
		"car_setup_window",
		storage.setupTab,
		vec2(sim.windowWidth / 4, 140),
		vec2(sim.windowWidth / 2, sim.windowHeight - 283),
		ui.WindowFlags.None,
		function()
			ui.drawRectFilled(
				vec2(0, 0),
				vec2(ui.windowWidth(), ui.windowHeight()),
				settings.uiColor1 / 2,
				0,
				ui.CornerFlags.None
			)

			if ui.checkbox("Hide other track setups", settings.hideOtherTrackSetups) then
				settings.hideOtherTrackSetups = not settings.hideOtherTrackSetups
				loadSetups()
			end

			ui.setCursorY(0)
			ui.textAligned("Current Setup [" .. loadedSetup .. "]", vec2(0.5, 0.5), vec2(ui.availableSpaceX(), 30))

			savedSetupsWindow()

			contentWindow(
				"saved_setups",
				"saved_setups",
				vec2(ui.windowWidth() / 2, 0),
				vec2(ui.windowWidth() / 2, ui.windowHeight()),
				ui.WindowFlags.None,
				function()
					saveSetupWindow()
				end
			)
		end
	)

	bottomBar(bottomBarButtonsIO)
end
