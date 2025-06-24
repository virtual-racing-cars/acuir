local Widget = require("src.classes.Widget")
local cui = require("src.ui.cui")

local sessionModifiersWidget = Widget("Modifiers")

local assistsINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.Cfg) .. "\\assists.ini")
local raceINI = ac.INIConfig.raceConfig()

local electronicsState = { [0] = "Off", [1] = "Factory", [2] = "On" }
local assistState = { [0] = "Not Allowed", [1] = "Allowed" }
local jumpStartState = { [0] = "No Penalty", [1] = "Pits", [2] = "Drive-Through" }

local assists = {
        { label = "Traction Control", value = electronicsState[assistsINI:get("ASSISTS", "TRACTION_CONTROL", 0)] },
        { label = "ABS", value = electronicsState[assistsINI:get("ASSISTS", "ABS", 0)] },
        {
                label = "Stability Control",
                value = assistState[math.clamp(assistsINI:get("ASSISTS", "STABILITY_CONTROL", 0), 0, 1)],
        },
        {
                label = "Auto Clutch",
                value = assistState[math.clamp(assistsINI:get("ASSISTS", "AUTO_CLUTCH", 0), 0, 1)],
        },
        {
                label = "Damage",
                value = assistsINI:get("ASSISTS", "DAMAGE", 0) .. " %",
        },
        {
                label = "Fuel Rate",
                value = assistsINI:get("ASSISTS", "FUEL_RATE", 0) * 100 .. " %",
        },
        {
                label = "Tyre Wear Rate",
                value = assistsINI:get("ASSISTS", "TYRE_WEAR", 0) * 100 .. " %",
        },
        {
                label = "Tyre Blankets",
                value = assistsINI:get("ASSISTS", "TYRE_BLANKETS", 0) == 1 and "Yes" or "No",
        },
        {
                label = "Jump-Start",
                value = jumpStartState[raceINI:get("RACE", "JUMP_START_PENALTY", 0)],
        },
}

function sessionModifiersWidget:body()
        for _, assist in ipairs(assists) do
                cui.setCursorX(15)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        assist.label,
                        18 * cui.uiScale(),
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), 18 * cui.uiScale() * 1.5)
                )
                ui.sameLine()
                ui.setCursorX(ui.windowWidth() * 0.5)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        assist.value,
                        18 * cui.uiScale(),
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), 18 * cui.uiScale() * 1.5)
                )
        end
end

return sessionModifiersWidget
