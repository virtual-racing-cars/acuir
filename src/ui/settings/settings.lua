require("src\\ui\\settings\\general_settings")
require("src\\ui\\settings\\appearance_settings")
require("src\\ui\\settings\\audio_settings")
require("src\\ui\\settings\\view_settings")

local settingsPages = {
	{
		label = "Home",
		enabled = true,
		func = function()
			pageSelector()
		end,
	},
	{ label = "General", enabled = true, func = generalSettings },
	{ label = "Controls", enabled = false, func = function() end },
	{ label = "Audio", enabled = true, func = audioSettings },
	{ label = "UI", enabled = true, func = appearanceSettings },
	{ label = "AI", enabled = false, func = function() end },
}

function pageSelector()
	cui.setCursorX(320)
	cui.setCursorY(366)

	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 122 * cui.scaleX())
	ui.beginGroup()

	for i = 2, #settingsPages do
		local page = settingsPages[i]

		if
			cui.settingsButton(page.label, 560, 300, page.enabled and ui.ButtonFlags.None or ui.ButtonFlags.Disabled)
		then
			storage.settingsTab = i
		end

		ui.sameLine()
		if i == 4 then
			cui.setCursorX(320)
			cui.offsetCursorY(422)
		end
	end

	ui.endGroup()
	ui.popStyleVar(1)

	bottomBar({
		{
			label = "BACK",
			enabled = true,
			func = function()
				storage.page = MenuPages.Home
			end,
		},
	})
end

function SettingsList(sim)
	pushMainMenuStyle()

	local page = settingsPages[storage.settingsTab]
	page.func()

	local storagePath = storage.settingsTab > 1 and "Settings/" .. page.label or "Settings/"
	topSubBar(storagePath)

	popMainMenuStyle()

	if ui.keyboardButtonPressed(ui.KeyIndex.Escape) then
		if storage.settingsTab > 1 then
			storage.settingsTab = 1
		else
			storage.page = MenuPages.Home
		end
	end
end
