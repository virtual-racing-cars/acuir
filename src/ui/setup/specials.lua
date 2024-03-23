local car = ac.getCar(0)

local setupsDir = ac.getFolder(ac.FolderID.UserSetups) .. "\\" .. ac.getCarID(0)

local selectedSetupPath = ""
local selectedSetup = ""
local selectedSetupCreation = ""
local function loadSetupTab()
	setCursorY(50)

	ui.childWindow("saved_setups", vec2(400, 500), function()
		io.scanDir(setupsDir, function(dirName)
			if settings.hideOtherTrackSetups then
				if dirName ~= ac.getTrackID() and dirName ~= "generic" then
					return
				end
			end

			local hasSetup = false
			local setups = {}
			io.scanDir(setupsDir .. "\\" .. dirName, function(fileName, fileAttributes)
				if string.find(fileName, ".sp") then
					return
				end

				hasSetup = true

				table.insert(setups, {
					setupsDir .. "\\" .. dirName .. "\\" .. fileName,
					fileName,
					os.date(
						"%A, %B %d, %Y %H:%M:%S",
						tonumber(string.trim(tostring(fileAttributes.creationTime), "LL"))
					),
				})
			end)

			if not hasSetup then
				return
			end

			ui.treeNode(dirName, function()
				for i in ipairs(setups) do
					selectedSetupPath = setups[i][1]
					local setupName = string.trim(setups[i][2], ".ini")
					selectedSetupCreation = setups[i][3]
					if ui.modernButtonAdvanced(setupName, vec2(300, 30), ui.ButtonFlags.None) then
						selectedSetup = setupName
					end
				end
			end)
		end)
	end)

	setCursorX(410)
	setCursorY(50)
	ui.childWindow("selected_setup", vec2(500, 500), function()
		if selectedSetup == "" then
			return
		end

		ui.pushDWriteFont("Default;Weight=Bold")
		ui.dwriteDrawText(selectedSetup, 20, vec2(0, 0), rgbm.colors.white)
		ui.newLine()
		ui.bulletText("Created on: " .. selectedSetupCreation)
		ui.popDWriteFont()

		if ui.modernButtonAdvanced("Load Setup", vec2(200, 30), ui.ButtonFlags.None) then
			ac.loadSetup(selectedSetupPath)
			loadSetupSpinners()
		end
		ui.sameLine()
		if ui.modernButtonAdvanced("Delete Setup", vec2(200, 30), ui.ButtonFlags.None) then
			io.deleteFile(selectedSetupPath)
			io.deleteFile(string.trim(selectedSetupPath, ".ini") .. ".sp")
		end
	end)
end

local saveDir = "generic"
local saveName = ""
local saveDescription = ""
local function saveSetupTab()
	setCursorX(10)
	setCursorY(70)

	ui.setNextItemWidth(300)
	saveName = ui.inputText("##SetupName", saveName, ui.InputTextFlags.None)
	ui.sameLine()
	ui.setNextItemWidth(300)
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
	setCursorX(10)
	saveDescription = ui.inputText("##SetupDesc", saveDescription, ui.InputTextFlags.None, vec2(300, 200))

	setCursorX(10)

	if ui.modernButtonAdvanced("Save Setup", vec2(300, 30), ui.ButtonFlags.None) then
		ac.saveCurrentSetup(setupsDir .. "\\" .. saveDir .. "\\" .. saveName .. ".ini")
	end
end

local function compareSetupTab() end

function SetupSpecialTabs(tab)
	if tab == "LOAD SETUP" then
		loadSetupTab()
	end

	if tab == "SAVE SETUP" then
		saveSetupTab()
	end

	if tab == "COMPARE SETUP" then
		compareSetupTab()
	end
end
