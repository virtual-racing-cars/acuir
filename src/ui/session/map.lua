local AISpline = require("ai_spline")
local cui = require("ui.cui")
local race = require("race")
local sim = ac.getSim()

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

local canvasSize = 1024
local mapCanvas = ui.ExtraCanvas(canvasSize):setName("map")
local mapResolution = 2000
local strokeMult = 5
local strokeWidths = {
        drsZone = 3.5 * strokeMult,
        drsDetection = 2 * strokeMult,
        trackMain = 2 * strokeMult,
        trackEdge = 1.5 * strokeMult,
        trackPit = 2 * strokeMult,
        splitLine = 1.5 * strokeMult,
        carDot = 2 * strokeMult,
}
local colors = {
        drs = rgbm(0.4, 1, 0.4, 1),
        trackMain = rgbm.colors.black,
        trackEdge = rgbm.colors.white,
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

local zoom = 1 - (0.01 * -40)
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
                drawSegment(startT, 1.0, color, thickness)
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
        ui.drawQuad(getCanvasPos(p1), getCanvasPos(p2), getCanvasPos(p3), getCanvasPos(p4), rgbm.colors.black)
end

local function drawDrsZones()
        for _, zone in ipairs(drsZones) do
                drawLoopedSegment(zone.start, zone.finish, colors.drs, strokeWidths.drsZone)
        end
end

local function drawTrack()
        drawSegment(0, 1, colors.trackMain, strokeWidths.trackMain)
        drawSegment(0, 1, colors.trackEdge, strokeWidths.trackEdge)
end

local function drawPitlane()
        if not spline then return end

        ui.pathClear()
        for t = 0, #spline.points - 1 do
                local index = t
                local wp = worldCoordsPit[index + 1]
                if wp then ui.pathLineTo(getCanvasPos(wp)) end
        end
        ui.pathStroke(rgbm.colors.gray, false, strokeWidths.trackPit)
end

function drawMapCanvas()
        mapCanvas:clear(rgbm.colors.transparent):update(function()
                drawDrsZones()
                drawPitlane()
                drawTrack()

                for i = 0, #sim.lapSplits - 1 do
                        local split = sim.lapSplits[i]
                        drawMarker(split, i == 0 and rgbm.colors.red or rgbm.colors.yellow, 30, 2)
                end

                for _, zone in ipairs(drsZones) do
                        drawMarker(zone.detection, colors.drs, 30, 2)
                end
        end)
end

local carPositionColors = {
        leader = rgbm.colors.red,
        focused = rgbm.colors.aqua,
        ahead = rgbm.colors.orange,
        behind = rgbm.colors.green,
        blueFlag = rgbm.colors.blue,
}

local function drawCarDot(car, position)
        local spectatedCar = ac.getCar(sim.focusedCar)
        if not spectatedCar then return end

        local localPos = getCanvasPos(car.position) * cui.uiScale()
        local screenPos = position + localPos

        local dotSize = strokeWidths.carDot
        local textSize = dotSize * 2

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
                and (car.lapCount + car.splinePosition)
                                - (spectatedCar.lapCount + spectatedCar.splinePosition)
                        < -0.9
        then
                carColor = carPositionColors.blueFlag
        end

        if car.index ~= spectatedCar.index and car.speedKmh < 5 then
                carColor = carColor:clone()
                carColor.mult = 0.5
                backColor = rgbm.colors.transparent
        end

        ui.drawCircleFilled(screenPos, dotSize * 1.2 * cui.uiScale(), backColor, 20 * cui.uiScale())
        ui.drawCircleFilled(screenPos, dotSize * cui.uiScale(), carColor, 20 * cui.uiScale())

        ui.setCursor(screenPos - vec2(textSize, textSize) * cui.uiScale())
        ui.dwriteTextAligned(
                leaderboardPosition,
                textSize * cui.uiScale(),
                0,
                0,
                vec2(textSize, textSize) * 2 * cui.uiScale(),
                false,
                spectatedCar.index == car.index and rgbm.colors.black or rgbm.colors.white
        )
end

function drawMap()
        local spectatedCar = ac.getCar(sim.focusedCar)
        local canvasSizeScaled = vec2(canvasSize, canvasSize) * cui.uiScale()
        local canvasPos = (ui.windowSize() - canvasSizeScaled) / 2

        ui.setCursor(canvasPos)
        ui.image(mapCanvas, canvasSizeScaled, sim.raceFlagType == ac.FlagType.Caution and rgbm.colors.yellow or nil)

        for _, c in ac.iterateCars.ordered(false) do
                local car = c
                if car and car.position and car.index ~= spectatedCar.index then drawCarDot(car, canvasPos) end
        end

        drawCarDot(spectatedCar, canvasPos)
end

drawMapCanvas()
