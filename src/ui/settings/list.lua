require("src\\ui\\settings\\general_settings")
require("src\\ui\\settings\\appearance_settings")
require("src\\ui\\settings\\audio_settings")
require("src\\ui\\settings\\view_settings")

local settingsTabs = {
	"GENERAL",
	"APPEARANCE",
	"VIEW",
	"AUDIO",
	"TELEMETRY",
	"CONTROLS",
}

local listWidth = 335 * UI_SCALE_X / 100
local listMargins = 5
local setupTabHeight = 50

local settingsWindowSize = vec2(830 * UI_SCALE_X / 100, 605 * UI_SCALE_Y / 100)
local settingsListSize = vec2(listWidth, 605 * UI_SCALE_Y / 100)

function SettingsList(sim)
	setCursorX(15)
	setCursorY(15)

	childWindow("settings_list", settingsListSize, false, ui.WindowFlags.None, function()
		ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.uiPrimaryColor, 0, ui.CornerFlags.None)
		ui.drawRect(vec2(0, 0), ui.availableSpace(), rgbm(1, 1, 1, 0.25), 0, ui.CornerFlags.None)

		pushSetupListStyle()

		local buttonXPos = 5
		local buttonYPos = 0
		for tab in ipairs(settingsTabs) do
			local buttonFlags = ui.ButtonFlags.None

			if storage.settingsTab == settingsTabs[tab] then
				buttonFlags = ui.ButtonFlags.Active
			end

			setCursorX(buttonXPos)
			setCursorY(buttonYPos)
			if ui.modernButtonAdvanced(settingsTabs[tab], LIST_BUTTON_SIZE, buttonFlags) then
				storage.settingsTab = settingsTabs[tab]
			end

			buttonYPos = buttonYPos + setupTabHeight + listMargins
		end

		popSetupListStyle()
	end)

	setCursorX(365)
	setCursorY(15)

	childWindow("settings_window", settingsWindowSize, false, ui.WindowFlags.None, function()
		ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.uiPrimaryColor, 0, ui.CornerFlags.None)
		ui.drawRect(vec2(0, 0), ui.availableSpace(), rgbm(1, 1, 1, 0.25), 0, ui.CornerFlags.None)

		if storage.settingsTab == "GENERAL" then
			generalSettings()
		end

		if storage.settingsTab == "APPEARANCE" then
			appearanceSettings()
		end

		if storage.settingsTab == "AUDIO" then
			audioSettings()
		end

		if storage.settingsTab == "VIEW" then
			viewSettings()
		end
	end)
end
