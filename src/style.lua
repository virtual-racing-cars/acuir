local Style = {}

local settings = require("settings")

local styleMain = {
        colors = {
                { ui.StyleColor.ScrollbarGrab, settings.Appearance.uiColor3 },
                { ui.StyleColor.ScrollbarBg, rgbm.colors.black },
        },
        var = {
                { ui.StyleVar.ScrollbarSize, 5 },
                { ui.StyleVar.ItemSpacing, 0 },
        },
        font = ui.DWriteFont("Rajdhani"):weight(ui.DWriteFont.Weight.SemiBold),
}

function Style:pushStyleMain()
        for _, v in pairs(styleMain.colors) do
                ui.pushStyleColor(v[1], v[2])
        end

        for _, v in pairs(styleMain.var) do
                ui.pushStyleVar(v[1], v[2])
        end

        ui.pushDWriteFont(styleMain.font)
end

function Style:popStyleMain()
        ui.popStyleColor(#styleMain.colors)
        ui.popStyleVar(#styleMain.var)
        ui.popDWriteFont()
end

local spinnerButtonStyle = {
        colors = {
                { ui.StyleColor.Button, rgbm(0, 0, 0, 0) },
                { ui.StyleColor.ButtonHovered, rgbm(0, 0, 0, 0) },
                { ui.StyleColor.ButtonActive, rgbm(0, 0, 0, 0) },
                { ui.StyleColor.TextHovered, rgbm(1, 0, 0, 1) },
        },
        var = {},
        font = nil,
}

function Style:pushSpinnerButtonStyle()
        for _, v in pairs(spinnerButtonStyle.colors) do
                ui.pushStyleColor(v[1], v[2])
        end

        for _, v in pairs(spinnerButtonStyle.var) do
                ui.pushStyleVar(v[1], v[2])
        end

        if spinnerButtonStyle.font then ui.pushDWriteFont(spinnerButtonStyle.font) end
end

function Style:popSpinnerButtonStyle()
        ui.popStyleColor(#spinnerButtonStyle.colors)
        ui.popStyleVar(#spinnerButtonStyle.var)

        if spinnerButtonStyle.font then ui.popDWriteFont() end
end

return Style
