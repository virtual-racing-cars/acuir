local banner = {}

function banner.menu(label, time, bannerColor, rightSide, callbackType)
        if not callbackType then callbackType = "info" end

        callback[callbackType] = function()
                local xStart = rightSide and ui.windowWidth() or 0
                local xEnd = rightSide and ui.windowWidth() * 0.5 or ui.windowWidth() * 0.5
                local xText = rightSide and ui.windowWidth() * 0.75 or 0
                local alignment = rightSide and ui.Alignment.End or ui.Alignment.Start
                local margin = rightSide and -20 * uiScale or 20 * uiScale

                ui.drawRectFilledMultiColor(
                        vec2(xStart, 0),
                        vec2(xEnd, ui.windowHeight()),
                        bannerColor,
                        rgbm(0, 0, 0, 0),
                        rgbm(0, 0, 0, 0),
                        bannerColor
                )

                ui.setCursor(vec2(xText + margin, 0))

                ui.dwriteTextAligned(
                        label,
                        22 * uiScale,
                        alignment,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth() * 0.2, ui.windowHeight()),
                        false,
                        rgbm.colors.white
                )

                if time then
                        ui.sameLine()
                        ui.dwriteTextAligned(
                                string.format("%.1f", time),
                                22 * uiScale,
                                ui.Alignment.End,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth() * 0.05, ui.windowHeight()),
                                false,
                                rgbm.colors.white
                        )
                end
        end

        setTimeout(function() callback[callbackType] = nil end, 2, callbackType .. "banner")
end

return banner
