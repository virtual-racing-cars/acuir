local style = {}

local settings = require("settings")

local styleMain = {
        colors = {
                { ui.StyleColor.ScrollbarGrab, settings.Appearance.uiColorAccent },
                { ui.StyleColor.ScrollbarBg, rgbm.colors.black },
        },
        var = {
                { ui.StyleVar.ScrollbarSize, 5 },
                { ui.StyleVar.ItemSpacing, 0 },
        },
        font = {
                type = ui.DWriteFont("Rajdhani", ac.dirname() .. "\\assets\\fonts\\"),
                header = { size = 32, space = 46 },
                bodySize = { size = 18, space = 34 },
                smallSize = { size = 14, space = 30 },
        },
}

function style:pushFontRegular() ui.pushDWriteFont(styleMain.font.type:weight(ui.DWriteFont.Weight.SemiBold)) end

function style:pushFontBold() ui.pushDWriteFont(styleMain.font.type:weight(ui.DWriteFont.Weight.Bold)) end

function style:pushStyleMain()
        for _, v in pairs(styleMain.colors) do
                ui.pushStyleColor(v[1], v[2])
        end

        for _, v in pairs(styleMain.var) do
                ui.pushStyleVar(v[1], v[2])
        end

        style:pushFontRegular()
end

function style:popStyleMain()
        ui.popStyleColor(#styleMain.colors)
        ui.popStyleVar(#styleMain.var)
        ui.popDWriteFont()
end

return style
