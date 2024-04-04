require("src\\ui\\settings\\general_settings")
require("src\\ui\\settings\\appearance_settings")
require("src\\ui\\settings\\audio_settings")
require("src\\ui\\settings\\view_settings")
require("src\\ui\\settings\\setup_settings")

local settingsTabs = {
	"GENERAL",
	"APPEARANCE",
	"VIEW",
	"AUDIO",
	"TELEMETRY",
	"SETUP",
	"CAR INSTRUMENTS",
	"CONTROLS",
}

local listWidth = 335 * UI_SCALE_X / 100
local listMargins = 5
local setupTabHeight = 50

local settingsWindowSize = vec2(830 * UI_SCALE_X / 100, 710 * UI_SCALE_Y / 100)
local settingsListSize = vec2(listWidth, 710 * UI_SCALE_Y / 100)

function SettingsList(sim)
	contentWindow("settings_list", "SETTINGS", settingsListSize, ui.WindowFlags.None, function()
		pushSetupListStyle()

		setCursorY(80 * UI_SCALE_Y / 100)

		childWindow("settings_list", ui.availableSpace(), false, ui.WindowFlags.ThinScrollbar, function()
			local buttonXPos = 0
			local buttonYPos = 0
			for tab in ipairs(settingsTabs) do
				local buttonFlags = ui.ButtonFlags.None

				if storage.settingsTab == settingsTabs[tab] then
					buttonFlags = ui.ButtonFlags.Active
				end

				setCursorX(buttonXPos)
				setCursorY(buttonYPos)
				if
					ui.modernButtonAdvanced(
						settingsTabs[tab],
						vec2(ui.availableSpaceX(), setupTabHeight * UI_SCALE_Y / 100),
						buttonFlags
					)
				then
					storage.settingsTab = settingsTabs[tab]
				end

				buttonYPos = buttonYPos + setupTabHeight + listMargins
			end
		end)

		popSetupListStyle()
	end)

	setCursorX(350)
	setCursorY(0)

	contentWindow("settings_window", storage.settingsTab, settingsWindowSize, ui.WindowFlags.None, function()
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

		if storage.settingsTab == "SETUP" then
			setupSettings()
		end
	end)
end
