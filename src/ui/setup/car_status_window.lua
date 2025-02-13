local cui = require("ui.cui")

local car = ac.getCar(0)
local carINI = ac.INIConfig.carData(0, "car.ini")
local kgPerL = carINI:get("FUEL_EXT", "KG_PER_LITER", 0.7339)

local cornerStatusLabels = { "FRONT LEFT", "FRONT RIGHT", "REAR LEFT", "REAR RIGHT" }
local cornerStatusInfo = {
        [0] = {
                label = "Camber",
                value = function(i) return car.wheels[i].camber end,
                round = 2,
                unit = "",
        },
        {
                label = "Camber",
                value = function(i) return car.wheels[i].camber end,
                round = 2,
                unit = "",
        },
        {
                label = "Caster",
                value = function(i) return car.caster end,
                round = 2,
                unit = "",
        },
        {
                label = "Toe",
                value = function(i)
                        local rightSide = i % 2 == 0
                        local sign = rightSide and 1 or -1

                        return car.wheels[i].toeIn * sign
                end,
                round = 2,
                unit = "",
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
                round = 2,
                unit = "psi",
        },
        {
                label = "Pressure (hot)",
                value = function(i) return car.wheels[i].tyrePressure end,
                round = 2,
                unit = "psi",
        },
        {
                label = "Core Temp",
                value = function(i) return car.wheels[i].tyreCoreTemperature end,
                round = 2,
                unit = "°C",
        },
}

local centerStatusInfo = {
        {
                label = "Front Ride Height",
                value = function(i) return car.rideHeight[0] * 1000 end,
                round = 1,
                unit = "mm",
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
                value = function(i) return car.mass + (car.fuel * kgPerL) + car.ballast end,
                round = 2,
                unit = "kg",
        },
        {
                label = "Fuel Mass",
                value = function(i) return car.fuel * kgPerL end,
                round = 2,
                unit = "kg",
        },
        {
                label = "Ballast Mass",
                value = function(i) return car.ballast end,
                round = 2,
                unit = "kg",
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
                unit = "mm",
        },
}

function CarStatusWindow()
        if car == nil then
                car = ac.getCar(0)
                return
        end

        for i = 1, #cornerStatusInfo do
                local infoBlock = cornerStatusInfo[i]
                for j = 0, 3 do
                        local xPos = (j % 2 == 0) and 20 or 326
                        local yPos = j < 2 and 10 or 700
                        local row = (i > 1 and j > 1) and i - 1 or i

                        if i == 2 and j > 1 then goto continue end

                        if i == 1 then
                                cui.dwriteText({
                                        text = cornerStatusLabels[j + 1],
                                        fontSize = 25,
                                        xPos = xPos,
                                        yPos = yPos,
                                })
                        end

                        cui.dwriteText({
                                text = infoBlock.label .. ":",
                                fontSize = 25,
                                xPos = xPos,
                                yPos = yPos + row * 28,
                        })

                        if infoBlock.value(j) then
                                cui.dwriteText({
                                        text = math.round(infoBlock.value(j), infoBlock.round) .. " " .. infoBlock.unit,
                                        fontSize = 25,
                                        xPos = xPos + 174,
                                        yPos = yPos + row * 28,
                                })
                        end

                        ::continue::
                end
        end

        for i = 1, #centerStatusInfo do
                local infoBlock = centerStatusInfo[i]
                local xPos = 130
                local yPos = 240
                local row = i

                cui.dwriteText({
                        text = infoBlock.label .. ":",
                        fontSize = 25,
                        xPos = xPos,
                        yPos = yPos + row * 50,
                })
                cui.dwriteText({
                        text = math.round(infoBlock.value(i), infoBlock.round) .. " " .. infoBlock.unit,
                        fontSize = 25,
                        xPos = xPos + 240,
                        yPos = yPos + row * 50,
                })
        end
end
