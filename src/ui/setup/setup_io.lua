local vec2Temp1 = vec2()

local setupsDir = ac.getFolder(ac.FolderID.UserSetups) .. "\\" .. ac.getCarID(0)

local refreshingSetups = false

local loadedSetups = {}
local trackSortedSetups = {}
local selectedSetup = { name = "", track = "", path = "", creation = "" }
local saveSetup = { name = "", track = ac.getTrackID(), path = "", creation = "" }
local currentSetup = "generic/default"

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
		if string.find(dirName, ".sp") or string.find(dirName, ".ini") or string.find(dirName, ".txt") then
			return
		end

		if loadedSetups[dirName] == nil then
			loadedSetups[dirName] = {}
		end

		io.scanDir(setupsDir .. "\\" .. dirName, function(fileName, fileAttributes)
			if string.find(fileName, ".sp") or string.find(fileName, ".txt") then
				return
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

local function deleteSetup()
	io.deleteFile(saveSetup.path)
	io.deleteFile(string.trim(saveSetup.path, ".ini") .. ".sp")

	saveSetup.name = ""
	saveSetup.path = ""

	selectedSetup = { name = "", track = "", path = "", creation = "" }

	loadSetups()
end

local function promptDeleteSetup()
	local mouseMoved = false

	cui.modalDialog(function()
		ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
		local textBoxHeight = ui.windowHeight() / 4

		ui.setCursor(0)
		ui.dwriteTextAligned("Delete Setup", textBoxHeight / 2, nil, nil, vec2(ui.windowWidth(), textBoxHeight))
		local titleTextWidth = ui.measureDWriteText(" Delete Setup ", textBoxHeight / 2).x

		ui.drawSimpleLine(
			vec2(ui.windowWidth() / 2 - titleTextWidth / 2, ui.getCursorY()),
			vec2(ui.windowWidth() / 2 + titleTextWidth / 2, ui.getCursorY()),
			SETTINGS.uiColor2,
			3
		)

		ui.setCursorX(0)
		ui.dwriteTextAligned(
			string.format("%s/%s", selectedSetup.track, selectedSetup.name),
			textBoxHeight / 4,
			nil,
			nil,
			vec2(ui.availableSpaceX(), textBoxHeight)
		)

		local buttonWidth = ui.windowWidth() / 3
		ui.setCursorX(ui.windowWidth() / 2 - buttonWidth - 5 * cui.scaleY())
		if cui.modalButton("Cancel", ui.windowWidth() / 3, 50 * cui.scaleY(), ui.ButtonFlags.None) then
			ui.popStyleVar(1)

			return true
		end
		ui.sameLine()

		if not mouseMoved then
			ac.setMousePosition(ui.cursorScreenPos() + vec2(ui.availableSpaceX() / 2, 20))
			mouseMoved = true
		end

		ui.setCursorX(ui.windowWidth() / 2 + 5 * cui.scaleY())
		if cui.modalButton("Confirm", ui.windowWidth() / 3, 50 * cui.scaleY(), ui.ButtonFlags.None) then
			deleteSetup()
			ui.popStyleVar(1)

			return true
		end

		ui.popStyleVar(1)
	end, false)
end

local function saveSetupFile()
	ac.setActiveSetupName(saveSetup.name, saveSetup.track)
	sm:saveSetup(saveSetup.path)

	currentSetup = saveSetup.track .. "/" .. saveSetup.name
	selectedSetup = table.clone(saveSetup, true)

	loadSetups()
end

local function promptOverwriteSetup()
	local mouseMoved = false

	cui.modalDialog(function()
		-- ui.text(string.format("%s/%s", selectedSetup.track, selectedSetup.name))

		ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
		local textBoxHeight = ui.windowHeight() / 4

		ui.setCursor(0)
		ui.dwriteTextAligned("Overwrite Setup", textBoxHeight / 2, nil, nil, vec2(ui.windowWidth(), textBoxHeight))
		local titleTextWidth = ui.measureDWriteText(" Overwrite Setup ", textBoxHeight / 2).x

		ui.drawSimpleLine(
			vec2(ui.windowWidth() / 2 - titleTextWidth / 2, ui.getCursorY()),
			vec2(ui.windowWidth() / 2 + titleTextWidth / 2, ui.getCursorY()),
			SETTINGS.uiColor2,
			3
		)

		ui.setCursorX(0)
		ui.dwriteTextAligned(
			string.format("%s/%s", selectedSetup.track, selectedSetup.name),
			textBoxHeight / 4,
			nil,
			nil,
			vec2(ui.availableSpaceX(), textBoxHeight)
		)

		local buttonWidth = ui.windowWidth() / 3
		ui.setCursorX(ui.windowWidth() / 2 - buttonWidth - 5 * cui.scaleY())
		if cui.modalButton("Cancel", ui.windowWidth() / 3, 50 * cui.scaleY(), ui.ButtonFlags.None) then
			ui.popStyleVar(1)

			return true
		end
		ui.sameLine()

		if not mouseMoved then
			ac.setMousePosition(ui.cursorScreenPos() + vec2(ui.availableSpaceX() / 2, 20))
			mouseMoved = true
		end

		ui.setCursorX(ui.windowWidth() / 2 + 5 * cui.scaleY())
		if cui.modalButton("Confirm", ui.windowWidth() / 3, 50 * cui.scaleY(), ui.ButtonFlags.None) then
			saveSetupFile()
			ui.popStyleVar(1)

			return true
		end

		ui.popStyleVar(1)
	end, false)
end

local function saveSetupWindow(sm)
	local iconButtonHeight = ui.windowHeight() / 5
	local buttonWidth = (ui.windowWidth() / 24) * 22
	local groupBegin = (ui.windowWidth() / 24)

	ui.setCursor(0)
	ui.dwriteTextAligned(
		"Current Setup - " .. currentSetup,
		18 * cui.scaleY(),
		ui.Alignment.Center,
		ui.Alignment.Center,
		vec2(ui.availableSpaceX(), iconButtonHeight)
	)

	-- ui.setCursorX(groupBegin)

	-- saveSetup.track = cui.combo(
	-- 	"##trackcombobox",
	-- 	vec2(buttonWidth, iconButtonHeight),
	-- 	saveSetup.track,
	-- 	function(previewValue)
	-- 		local clicked = false
	-- 		local value = previewValue
	-- 		io.scanDir(setupsDir, function(dirName)
	-- 			if cui.treeNodeButton(dirName, vec2(buttonWidth, iconButtonHeight / 2), false, false) then
	-- 				clicked = true
	-- 				value = dirName
	-- 			end
	-- 		end)
	-- 		return clicked, value
	-- 	end
	-- )

	-- saveSetup.name = cui.inputText(
	-- 	"##SetupName",
	-- 	saveSetup.track .. "/",
	-- 	saveSetup.name,
	-- 	ui.InputTextFlags.None,
	-- 	vec2Temp1:set(buttonWidth, iconButtonHeight)
	-- )

	ui.setCursorX(groupBegin)
	saveSetup.name = cui.inputText(
		"##SetupName",
		saveSetup.track .. "/",
		saveSetup.name,
		ui.InputTextFlags.None,
		vec2Temp1:set(buttonWidth, iconButtonHeight)
	)
	ui.newLine()

	local setupFileExists = false
	if saveSetup.name ~= "" then
		saveSetup.path = setupsDir .. "\\" .. saveSetup.track .. "\\" .. saveSetup.name .. ".ini"
		setupFileExists = io.fileExists(saveSetup.path)
	end

	ui.setCursorX(groupBegin)

	ui.drawRectFilled(ui.getCursor(), ui.getCursor() + vec2Temp1:set(buttonWidth, iconButtonHeight), SETTINGS.uiColor1)
	if
		cui.menuButton(
			"Load Setup",
			vec2Temp1:set(buttonWidth, iconButtonHeight),
			nil,
			nil,
			setupFileExists and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
		)
	then
		sm:LoadStuff(selectedSetup.path)
		currentSetup = selectedSetup.track .. "/" .. selectedSetup.name
	end
	ui.newLine()

	buttonWidth = buttonWidth - 10 * cui.scaleY()

	ui.setCursorX(groupBegin)
	ui.drawRectFilled(
		ui.getCursor(),
		ui.getCursor() + vec2Temp1:set(buttonWidth / 2, iconButtonHeight),
		SETTINGS.uiColor1
	)
	if
		cui.menuButton(
			"Delete Setup",
			vec2Temp1:set(buttonWidth / 2, iconButtonHeight),
			nil,
			nil,
			setupFileExists and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
		)
	then
		if #selectedSetup.name > 0 then
			promptDeleteSetup()
		end
	end
	ui.sameLine()

	ui.offsetCursorX(10 * cui.scaleY())
	ui.drawRectFilled(
		ui.getCursor(),
		ui.getCursor() + vec2Temp1:set(buttonWidth / 2, iconButtonHeight),
		SETTINGS.uiColor1
	)
	if cui.menuButton("Save Setup", vec2Temp1:set(buttonWidth / 2, iconButtonHeight)) then
		if setupFileExists then
			promptOverwriteSetup(sm)
		else
			saveSetupFile(sm)
		end
	end
end

function setupIoDraw(sm)
	if ui.keyPressed(ui.Key.Delete) then
		deleteSetup()
	end

	cui.contentWindow(
		"setup_io_saved_setups",
		"setup_io_saved_setups",
		vec2(0, (ui.windowHeight() / 4) * 3),
		vec2(ui.windowWidth(), ui.windowHeight() / 4),
		ui.WindowFlags.None,
		function()
			ui.setCursor(0)

			saveSetupWindow(sm)
		end,
		false,
		false
	)

	cui.contentWindow(
		"load_setups",
		"load_setups",
		vec2(0, 0),
		vec2(ui.windowWidth(), (ui.windowHeight() / 4) * 3),
		ui.WindowFlags.None,
		function()
			ui.setCursor(0)

			if refreshingSetups then
				ui.icon(ui.Icons.LoadingSpinner, ui.availableSpace())
			else
				for _, track in ipairs(trackSortedSetups) do
					ui.setCursorX(0)
					if
						cui.treeNode(track, #loadedSetups[track], function()
							for i in ipairs(loadedSetups[track]) do
								local setup = loadedSetups[track][i]
								local setupActive = selectedSetup.path == setup.path
								local name = string.replace(setup.name, ".ini", "")
								ui.setCursorX(0)

								if
									cui.treeNodeButton(
										name,
										vec2(ui.windowWidth(), 40 * cui.scaleY()),
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
						end)
					then
						saveSetup.track = track
					end
				end
			end

			if ui.getScrollY() < 5 * cui.scaleY() then
				ui.setScrollY(0)
			end

			if ui.getScrollMaxY() - ui.getScrollY() < 5 * cui.scaleY() then
				ui.setScrollY(ui.getScrollMaxY())
			end
		end,
		false,
		true,
		true
	)

	return ""
end
