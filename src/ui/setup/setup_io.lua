local vec2Temp1 = vec2()

local setupsDir = ac.getFolder(ac.FolderID.UserSetups) .. "\\" .. ac.getCarID(0)

local refreshingSetups = false

local loadedSetups = {}
local selectedSetup = { name = "", track = "", path = "", creation = "" }
local saveSetup = { name = "", track = ac.getTrackID(), path = "", creation = "" }
local currentSetup = "generic/default"
local trackSortedSetups = {}

local function loadSetups()
	refreshingSetups = true

	for track, _ in pairs(loadedSetups) do
		for i in ipairs(loadedSetups[track]) do
			loadedSetups[track][i] = nil
		end
		loadedSetups[track] = nil
	end

	trackSortedSetups = {}

	loadedSetups[ac.getTrackID()] = {}

	io.scanDir(setupsDir, function(dirName)
		if SETTINGS.hideOtherTrackSetups then
			if dirName ~= ac.getTrackID() and dirName ~= "generic" then
				return
			end
		end

		io.scanDir(setupsDir .. "\\" .. dirName, function(fileName, fileAttributes)
			if string.find(fileName, ".sp") or string.find(fileName, ".txt") then
				return
			end

			if loadedSetups[dirName] == nil then
				loadedSetups[dirName] = {}
			end

			table.insert(loadedSetups[dirName], {
				name = fileName,
				track = dirName,
				path = setupsDir .. "\\" .. dirName .. "\\" .. fileName,
				creationTime = os.date(
					"%A, %B %d, %Y %H:%M:%S",
					tonumber(string.trim(tostring(fileAttributes.creationTime), "LL"))
				),
			})
		end)
	end)

	for track, setupList in pairs(loadedSetups) do
		table.sort(setupList, function(a, b)
			return a.creationTime > b.creationTime
		end)
	end

	-- Create a sorted list of track names
	for track in pairs(loadedSetups) do
		table.insert(trackSortedSetups, track)
	end
	table.sort(trackSortedSetups)
	table.removeItem(trackSortedSetups, "generic")
	table.insert(trackSortedSetups, 1, "generic")
	table.removeItem(trackSortedSetups, ac.getTrackID())
	table.insert(trackSortedSetups, 1, ac.getTrackID())

	refreshingSetups = false
end

loadSetups()

local function saveSetupWindow()
	local fontSize = ui.windowHeight() / 6

	ui.setCursorX(0)
	saveSetup.name = cui.inputText(
		"##SetupName",
		saveSetup.track .. "/",
		saveSetup.name,
		ui.InputTextFlags.None,
		vec2(ui.windowWidth(), 32 * cui.scaleY())
	)

	ui.setCursorX(0)
	local ioButtonSize = vec2Temp1:set(ui.windowWidth() / 4, fontSize * 1.5)

	if cui.menuButton("load", ioButtonSize) then
		ac.loadSetup(selectedSetup.path)
		currentSetup = selectedSetup.track .. "/" .. selectedSetup.name
		ui.toast(ui.Icons.Download, "Setup loaded: " .. selectedSetup.name)
	end
	ui.sameLine()

	if cui.menuButton("Reset", ioButtonSize) then
		ac.loadSetup(selectedSetup.path)
		currentSetup = selectedSetup.track .. "/" .. selectedSetup.name
		ui.toast(ui.Icons.Download, "Setup loaded: " .. selectedSetup.name)
	end
	ui.sameLine()

	if cui.menuButton("delete", ioButtonSize) then
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

	if cui.menuButton("Save", ioButtonSize) then
		if saveSetup.name ~= "" then
			saveSetup.path = setupsDir .. "\\" .. saveSetup.track .. "\\" .. saveSetup.name .. ".ini"
			ac.setActiveSetupName(saveSetup.name, saveSetup.track)
			ac.saveCurrentSetup(saveSetup.path)
			ui.toast(ui.Icons.Save, "Setup Saved: " .. saveSetup.name)
			currentSetup = saveSetup.track .. "/" .. saveSetup.name
			selectedSetup = table.clone(saveSetup, true)

			loadSetups()
		end
	end
end

function setupIoDraw()
	cui.contentWindow(
		"saved_setups",
		"saved_setups",
		vec2(0, 0),
		vec2(ui.windowWidth(), ui.windowHeight() / 5),
		ui.WindowFlags.None,
		function()
			ui.setCursor(0)
			ui.dwriteTextAligned(
				"Saved Setups",
				20 * cui.scaleY(),
				ui.Alignment.Center,
				ui.Alignment.End,
				ui.availableSpace()
			)

			ui.setCursor(0)
			ui.dwriteTextAligned(
				"Current Setup [" .. currentSetup .. "]",
				20 * cui.scaleY(),
				ui.Alignment.Center,
				ui.Alignment.Center,
				vec2(ui.availableSpaceX(), 40 * cui.scaleY())
			)

			saveSetupWindow()
		end,
		false,
		true
	)

	cui.contentWindow(
		"load_setups",
		"load_setups",
		vec2(0, (ui.windowHeight() / 5)),
		vec2(ui.windowWidth(), (ui.windowHeight() / 5) * 4),
		ui.WindowFlags.None,
		function()
			ui.setCursor(0)
			if refreshingSetups then
				ui.icon(ui.Icons.LoadingSpinner, ui.availableSpace())
			else
				for _, track in ipairs(trackSortedSetups) do
					ui.setCursorX(0)
					if
						cui.treeNode(track, function()
							ui.pushStyleVar(ui.StyleVar.ItemSpacing, 1)
							for i in ipairs(loadedSetups[track]) do
								local setup = loadedSetups[track][i]
								local setupActive = selectedSetup.path == setup.path
								local name = string.replace(setup.name, ".ini", "")
								ui.setCursorX(0)

								if
									cui.treeNodeButton(
										name,
										vec2(ui.windowWidth(), 32 * cui.scaleY()),
										setupActive,
										false
									)
								then
									selectedSetup = {
										name = name,
										track = track,
										path = setup.path,
										creation = setup.creationTime,
									}

									saveSetup = {
										name = name,
										track = track,
										path = setup.path,
										creation = setup.creationTime,
									}
								end
							end
							ui.popStyleVar(1)
						end)
					then
						saveSetup.track = track
					end
				end
			end

			if ui.getScrollY() < 10 then
				ui.setScrollY(0)
			end

			if ui.getScrollMaxY() - ui.getScrollY() < 10 then
				ui.setScrollY(ui.getScrollMaxY())
			end
		end,
		false,
		false,
		true
	)

	return ""
end
