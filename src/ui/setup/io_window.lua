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
	childWindow("saved_setups", vec2(ui.availableSpaceX(), ui.availableSpaceY()), false, ui.WindowFlags.None, function()
		setCursorX(10)
		childWindow("saved_setups", vec2(ui.availableSpaceX() - 10, ui.availableSpaceY()), false, function()
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
							if
								ui.modernButtonAdvanced(
									name,
									vec2(ui.availableSpaceX() - 20, 30 * UI_SCALE_Y / 100),
									setupButtonFlags
								)
							then
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
	local availableSpaceY = ui.availableSpaceY()

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

	local availableSpaceX = (ui.availableSpaceX() - 30 * UI_SCALE_X / 100) / 5

	setCursorY(580)

	if
		ui.modernButtonAdvanced(
			"##loadsetup",
			vec2(availableSpaceX, availableSpaceX),
			ui.ButtonFlags.None,
			ui.Icons.Download
		)
	then
		ac.loadSetup(selectedSetup.path)
		loadedSetup = selectedSetup.track .. " - " .. selectedSetup.name

		ui.toast(ui.Icons.Download, "Setup loaded: " .. selectedSetup.name)
	end

	ui.sameLine()
	if
		ui.modernButtonAdvanced(
			"##comparesetup",
			vec2(availableSpaceX, availableSpaceX),
			ui.ButtonFlags.None,
			ui.Icons.Contrast
		)
	then
		ac.resetSetupToDefault()
	end

	ui.sameLine()
	if
		ui.modernButtonAdvanced(
			"##resetsetup",
			vec2(availableSpaceX, availableSpaceX),
			ui.ButtonFlags.None,
			ui.Icons.Restart
		)
	then
		ac.resetSetupToDefault()
	end

	ui.sameLine()
	if
		ui.modernButtonAdvanced(
			"##deletesetup",
			vec2(availableSpaceX, availableSpaceX),
			ui.ButtonFlags.None,
			ui.Icons.Delete
		)
	then
		io.deleteFile(saveSetup.path)
		io.deleteFile(string.trim(saveSetup.path, ".ini") .. ".sp")

		ui.toast(ui.Icons.Download, "Setup deleted: " .. saveSetup.name)

		saveSetup.name = ""
		saveSetup.path = ""
		saveSetup.tags = ""
		saveSetup.description = ""

		loadSetups()
	end

	ui.sameLine()
	if
		ui.modernButtonAdvanced(
			"##savesetup",
			vec2(availableSpaceX, availableSpaceX),
			ui.ButtonFlags.None,
			ui.Icons.Save
		)
	then
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
	end
end

function ioTab()
	setCursorY(50)
	setCursorX(10)

	childWindow(
		"setup_io",
		vec2(ui.availableSpaceX() / 2 - 2.5, ui.availableSpaceY() - 10),
		false,
		ui.WindowFlags.None,
		function()
			ui.drawRectFilled(
				vec2(0, 0),
				vec2(ui.availableSpaceX(), ui.availableSpaceY()),
				settings.uiPrimaryColor / 2,
				0,
				ui.CornerFlags.None
			)
			ui.drawRect(
				vec2(0, 0),
				vec2(ui.availableSpaceX(), ui.availableSpaceY()),
				rgbm(1, 1, 1, 0.25),
				0,
				ui.CornerFlags.None
			)

			setCursorY(0)

			ui.textAligned("Current Setup [" .. loadedSetup .. "]", vec2(0.5, 0.5), vec2(ui.availableSpaceX(), 30))

			savedSetupsWindow()
		end
	)

	cui.setCursorX(0)
	cui.setCursorY(50)
	cui.setCursorX(410)

	ui.beginGroup(370 * cui.scaleY())

	saveSetupWindow()

	ui.endGroup()
end
