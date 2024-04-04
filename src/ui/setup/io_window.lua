local car = ac.getCar(0)

local setupsDir = ac.getFolder(ac.FolderID.UserSetups) .. "\\" .. ac.getCarID(0)

local refreshingSetups = false

local setups = {}
local selectedSetupPath = ""
local loadedSetup = "generic - default"
local selectedSetupName = ""
local selectedSetupDir = ""
local selectedSetupCreation = ""
local saveDir = "generic"
local saveName = ""
local saveDescription = ""

local function loadSetups()
	refreshingSetups = true

	for track, _ in pairs(setups) do
		for i in ipairs(setups[track]) do
			setups[track][i] = nil
		end
		setups[track] = nil
	end

	io.scanDir(setupsDir, function(dirName)
		if settings.hideOtherTrackSetups then
			if dirName ~= ac.getTrackID() and dirName ~= "generic" then
				return
			end
		end

		io.scanDir(setupsDir .. "\\" .. dirName, function(fileName, fileAttributes)
			if string.find(fileName, ".sp") then
				return
			end

			if setups[dirName] == nil then
				setups[dirName] = {}
			end

			table.insert(setups[dirName], {
				name = fileName,
				path = setupsDir .. "\\" .. dirName .. "\\" .. fileName,
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
	childWindow(
		"saved_setups",
		vec2(ui.availableSpaceX() / 2, ui.availableSpaceY()),
		false,
		ui.WindowFlags.None,
		function()
			setCursorX(10)
			childWindow("saved_setups", vec2(ui.availableSpaceX() - 10, ui.availableSpaceY()), false, function()
				ui.drawRectFilled(
					vec2(0, 0),
					vec2(ui.availableSpaceX(), ui.availableSpaceY() - 10),
					settings.uiPrimaryColor / 2,
					0,
					ui.CornerFlags.None
				)
				ui.drawRect(
					vec2(0, 0),
					vec2(ui.availableSpaceX(), ui.availableSpaceY() - 10),
					rgbm(1, 1, 1, 0.25),
					0,
					ui.CornerFlags.None
				)

				ui.textAligned("Saved Setups", vec2(0.5, 0.5), vec2(ui.availableSpaceX(), 22 * UI_SCALE_Y / 100))

				if refreshingSetups then
					ui.icon(ui.Icons.LoadingSpinner, ui.availableSpace())
				else
					for track, trackSetups in pairs(setups) do
						ui.treeNode(track, function()
							for i in ipairs(trackSetups) do
								local setup = trackSetups[i]
								local setupButtonFlags = ui.ButtonFlags.None

								if selectedSetupPath == setup.path then
									setupButtonFlags = ui.ButtonFlags.Active
								end

								local setupName = string.replace(setup.name, ".ini", "")

								ui.pushStyleVar(ui.StyleVar.ItemSpacing, 3)
								ui.pushStyleVar(ui.StyleVar.FramePadding, -25)
								if
									ui.modernButtonAdvanced(
										setupName,
										vec2(ui.availableSpaceX() - 20, 30 * UI_SCALE_Y / 100),
										setupButtonFlags
									)
								then
									selectedSetupPath = setup.path
									selectedSetupCreation = setup.creationTime
									saveName = setupName
									saveDir = track

									selectedSetupName = setupName
									selectedSetupDir = track
								end

								ui.popStyleVar(2)
							end
						end)
					end
				end
			end)
		end
	)
end

local function loadSetupInfoWindow()
	setCursorX(ui.availableSpaceX() / 2)
	ui.sameLine()

	childWindow(
		"load_setup",
		vec2(ui.availableSpaceX() - 10, ui.availableSpaceY()),
		false,
		ui.WindowFlags.None,
		function()
			ui.drawRectFilled(
				vec2(0, 0),
				vec2(ui.availableSpaceX(), ui.availableSpaceY() - 10),
				settings.uiPrimaryColor / 2,
				0,
				ui.CornerFlags.None
			)
			ui.drawRect(
				vec2(0, 0),
				vec2(ui.availableSpaceX(), ui.availableSpaceY() - 10),
				rgbm(1, 1, 1, 0.25),
				0,
				ui.CornerFlags.None
			)

			ui.textAligned("Selected Setup", vec2(0.5, 0.5), vec2(ui.availableSpaceX(), 22))

			if selectedSetupName ~= "" then
				setCursorX(10)
				ui.pushDWriteFont("Default;Weight=Bold")

				ui.dwriteText(selectedSetupDir .. " - " .. selectedSetupName, 20 * UI_SCALE_Y / 100)
				ui.popDWriteFont()

				setCursorX(10)
				ui.dwriteText("Created:" .. selectedSetupCreation, 20 * UI_SCALE_Y / 100)

				setCursorX(10)
				if
					ui.modernButtonAdvanced(
						"Load",
						vec2(ui.availableSpaceX() / 2 - 10, 30 * UI_SCALE_Y / 100),
						ui.ButtonFlags.None,
						ui.Icons.Download
					)
				then
					ac.loadSetup(selectedSetupPath)
					loadedSetup = saveDir .. " - " .. saveName

					ui.toast(ui.Icons.Download, "Setup loaded: " .. saveName)
				end
				ui.sameLine()

				if
					ui.modernButtonAdvanced(
						"Delete",
						vec2(ui.availableSpaceX() - 10, 30 * UI_SCALE_Y / 100),
						ui.ButtonFlags.None,
						ui.Icons.Delete
					)
				then
					io.deleteFile(selectedSetupPath)
					io.deleteFile(string.trim(selectedSetupPath, ".ini") .. ".sp")

					ui.toast(ui.Icons.Download, "Setup deleted: " .. selectedSetupName)

					selectedSetupPath = ""
					selectedSetupDir = ""
					selectedSetupName = ""

					loadSetups()
				end
			end
		end
	)
end

local function saveSetupWindow()
	setCursorX(0)
	ui.newLine(-30)

	childWindow(
		"save_setups",
		vec2(ui.availableSpaceX(), ui.availableSpaceY() - 10),
		false,
		ui.WindowFlags.None,
		function()
			-- ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), rgbm.colors.red, 0, ui.CornerFlags.None)

			setCursorX(10)
			ui.textAligned("Save Current Setup", vec2(0.5, 0.5), vec2(ui.availableSpaceX(), 30))

			setCursorX(10)
			ui.beginGroup(ui.availableSpaceX())

			ui.text("Name:")
			ui.sameLine()
			setCursorX(80)
			ui.setNextItemWidth((ui.availableSpaceX() - 80) / 2)
			saveName = ui.inputText("##SetupName", saveName, ui.InputTextFlags.None)

			ui.text("Notes:")
			ui.sameLine()
			setCursorX(80)
			saveDescription = ui.inputText(
				"##SetupDesc",
				saveDescription,
				ui.InputTextFlags.None,
				vec2((ui.availableSpaceX() - 80) / 2, ui.availableSpaceY() - 10)
			)

			ui.endGroup()

			setCursorX(ui.availableSpaceX() / 2 + 5)
			setCursorY(40)

			ui.beginGroup(ui.availableSpaceX())

			ui.text("Track:")
			ui.sameLine(50)
			ui.setNextItemWidth(ui.availableSpaceX() - 10)
			ui.combo("##setupcombo", saveDir, ui.ComboFlags.None, function()
				ui.bringWindowToFront()

				if ui.selectable("generic") then
					saveDir = "generic"
				end

				io.scanDir(setupsDir, function(dirName)
					if dirName == "generic" then
						return
					end

					if ui.selectable(dirName) then
						saveDir = dirName
					end
				end)
			end)

			ui.text("Tags:")
			ui.sameLine(50)
			ui.setNextItemWidth(ui.availableSpaceX() - 10)
			saveName = ui.inputText("##SetupTags", saveName, ui.InputTextFlags.None)

			if
				ui.modernButtonAdvanced(
					"Save Setup",
					vec2(ui.availableSpaceX() / 2 - 10, ui.availableSpaceY() - 10),
					ui.ButtonFlags.None,
					ui.Icons.Save
				)
			then
				if saveName ~= "" then
					ac.setActiveSetupName(saveName, saveDir)
					ac.saveCurrentSetup(setupsDir .. "\\" .. saveDir .. "\\" .. saveName .. ".ini")
					ui.toast(ui.Icons.Save, "Setup Saved: " .. saveName)
					loadedSetup = saveDir .. " - " .. saveName
					loadSetups()
				end
			end

			setCursorX(10)
			ui.sameLine()

			if
				ui.modernButtonAdvanced(
					"Reset Setup",
					vec2(ui.availableSpaceX() - 10, ui.availableSpaceY() - 10),
					ui.ButtonFlags.None,
					ui.Icons.Restart
				)
			then
				ac.resetSetupToDefault()
			end

			ui.endGroup()
		end
	)
end

function ioTab()
	setCursorY(50)

	childWindow(
		"setup_io",
		vec2(ui.availableSpaceX(), ui.availableSpaceY() / 2.75 * 2 - 20),
		false,
		ui.WindowFlags.None,
		function()
			setCursorY(0)
			ui.textAligned("Current Setup [" .. loadedSetup .. "]", vec2(0.5, 0.5), vec2(ui.availableSpaceX(), 30))

			savedSetupsWindow()
			loadSetupInfoWindow()
		end
	)

	saveSetupWindow()
end
