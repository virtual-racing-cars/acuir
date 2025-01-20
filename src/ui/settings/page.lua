require("src\\ui\\settings\\settings")

local acLogo = ac.getFolder(ac.FolderID.Root) .. "\\launcher\\themes\\default\\graphics\\btn_AC_logo.png"
local acLogoSize = ui.imageSize(acLogo)

function SettingsPage(sim)
	ui.drawRectFilled(vec2(0, 0), vec2(sim.windowWidth, sim.windowHeight), rgbm(0.227451, 0.219608, 0.258824, 0.9))

	-- ui.drawLine(vec2(220, 64), vec2(600, 64), rgbm.colors.white, 1)
	-- ui.drawLine(vec2(220, 90), vec2(600, 90), rgbm.colors.white, 1)

	SettingsList(sim)
end
