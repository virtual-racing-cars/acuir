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

local listWidth = 320
local listMargins = 5
local setupTabHeight = 50

function SettingsList(sim)
	setCursorX(100)
	setCursorY(110)

	ui.childWindow("settings_list", vec2(listWidth, 960), false, ui.WindowFlags.None, function()
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

	setCursorX(450)
	setCursorY(110)

	ui.childWindow("audio", vec2(800, 960), false, ui.WindowFlags.None, function()
		ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), rgbm(0.1, 0.1, 0.1, 0.5), 0, ui.CornerFlags.None)

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
