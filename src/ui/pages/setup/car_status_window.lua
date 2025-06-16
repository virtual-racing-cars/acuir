local cui = require("ui.cui")
local style = require("style")
local units = require("units")
local uis = ac.getUI()

local round = math.round

local car = ac.getCar(0)
local carINI = ac.INIConfig.carData(0, "car.ini")
local kgPerL = carINI:get("FUEL_EXT", "KG_PER_LITER", 0.7339)

local columnHeaders = { "", "Left", "Σ/Δ", "Right" }

local cornerStatusLabels = { "FRONT LEFT", "FRONT RIGHT", "REAR LEFT", "REAR RIGHT" }
local cornerStatusInfo = {

        {
                label = "Camber",
                value = function(i) return car.wheels[i].camber end,
                round = 2,
                compare = true,
                unit = "°",
        },
        {
                label = "Caster",
                value = function(i) return car.caster end,
                round = 2,
                compare = true,
                unit = "°",
        },
        {
                label = "Toe",
                value = function(i)
                        local rightSide = i % 2 == 0
                        local sign = rightSide and 1 or -1

                        return car.wheels[i].toeIn * sign
                end,
                round = 2,
                compare = true,
                unit = "°",
        },
        {
                label = "Travel",
                value = function(i) return car.wheels[i].suspensionTravel * 1000 end,
                round = 2,
                unit = "mm",
        },
        {
                label = "Load",
                value = function(i) return car.wheels[i].load end,
                round = 0,
                unit = "N",
        },
        {
                label = "Pressure",
                value = function(i) return car.wheels[i].tyreStaticPressure end,
                value2 = function(i) return car.wheels[i].tyrePressure end,
                round = 2,
                unit = "psi",
        },
        {
                label = "Core Temp",
                value = function(i) return car.wheels[i].tyreCoreTemperature end,
                round = 2,
                unit = "°C",
        },
        {
                label = "Grain & Blister",
                value = function(i) return car.wheels[i].tyreGrain end,
                value2 = function(i) return car.wheels[i].tyreBlister end,
                round = 4,
                unit = "%",
        },
}

local centerStatusInfo = {
        {
                label = "Front Ride Height",
                value = function(i) return car.rideHeight[0] * 1000 end,
                round = 1,
                min = "min: %s" % math.max(round(car.minHeight * 1000), 0),
                unit = "mm",
                warn = function() return car.rideHeight[0] < car.minHeight end,
        },
        {
                label = "Sprung CoG Height",
                value = function(i) return car.cgHeight * 1000 end,
                round = 1,
                unit = "mm",
        },
        {
                label = "Front WB",
                value = function(i)
                        return (car.wheels[0].load + car.wheels[1].load)
                                / (car.wheels[0].load + car.wheels[1].load + car.wheels[2].load + car.wheels[3].load)
                                * 100
                end,
                round = 2,
                unit = "%",
        },
        {
                label = "Total Mass",
                value = function(i) return units:mass(car.mass + (car.fuel * kgPerL) + car.ballast) end,
                round = 2,
                unit = uis.useImperialUnits and "lb" or "kg",
        },
        {
                label = "Fuel Mass",
                value = function(i) return units:mass(car.fuel * kgPerL) end,
                round = 2,
                unit = uis.useImperialUnits and "lb" or "kg",
        },
        {
                label = "Ballast Mass",
                value = function(i) return units:mass(car.ballast) end,
                round = 2,
                unit = uis.useImperialUnits and "lb" or "kg",
        },
        {
                label = "Plank Wear",
                value = function(i) return car.maxRelativePlankWear * 1000 end,
                round = 2,
                unit = "mm",
        },
        {
                label = "Rear Ride Height",
                value = function(i) return car.rideHeight[1] * 1000 end,
                round = 1,
                min = "min: %s" % math.max(round(car.minHeight * 1000), 0),
                unit = "mm",
                warn = function() return car.rideHeight[1] < car.minHeight end,
        },
}

function CarStatusWindow()
        local spaceSize = ui.windowHeight() / 28
        local fontSize = spaceSize * 0.5

        style:pushFontBold()
        for _, v in ipairs(columnHeaders) do
                ui.sameLine()
                ui.dwriteTextAligned(
                        v,
                        fontSize * 1.2,
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth() * 0.25, spaceSize * 1.2)
                )
        end
        ui.popDWriteFont()

        for i = 1, #cornerStatusInfo do
                local infoBlock = cornerStatusInfo[i]

                cui.offsetCursorX(15)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        string.format("%s (%s)", infoBlock.label, infoBlock.unit),
                        fontSize,
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth() * 0.25, spaceSize)
                )
                ui.sameLine()
                ui.setCursorX(ui.windowWidth() * 0.25)

                if infoBlock.compare then
                        local xSpace = ui.availableSpaceX() / 3
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                round(infoBlock.value(0), infoBlock.round),
                                fontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(xSpace, spaceSize)
                        )
                        ui.sameLine()

                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                round(infoBlock.value(0) - infoBlock.value(1), infoBlock.round),
                                fontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(xSpace, spaceSize)
                        )
                        ui.sameLine()

                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                round(infoBlock.value(1), infoBlock.round),
                                fontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(xSpace, spaceSize)
                        )
                elseif infoBlock.value2 then
                        local xSpace = ui.availableSpaceX() / 2
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                round(infoBlock.value(0), infoBlock.round)
                                        .. "/"
                                        .. round(infoBlock.value2(0), infoBlock.round),
                                fontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(xSpace, spaceSize)
                        )
                        ui.sameLine()

                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                round(infoBlock.value(1), infoBlock.round)
                                        .. "/"
                                        .. round(infoBlock.value2(1), infoBlock.round),
                                fontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(xSpace, spaceSize)
                        )
                else
                        local xSpace = ui.availableSpaceX() / 2
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                round(infoBlock.value(0), infoBlock.round),
                                fontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(xSpace, spaceSize)
                        )
                        ui.sameLine()

                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                round(infoBlock.value(1), infoBlock.round),
                                fontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(xSpace, spaceSize)
                        )
                end
        end
        ui.dummy(spaceSize)

        for i = 1, #centerStatusInfo do
                local infoBlock = centerStatusInfo[i]

                cui.offsetCursorX(15)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        string.format("%s (%s)", infoBlock.label, infoBlock.unit),
                        fontSize,
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth() * 0.4, spaceSize)
                )
                ui.sameLine()
                ui.setCursorX(ui.windowWidth() * 0.25)

                cui.snapCursor()
                ui.dwriteTextAligned(
                        round(infoBlock.value(1), infoBlock.round) .. (infoBlock.min and " " .. infoBlock.min or ""),
                        fontSize,
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(ui.availableSpaceX(), spaceSize),
                        false,
                        (infoBlock.warn and infoBlock.warn()) and rgbm.colors.red or rgbm.colors.white
                )
        end

        ui.dummy(spaceSize)

        for i = 1, #cornerStatusInfo do
                local infoBlock = cornerStatusInfo[i]

                cui.offsetCursorX(15)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        string.format("%s (%s)", infoBlock.label, infoBlock.unit),
                        fontSize,
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth() * 0.25, spaceSize)
                )
                ui.sameLine()
                ui.setCursorX(ui.windowWidth() * 0.25)

                if infoBlock.compare then
                        local xSpace = ui.availableSpaceX() / 3
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                round(infoBlock.value(2), infoBlock.round),
                                fontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(xSpace, spaceSize)
                        )
                        ui.sameLine()

                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                round(infoBlock.value(2) - infoBlock.value(3), infoBlock.round),
                                fontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(xSpace, spaceSize)
                        )
                        ui.sameLine()

                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                round(infoBlock.value(3), infoBlock.round),
                                fontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(xSpace, spaceSize)
                        )
                elseif infoBlock.value2 then
                        local xSpace = ui.availableSpaceX() / 2
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                round(infoBlock.value(2), infoBlock.round)
                                        .. "/"
                                        .. round(infoBlock.value2(2), infoBlock.round),
                                fontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(xSpace, spaceSize)
                        )
                        ui.sameLine()

                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                round(infoBlock.value(3), infoBlock.round)
                                        .. "/"
                                        .. round(infoBlock.value2(3), infoBlock.round),
                                fontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(xSpace, spaceSize)
                        )
                else
                        local xSpace = ui.availableSpaceX() / 2
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                round(infoBlock.value(2), infoBlock.round),
                                fontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(xSpace, spaceSize)
                        )
                        ui.sameLine()

                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                round(infoBlock.value(3), infoBlock.round),
                                fontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(xSpace, spaceSize)
                        )
                end
        end
end
