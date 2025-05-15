-- local sim = ac.getSim()

-- local pan = 0
-- local locked = false
-- local mapFocused = false

-- local trackStratMapResolution = sim.trackLengthM

-- local prevClickLeft = false
-- local prevClickRight = false
-- local prevClickIn = false
-- local prevClickOut = false

-- local ersMapper = ac.connect({
--         ac.StructItem.key("ERS_MAPPER"),
--         connected = ac.StructItem.boolean(),
--         trackMapCanvasHandle = ac.StructItem.int64(),
--         ersMapCanvasHandle = ac.StructItem.int64(),
-- }, true, ac.SharedNamespace.CarDisplay)

-- local drsIni = ac.INIConfig.trackData("drs_zones.ini")
-- local drsZonesPresent = false
-- local detectionLines = {}
-- local startLines = {}
-- local endLines = {}

-- local zoneCount = 0
-- for index, section in drsIni:iterate("ZONE") do
--         index = index - 1
--         detectionLines[index] = drsIni:get(section, "DETECTION", -1)
--         startLines[index] = drsIni:get(section, "START", -1)
--         endLines[index] = drsIni:get(section, "END", -1)

--         zoneCount = zoneCount + 1

--         drsZonesPresent = true
-- end

-- local colors = {
--         kDeploy = rgbm.colors.aqua,
--         hDeploy = rgbm(1, 0.2, 0.2, 1),
--         drs = rgbm(0.4, 1, 0.4, 0.85),
--         trackSplits = rgbm.colors.transparent,
-- }

-- local scale = 12
-- local xOffset = 0
-- local yOffset = 550
-- local points = 5000

-- local worldCoordXMin = nil
-- local worldCoordXMax = nil
-- local worldCoordZMin = nil
-- local worldCoordZMax = nil
-- for i = 0, points do
--         local splineStep = i / points
--         local worldCoord = ac.trackProgressToWorldCoordinate(splineStep)

--         if not worldCoordXMin or worldCoord.x < worldCoordXMin then worldCoordXMin = worldCoord.x end

--         if not worldCoordXMax or worldCoord.x > worldCoordXMax then worldCoordXMax = worldCoord.x end

--         if not worldCoordZMin or worldCoord.z < worldCoordZMin then worldCoordZMin = worldCoord.z end

--         if not worldCoordZMax or worldCoord.z > worldCoordZMax then worldCoordZMax = worldCoord.z end
-- end

-- local xScale = false
-- if math.abs(worldCoordXMax - worldCoordXMin) / 1024 > math.abs(worldCoordZMax - worldCoordZMin) / 1024 then
--         xScale = true
-- end

-- scale = math.max((math.abs(worldCoordXMax - worldCoordXMin)) / 768, (math.abs(worldCoordZMax - worldCoordZMin)) / 768)

-- local xCoordMin = worldCoordXMin / scale
-- local yCoordMin = worldCoordZMin / scale
-- local trackWidth = math.abs(worldCoordXMax - worldCoordXMin) / scale
-- local trackHeight = math.abs(worldCoordZMax - worldCoordZMin) / scale

-- if xScale then
--         xOffset = -xCoordMin + (768 - trackWidth) + 128
--         yOffset = -yCoordMin + (1024 - trackHeight) / 2
-- else
--         xOffset = -xCoordMin + (1024 - trackWidth) / 2
--         yOffset = -yCoordMin + (768 - trackHeight) + 128
-- end

-- local mapCanvas = ui.ExtraCanvas(1024)
-- local ersCanvas = ui.ExtraCanvas(1024)
-- local ersSplitCanvas = ui.ExtraCanvas(1024)
-- local completeCanvas = ui.ExtraCanvas(1024)

-- ersMapper.trackMapCanvasHandle = mapCanvas:sharedHandle()
-- ersMapper.ersMapCanvasHandle = ersCanvas:sharedHandle()

-- mapCanvas:setName("map")
-- ersSplitCanvas:setName("ers_split_map")
-- ersCanvas:setName("ers_map")

-- local trackMapResolution = 5000
-- local function drawMapSection(point1, point2, color, thickness)
--         for i = point1 * trackMapResolution, point2 * trackMapResolution do
--                 local splineStep = i / points
--                 local worldCoord = ac.trackProgressToWorldCoordinate(splineStep) / scale

--                 ui.pathLineTo(vec2(worldCoord.x + xOffset, worldCoord.z + yOffset))
--         end
--         ui.pathStroke(color, false, thickness)
-- end

-- local function updateMapSection(start, finish, color, thickness)
--         if start == finish then return end

--         if finish < start then
--                 drawMapSection(start, 1, color, thickness)
--                 drawMapSection(0, finish, color, thickness)
--         else
--                 drawMapSection(start, finish, color, thickness)
--         end
-- end

-- local function drawStartFinishLineMarker()
--         updateMapSection(sim.lapSplits[0] - 0.001, sim.lapSplits[0] + 0.001, rgbm.colors.white, 45)
-- end

-- local function drawDrsMarkers()
--         for i = 0, zoneCount - 1 do
--                 local drsDetectionLine = detectionLines[i]
--                 local drsStartLine = startLines[i]
--                 local drsEndLine = endLines[i]

--                 updateMapSection(drsDetectionLine - 0.001, drsDetectionLine + 0.001, colors.drs, 45)
--                 updateMapSection(drsStartLine, drsEndLine, colors.drs, 24)
--         end
-- end

-- local function drawTrack()
--         updateMapSection(0, 1, rgbm.colors.black, 15)
--         updateMapSection(0, 1, rgbm.colors.white, 5)
-- end

-- local function updateMapCanvas()
--         drawStartFinishLineMarker()
--         drawDrsMarkers()
--         drawTrack()
-- end

-- function drawMapCanvas()
--         mapCanvas:clear(rgbm.colors.transparent):update(function(dt) updateMapCanvas() end)
-- end

-- drawMapCanvas()

-- -- function mapViewControls()
-- -- 	local viewControlButtonFlags = locked and ui.ButtonFlags.Disabled or ui.ButtonFlags.None

-- -- 	cui.setCursorY(10)

-- -- 	if mapFocused then
-- -- 		cui.setCursorX(10)
-- -- 		ui.beginGroup()
-- -- 		ui.pushStyleVar(ui.StyleVar.ItemSpacing, 2)

-- -- 		if
-- -- 			ui.iconButton(
-- -- 				locked and ui.Icons.Padlock or ui.Icons.PadlockUnlocked,
-- -- 				vec2(25, 25) * cui.uiScale(),
-- -- 				5 * cui.uiScale()
-- -- 			)
-- -- 		then
-- -- 			locked = not locked
-- -- 		end
-- -- 		ui.sameLine()

-- -- 		ui.iconButton(
-- -- 			ui.Icons.TurnSignalLeft,
-- -- 			vec2(25, 25) * cui.uiScale(),
-- -- 			5 * cui.uiScale(),
-- -- 			true,
-- -- 			viewControlButtonFlags
-- -- 		)
-- -- 		if not locked then
-- -- 			if ui.itemClicked(ui.MouseButton.Left) or prevClickLeft then
-- -- 				if ui.mouseDown(ui.MouseButton.Left) then
-- -- 					prevClickLeft = true
-- -- 				else
-- -- 					prevClickLeft = false
-- -- 				end
-- -- 				local rotation = ac.getSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_ROTATION"]) + 25
-- -- 				if rotation > 36000 then
-- -- 					ac.setSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_ROTATION"], 0)
-- -- 				else
-- -- 					ac.setSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_ROTATION"], rotation)
-- -- 				end
-- -- 			end
-- -- 		end

-- -- 		ui.sameLine()
-- -- 		ui.iconButton(
-- -- 			ui.Icons.TurnSignalRight,
-- -- 			vec2(25, 25) * cui.uiScale(),
-- -- 			5 * cui.uiScale(),
-- -- 			true,
-- -- 			viewControlButtonFlags
-- -- 		)
-- -- 		if not locked then
-- -- 			if ui.itemClicked(ui.MouseButton.Left) or prevClickRight then
-- -- 				if ui.mouseDown(ui.MouseButton.Left) then
-- -- 					prevClickRight = true
-- -- 				else
-- -- 					prevClickRight = false
-- -- 				end
-- -- 				local rotation = ac.getSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_ROTATION"]) - 25
-- -- 				if rotation < 0 then
-- -- 					ac.setSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_ROTATION"], 36000)
-- -- 				else
-- -- 					ac.setSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_ROTATION"], rotation)
-- -- 				end
-- -- 			end
-- -- 		end

-- -- 		local currentZoom = ac.getSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_ZOOM"])

-- -- 		ui.iconButton(
-- -- 			ui.Icons.ZoomOut,
-- -- 			vec2(25, 25) * cui.uiScale(),
-- -- 			5 * cui.uiScale(),
-- -- 			true,
-- -- 			currentZoom > 355 and viewControlButtonFlags or ui.ButtonFlags.Disabled
-- -- 		)
-- -- 		if not locked then
-- -- 			if ui.itemClicked(ui.MouseButton.Left) or prevClickOut then
-- -- 				if ui.mouseDown(ui.MouseButton.Left) then
-- -- 					prevClickOut = true
-- -- 				else
-- -- 					prevClickOut = false
-- -- 				end
-- -- 				ac.setSetupSpinnerValue(
-- -- 					setupIDToSectionKeyMap["ERS_MAP_ZOOM"],
-- -- 					ac.getSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_ZOOM"]) - 5
-- -- 				)
-- -- 			end
-- -- 		end

-- -- 		ui.iconButton(
-- -- 			ui.Icons.ZoomIn,
-- -- 			vec2(25, 25) * cui.uiScale(),
-- -- 			5 * cui.uiScale(),
-- -- 			true,
-- -- 			currentZoom < 1000 and viewControlButtonFlags or ui.ButtonFlags.Disabled
-- -- 		)
-- -- 		if not locked then
-- -- 			if ui.itemClicked(ui.MouseButton.Left) or prevClickIn then
-- -- 				if ui.mouseDown(ui.MouseButton.Left) then
-- -- 					prevClickIn = true
-- -- 				else
-- -- 					prevClickIn = false
-- -- 				end
-- -- 				ac.setSetupSpinnerValue(
-- -- 					setupIDToSectionKeyMap["ERS_MAP_ZOOM"],
-- -- 					ac.getSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_ZOOM"]) + 5
-- -- 				)
-- -- 			end
-- -- 		end

-- -- 		ui.popStyleVar(1)
-- -- 		ui.endGroup()
-- -- 	end
-- -- end

-- local currentPanMapX = -90
-- local currentPanMapY = 80
-- local currentZoom = 0.8

-- function drawMap()
--         local mapWidth = ui.windowWidth()
--         local mapHeight = ui.windowHeight()
--         -- local targetPanMapX = ac.getSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_X"])
--         -- local targetPanMapY = ac.getSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_Y"])
--         -- local targetZoom = ac.getSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_ZOOM"]) / 1000

--         -- currentPanMapX = math.lerp(currentPanMapX, targetPanMapX - 680, 0.5)
--         -- currentPanMapY = math.lerp(currentPanMapY, targetPanMapY - 550, 0.5)
--         -- currentZoom = math.lerp(currentZoom, targetZoom, 0.5)

--         local mouseLocal = ui.mouseLocalPos()

--         -- if mouseLocal > vec2(0, 0) and mouseLocal <= vec2(mapWidth, mapHeight) then
--         -- 	ui.newLine()
--         -- 	if not locked then
--         -- 		if ui.mouseWheel() ~= 0 then
--         -- 			local newZoom = ac.getSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_ZOOM"]) + ui.mouseWheel() * 10
--         -- 			ac.setSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_ZOOM"], newZoom)

--         -- 			if (newZoom < 999 and ui.mouseWheel() > 0) or (newZoom > 356 and ui.mouseWheel() < 0) then
--         -- 				ac.setSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_X"], targetPanMapX - ui.mouseWheel() * 4)
--         -- 				ac.setSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_Y"], targetPanMapY - ui.mouseWheel() * 5.2)
--         -- 			end
--         -- 		else
--         -- 			if ui.isMouseDragging(ui.MouseButton.Middle) then
--         -- 				ui.setMouseCursor(ui.MouseCursor.ResizeAll)
--         -- 				local pan = ui.mouseDragDelta(ui.MouseButton.Middle)
--         -- 				ac.setSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_X"], targetPanMapX + pan.x)
--         -- 				ac.setSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_Y"], targetPanMapY + pan.y)
--         -- 				ui.resetMouseDragDelta(ui.MouseButton.Middle)
--         -- 			end
--         -- 		end
--         -- 	end

--         -- 	mapFocused = true
--         -- else
--         -- 	mapFocused = false
--         -- end

--         -- ui.beginRotation()
--         cui.setCursorX(currentPanMapX)
--         cui.setCursorY(currentPanMapY)
--         ui.image(mapCanvas, vec2(1024 * currentZoom, 1024 * currentZoom) * cui.uiScale())
--         cui.setCursorX(currentPanMapX)
--         cui.setCursorY(currentPanMapY)
--         ui.image(ersCanvas, vec2(1024 * currentZoom, 1024 * currentZoom) * cui.uiScale())
--         cui.setCursorX(currentPanMapX)
--         cui.setCursorY(currentPanMapY)
--         ui.image(ersSplitCanvas, vec2(1024 * currentZoom, 1024 * currentZoom) * cui.uiScale())
--         -- ui.endRotation(ac.getSetupSpinnerValue(setupIDToSectionKeyMap["ERS_MAP_ROTATION"]) / 100)

--         -- mapViewControls()
--         -- drawLegend()

--         ersMapper.connected = true
-- end

-- -- function drawScreenshotLegend()
-- -- 	ui.dwriteDrawText(ac.getTrackName(), 50, vec2(30, 10))
-- -- 	ui.dwriteDrawText(ac.getTrackID(), 25, vec2(50, 70))
-- -- 	ui.dwriteDrawText("STRAT " .. ERS_MAPPER_SELECTED_STRAT, 25, vec2(50, 100))

-- -- 	local yAlign = 820
-- -- 	local xAlign = 870
-- -- 	local xSpacing = 50

-- -- 	ui.dwriteDrawText("MGU-K Deploy", 20, vec2(xAlign, yAlign))
-- -- 	ui.drawRectFilled(vec2(xAlign - 35, yAlign), vec2(xAlign - 10, yAlign + 25), colors.kDeploy, 2, ui.CornerFlags.All)
-- -- 	yAlign = yAlign + xSpacing

-- -- 	ui.dwriteDrawText("E-Boost Turbo", 20, vec2(xAlign, yAlign))
-- -- 	ui.drawRectFilled(vec2(xAlign - 35, yAlign), vec2(xAlign - 10, yAlign + 25), colors.hDeploy, 2, ui.CornerFlags.All)
-- -- 	yAlign = yAlign + xSpacing

-- -- 	ui.dwriteDrawText("Overrun Regen", 20, vec2(xAlign, yAlign))
-- -- 	ui.drawRectFilled(
-- -- 		vec2(xAlign - 35, yAlign),
-- -- 		vec2(xAlign - 10, yAlign + 25),
-- -- 		rgbm.colors.white,
-- -- 		2,
-- -- 		ui.CornerFlags.All
-- -- 	)
-- -- 	yAlign = yAlign + xSpacing

-- -- 	ui.dwriteDrawText("DRS Zone", 20, vec2(xAlign, yAlign))
-- -- 	ui.drawRectFilled(vec2(xAlign - 35, yAlign), vec2(xAlign - 10, yAlign + 25), colors.drs, 2, ui.CornerFlags.All)
-- -- end

-- -- function drawLegend(screenshot)
-- -- 	if screenshot then
-- -- 		drawScreenshotLegend()
-- -- 		return
-- -- 	end

-- -- 	local yAlign = 325
-- -- 	local xAlign = 40
-- -- 	local ySpacing = 30

-- -- 	cui.setCursorY(yAlign)
-- -- 	cui.setCursorX(xAlign)
-- -- 	ui.dwriteText("MGU-K Deploy", 10 * cui.uiScale())
-- -- 	ui.drawRectFilled(
-- -- 		vec2(xAlign - 25, yAlign) * cui.uiScale(),
-- -- 		vec2(xAlign - 10, yAlign + 15) * cui.uiScale(),
-- -- 		colors.kDeploy,
-- -- 		2,
-- -- 		ui.CornerFlags.All
-- -- 	)
-- -- 	yAlign = yAlign + ySpacing

-- -- 	cui.setCursorY(yAlign)
-- -- 	cui.setCursorX(xAlign)
-- -- 	ui.dwriteText("E-Boost Turbo", 10 * cui.uiScale())
-- -- 	ui.drawRectFilled(
-- -- 		vec2(xAlign - 25, yAlign) * cui.uiScale(),
-- -- 		vec2(xAlign - 10, yAlign + 15) * cui.uiScale(),
-- -- 		colors.hDeploy,
-- -- 		2,
-- -- 		ui.CornerFlags.All
-- -- 	)
-- -- 	yAlign = yAlign + ySpacing

-- -- 	cui.setCursorY(yAlign)
-- -- 	cui.setCursorX(xAlign)
-- -- 	ui.dwriteText("Overrun Regen", 10 * cui.uiScale())
-- -- 	ui.drawRectFilled(
-- -- 		vec2(xAlign - 25, yAlign) * cui.uiScale(),
-- -- 		vec2(xAlign - 10, yAlign + 15) * cui.uiScale(),
-- -- 		rgbm.colors.white,
-- -- 		2,
-- -- 		ui.CornerFlags.All
-- -- 	)
-- -- 	yAlign = yAlign + ySpacing

-- -- 	cui.setCursorY(yAlign)
-- -- 	cui.setCursorX(xAlign)
-- -- 	ui.dwriteText("DRS Zone", 10 * cui.uiScale())
-- -- 	ui.drawRectFilled(
-- -- 		vec2(xAlign - 25, yAlign) * cui.uiScale(),
-- -- 		vec2(xAlign - 10, yAlign + 15) * cui.uiScale(),
-- -- 		colors.drs,
-- -- 		2,
-- -- 		ui.CornerFlags.All
-- -- 	)
-- -- end
