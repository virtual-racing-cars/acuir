local listWidth = 320
local listMargins = 5
local setupTabHeight = 50

local functionButtonSize = vec2((listWidth / 3 - 12) * UI_SCALE_X / 100, setupTabHeight * UI_SCALE_Y / 100)

function SetupTabList()
	pushSetupListStyle()

	setCursorX(15)
	setCursorY(0)
	childWindow("setup_list", vec2(listWidth, 960), false, ui.WindowFlags.None, function()
		setCursorX(5)
		setCursorY(0)
		local buttonFlags = ui.ButtonFlags.None

		if storage.setupTab == "LOAD SETUP" then
			buttonFlags = ui.ButtonFlags.Active
		end

		if ui.modernButtonAdvanced("##load", functionButtonSize, buttonFlags, ui.Icons.Download) then
			storage.setupTab = "LOAD SETUP"
		end

		setCursorX(listWidth / 3 * 1)
		setCursorY(0)
		local buttonFlags = ui.ButtonFlags.None

		if storage.setupTab == "SAVE SETUP" then
			buttonFlags = ui.ButtonFlags.Active
		end

		if ui.modernButtonAdvanced("##save", functionButtonSize, buttonFlags, ui.Icons.Save) then
			storage.setupTab = "SAVE SETUP"
		end

		setCursorX(listWidth / 3 * 2)
		setCursorY(0)
		local buttonFlags = ui.ButtonFlags.None

		if storage.setupTab == "COMPARE SETUPS" then
			buttonFlags = ui.ButtonFlags.Active
		end

		if ui.modernButtonAdvanced("##compare", functionButtonSize, buttonFlags, ui.Icons.Contrast) then
			storage.setupTab = "COMPARE SETUPS"
		end

		local buttonXPos = 5
		local buttonYPos = 60
		for tab in ipairs(tabs) do
			local buttonFlags = ui.ButtonFlags.None

			if storage.setupTab == tabs[tab] then
				buttonFlags = ui.ButtonFlags.Active
			end

			setCursorX(buttonXPos)
			setCursorY(buttonYPos)
			if ui.modernButtonAdvanced(tabs[tab], LIST_BUTTON_SIZE, buttonFlags) then
				storage.setupTab = tabs[tab]
			end

			buttonYPos = buttonYPos + setupTabHeight + listMargins
		end
	end)

	popSetupListStyle()
end
