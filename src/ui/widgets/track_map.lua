local AISpline = require("ai_spline")
local cui = require("ui.cui")
local race = require("race")
local settings = require("settings")
local style = require("ui.cui.style")
local weather = require("weather")
local car = ac.getCar(0)
local sim = ac.getSim()

local canvasSize = 1024

local trackMapWidget = {}

local map = {
        isShowingCars = true,
        isShowingSectors = true,
        isShowingWeather = true,
        canvas = ui.ExtraCanvas(1024):setName("map"),
}

local aiFolder = ac.getFolder(ac.FolderID.CurrentTrackLayout) .. "/ai"
local splineFilename ---@type string
local spline ---@type AISpline?

local availableSplines = {}
local function rescanSplines()
        availableSplines = io.scanDir(aiFolder, "*.ai")
        if not splineFilename and #availableSplines > 0 then
                splineFilename = "%s/%s"
                        % {
                                aiFolder,
                                "pit_lane.ai",
                        }
                spline = AISpline(splineFilename)
        end
end

rescanSplines()

local mapResolution = 2000
local strokeMult = 5
local strokeWidths = {
        drsZone = 5.5 * strokeMult,
        drsDetection = 2 * strokeMult,
        trackMain = 4 * strokeMult,
        trackEdge = 3 * strokeMult,
        trackPitEdge = 3 * strokeMult,
        trackPit = 2 * strokeMult,
        splitLine = 1.5 * strokeMult,
        carDot = 2.5 * strokeMult,
}
local colors = {
        drs = rgbm(0.4, 1, 0.4, 1),
        trackMain = settings.Appearance.uiColorBackground,
        trackEdge = settings.Appearance.uiColorText,
        split = rgbm.colors.white,
}

local drsIni = ac.INIConfig.trackData("drs_zones.ini")
local drsZones = {}

for _, section in drsIni:iterate("ZONE") do
        drsZones[#drsZones + 1] = {
                detection = drsIni:get(section, "DETECTION", -1),
                start = drsIni:get(section, "START", -1),
                finish = drsIni:get(section, "END", -1),
        }
end

local worldCoords = {}
local worldCoordsPit = {}
local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge

if spline then
        for _, v in ipairs(spline.points) do
                worldCoordsPit[#worldCoordsPit + 1] = v.pos
        end
end

for i = 0, mapResolution do
        local t = i / mapResolution
        local pt = ac.trackProgressToWorldCoordinate(t)
        worldCoords[#worldCoords + 1] = pt

        minX = math.min(minX, pt.x)
        maxX = math.max(maxX, pt.x)
        minZ = math.min(minZ, pt.z)
        maxZ = math.max(maxZ, pt.z)
end

local zoom = 1 - (0.01 * -25)
local trackWidth = maxX - minX
local trackHeight = maxZ - minZ
local scale = math.max(trackWidth, trackHeight) * zoom / (canvasSize - 256)
local offset = vec2(
        (canvasSize - trackWidth / scale) / 2 - minX / scale,
        (canvasSize - trackHeight / scale) / 2 - minZ / scale
)

local function getCanvasPos(worldPos) return vec2(worldPos.x / scale + offset.x, worldPos.z / scale + offset.y) end

local function drawSegment(startT, endT, color, thickness)
        local tStep = 1 / mapResolution
        ui.pathClear()
        for t = startT, endT, tStep do
                local index = math.floor(t * mapResolution)
                local wp = worldCoords[index + 1]
                if wp then ui.pathLineTo(getCanvasPos(wp)) end
        end
        ui.pathStroke(color, false, thickness)
end

local function drawLoopedSegment(startT, endT, color, thickness)
        if endT < startT then
                drawSegment(startT, 1.001, color, thickness)
                drawSegment(0.0, endT, color, thickness)
        else
                drawSegment(startT, endT, color, thickness)
        end
end

local function drawMarker(progress, color, lengthMeters, widthMeters)
        local center = ac.trackProgressToWorldCoordinate(progress)
        local forward = ac.trackProgressToWorldCoordinate((progress + 0.0005) % 1)
        local look = (forward - center):normalize()

        local up = vec3(0, 1, 0)
        local side = vec3.cross(up, look):normalize()

        local halfLength = look * strokeWidths.splitLine * scale * 0.5
        local halfWidth = side * strokeWidths.splitLine * 4 * scale * 0.5

        local p1 = center + halfLength + halfWidth
        local p2 = center + halfLength - halfWidth
        local p3 = center - halfLength - halfWidth
        local p4 = center - halfLength + halfWidth

        ui.drawQuadFilled(getCanvasPos(p1), getCanvasPos(p2), getCanvasPos(p3), getCanvasPos(p4), color)
        ui.drawQuad(
                getCanvasPos(p1),
                getCanvasPos(p2),
                getCanvasPos(p3),
                getCanvasPos(p4),
                settings.Appearance.uiColorBackground
        )
end

local function drawDrsZones()
        for _, zone in ipairs(drsZones) do
                drawLoopedSegment(zone.start, zone.finish, colors.drs, strokeWidths.drsZone)
        end
end

local function drawTrack()
        drawLoopedSegment(0, 1.001, colors.trackMain, strokeWidths.trackMain)
        drawLoopedSegment(0, 1.001, colors.trackEdge, strokeWidths.trackEdge)
end

local function drawPitlane()
        if not spline then return end

        ui.pathClear()
        for t = 0, #spline.points - 1 do
                local index = t
                local wp = worldCoordsPit[index + 1]
                if wp then ui.pathLineTo(getCanvasPos(wp)) end
        end
        ui.pathStroke(settings.Appearance.uiColorBackground, false, strokeWidths.trackPitEdge)

        ui.pathClear()
        for t = 0, #spline.points - 1 do
                local index = t
                local wp = worldCoordsPit[index + 1]
                if wp then ui.pathLineTo(getCanvasPos(wp)) end
        end
        ui.pathStroke(rgbm.colors.gray, false, strokeWidths.trackPit)
end

local function drawMapCanvas()
        map.canvas:clear(rgbm.colors.transparent):update(function()
                if car.drsPresent then drawDrsZones() end

                drawPitlane()
                drawTrack()

                if map.isShowingSectors then
                        for i = 0, #sim.lapSplits - 1 do
                                local split = sim.lapSplits[i]
                                drawMarker(split, i == 0 and rgbm.colors.red or rgbm.colors.yellow, 30, 2)
                        end
                end

                if car.drsPresent then
                        for _, zone in ipairs(drsZones) do
                                drawMarker(zone.detection, colors.drs, 30, 2)
                        end
                end
        end)
end

local carPositionColors = {
        leader = settings.Appearance.uiColorGold,
        focused = rgbm.colors.red,
        ahead = rgbm.colors.orange,
        behind = rgbm.colors.aqua,
        blueFlag = rgbm.colors.blue,
}

local function drawCarDot(car, position)
        local spectatedCar = ac.getCar(sim.focusedCar)
        if not spectatedCar then return end

        local localPos = getCanvasPos(car.position) * cui.scale()
        local screenPos = position + localPos

        local dotSize = strokeWidths.carDot
        local textSize = dotSize * 1.5 * cui.scale()

        local carColor = carPositionColors.behind
        local backColor = rgbm.colors.black

        local leaderboardPosition = race:getLeaderboardPosition(car.index)

        if car.index == spectatedCar.index then
                carColor = carPositionColors.focused
        elseif leaderboardPosition == 1 then
                carColor = carPositionColors.leader
        elseif leaderboardPosition < race:getLeaderboardPosition(spectatedCar.index) then
                carColor = carPositionColors.ahead
        elseif
                sim.raceSessionType == ac.SessionType.Race
                and (spectatedCar.lapCount + spectatedCar.splinePosition)
                        > (car.lapCount + car.splinePosition) + 0.8
        then
                carColor = carPositionColors.blueFlag
        end

        if car.speedKmh < 4 then
                dotSize = dotSize * 0.5
        elseif car.isInPitlane then
                dotSize = dotSize * 0.75
        end

        if car.drsActive and not car.isInPitlane then backColor = rgbm(0, 0.75, 0, 1) end

        ui.drawCircleFilled(screenPos, dotSize * 1.4 * cui.scale(), backColor, 20 * cui.scale())
        ui.drawCircleFilled(screenPos, dotSize * 1.2 * cui.scale(), rgbm.colors.black, 20 * cui.scale())
        ui.drawCircleFilled(screenPos, dotSize * cui.scale(), carColor, 20 * cui.scale())

        ui.setCursor(screenPos - vec2(dotSize * cui.scale(), dotSize * cui.scale()))
        if
                ui.invisibleButton(
                        "##focuscarmarker" .. car.index,
                        vec2(dotSize * 2 * cui.scale(), dotSize * 2 * cui.scale()),
                        ui.ButtonFlags.None
                )
        then
                if car.isConnected then ac.focusCar(car.index) end
        end

        ui.setCursor(screenPos - vec2(textSize, textSize))

        if leaderboardPosition < 9 then
                cui.offsetCursorX(4)
        elseif leaderboardPosition == 9 then
                cui.offsetCursorX(5)
        elseif leaderboardPosition == 11 then
                cui.offsetCursorX(4)
        elseif leaderboardPosition < 20 then
                cui.offsetCursorX(8)
        else
                cui.offsetCursorX(9)
        end

        if car.speedKmh < 4 then return end

        cui.offsetCursorY(9)
        style:pushFontBold()
        ui.dwriteTextAligned(leaderboardPosition, textSize, 1, 0, vec2(textSize, textSize), false, rgbm.colors.black)
        ui.popDWriteFont()
end

local function drawWeather()
        local xStart = 80 * cui.scale()
        local yStart = 50 * cui.scale()
        local size = 50 * cui.scale()
        local row = 0
        local column = 0
        local xGap = 100 * cui.scale()
        local yGap = 120 * cui.scale()
        local columnMax = 5

        for i = 0, 24 do
                column = column + 1

                if i % columnMax == 0 then
                        row = row + 1
                        column = 0
                end

                local x = xStart + column * xGap
                local y = yStart + row * yGap

                if row % 2 ~= 0 then x = x + xGap end

                ui.beginRotation()
                ui.drawIcon(ui.Icons.UpAlt, vec2(x, y), vec2(x + size, y + size), rgbm(0.6, 0.7, 0.9, 0.1))
                ui.endRotation(90 - sim.windDirectionDeg)
        end

        ui.drawIcon(
                weather.typeIcon[sim.weatherType],
                vec2(25 * cui.scale(), ui.windowHeight() - 75 * cui.scale()),
                vec2(75 * cui.scale(), ui.windowHeight() - 25 * cui.scale())
        )

        ui.drawIcon(
                ui.Icons.Compass,
                vec2(ui.windowWidth() - 75 * cui.scale(), ui.windowHeight() - 75 * cui.scale()),
                vec2(ui.windowWidth() - 25 * cui.scale(), ui.windowHeight() - 25 * cui.scale())
        )
        ui.setCursorX(ui.windowWidth() - 62 * cui.scale())
        ui.setCursorY(ui.windowHeight() - 125 * cui.scale())
        ui.dwriteText("N", 40 * cui.scale())
end

drawMapCanvas()

local trackLocation
local function getTrackLocation()
        if not trackLocation then
                if ac.getTrackID() == "" then return nil end
                local path = ac.getFolder(ac.FolderID.ContentTracks) .. "/" .. ac.getTrackID() .. "/ui/"
                if ac.getTrackLayout() ~= "" then path = path .. ac.getTrackLayout() .. "/" end
                print(path .. "ui_track.json")
                local city = JSON.parse(io.load(path .. "ui_track.json")).city
                local country = JSON.parse(io.load(path .. "ui_track.json")).country

                ac.log(city, country)

                if city and country then
                        trackLocation = string.reggsub(city, [[\t|</?br\s*/?\s*>]], "")
                                .. ", "
                                .. string.reggsub(country, [[\t|</?br\s*/?\s*>]], "")
                elseif city then
                        trackLocation = string.reggsub(city, [[\t|</?br\s*/?\s*>]], "")
                elseif country then
                        trackLocation = string.reggsub(country, [[\t|</?br\s*/?\s*>]], "")
                else
                        trackLocation = ""
                end
        end
        return trackLocation
end

function trackMapWidget:body()
        local spectatedCar = ac.getCar(sim.focusedCar)
        local canvasSizeScaled = vec2(canvasSize, canvasSize) * cui.scale()

        local canvasPos = (ui.windowSize() - canvasSizeScaled) / 2

        ui.setCursor(canvasPos)
        ui.image(map.canvas, canvasSizeScaled, sim.raceFlagType == ac.FlagType.Caution and rgbm.colors.yellow or nil)

        if map.isShowingCars then
                for _, c in ac.iterateCars.ordered(false) do
                        local car = c
                        if car and car.position and car.index ~= spectatedCar.index then drawCarDot(car, canvasPos) end
                end

                drawCarDot(spectatedCar, canvasPos)
        end

        if map.isShowingWeather then drawWeather() end

        local track = string.split(ac.getTrackName(), " - ")

        ui.setCursor(0)
        cui.offsetCursorY(10)
        for _, trackLine in ipairs(track) do
                cui.offsetCursorX(10)
                cui.snapCursor()

                ui.dwriteTextAligned(
                        trackLine,
                        style.main.font.body.size,
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), style.main.font.body.size * 1.2)
                )
        end

        cui.offsetCursorX(10)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "%s" % getTrackLocation(),
                style.main.font.body.size,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), style.main.font.body.size)
        )
end

function trackMapWidget:drawFooter()
        local changed = false
        local height = ui.windowHeight() * 0.65

        map.isShowingCars = drawCheckbox("##mapisShowingCars", "Cars", height, map.isShowingCars)
        ui.sameLine()
        cui.offsetCursorX(30)

        map.isShowingSectors, changed = drawCheckbox("##mapisShowingSectors", "Sectors", height, map.isShowingSectors)
        ui.sameLine()
        cui.offsetCursorX(30)

        map.isShowingWeather = drawCheckbox("##mapisShowingWeather", "Weather", height, map.isShowingWeather)

        if changed then drawMapCanvas() end
end

return trackMapWidget
