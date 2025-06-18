local settings = require("settings")

local style = {
        main = {
                colors = {
                        { ui.StyleColor.ScrollbarGrab, settings.Appearance.uiColorAccent },
                        { ui.StyleColor.ScrollbarBg, settings.Appearance.uiColorBackground },
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
                corners = { innerSize = 6, outerSize = 16 },
                margins = { innerSize = 10, outerSize = 15 },
        },
}

function style:pushFontRegular() ui.pushDWriteFont(style.main.font.type:weight(ui.DWriteFont.Weight.SemiBold)) end

function style:pushFontBold() ui.pushDWriteFont(style.main.font.type:weight(ui.DWriteFont.Weight.Bold)) end

function style:pushStyleMain()
        for _, v in pairs(style.main.colors) do
                ui.pushStyleColor(v[1], v[2])
        end

        for _, v in pairs(style.main.var) do
                ui.pushStyleVar(v[1], v[2])
        end

        style:pushFontRegular()
end

function style:popStyleMain()
        ui.popStyleColor(#style.main.colors)
        ui.popStyleVar(#style.main.var)
        ui.popDWriteFont()
end

return style
