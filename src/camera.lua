local cui = require("ui.cui")
local sim = ac.getSim()

local camera = { FOV = sim.cameraFOV, windowHovered = false }

function camera:step()
        if sim.isInMainMenu then
                if ui.mouseDown(ui.MouseButton.Right) or cui.menuZoomAvailable and ui.mouseWheel() ~= 0 then
                        camera.FOV = math.clamp(camera.FOV - ui.mouseWheel(), 20, 90)
                end

                if
                        ui.mouseDown(ui.MouseButton.Right)
                        or (sim.cameraMode == ac.CameraMode.OnBoardFree or sim.cameraMode == ac.CameraMode.Free)
                then
                        ac.setCameraFOV(camera.FOV)
                else
                        camera.FOV = sim.cameraFOV
                end
        else
                camera.FOV = sim.cameraFOV
        end
end

function camera:setPreviousSpectatedCar(focusedCar)
        local newSpectatedIndex = focusedCar == 0 and sim.carsCount - 1 or focusedCar - 1
        if ac.getCar(newSpectatedIndex) and ac.getCar(newSpectatedIndex).isConnected then
                ac.focusCar(newSpectatedIndex)
        else
                camera:setPreviousSpectatedCar(newSpectatedIndex)
        end
end

function camera:setNextSpectatedCar(focusedCar)
        local newSpectatedIndex = focusedCar == sim.carsCount - 1 and 0 or focusedCar + 1
        if ac.getCar(newSpectatedIndex) and ac.getCar(newSpectatedIndex).isConnected then
                ac.focusCar(newSpectatedIndex)
        else
                camera:setNextSpectatedCar(newSpectatedIndex)
        end
end

function camera:panZoomController()
        if sim.cameraMode == ac.CameraMode.OnBoardFree or sim.cameraMode == ac.CameraMode.Free then
                if ui.mouseClicked(ui.MouseButton.Left) then cui.menuPanAvailable = ui.getHoveredID() == 0 end
                if ui.mouseReleased(ui.MouseButton.Left) then cui.menuPanAvailable = false end

                cui.menuZoomAvailable = ui.getHoveredID() == 0
        else
                cui.menuZoomAvailable = false
                cui.menuPanAvailable = false
        end

        ui.setCursor(0)
        ui.childWindow("##Panner", vec2(10, 10), false, ui.WindowFlags.None, function()
                if cui.menuPanAvailable then ui.passthroughIMGUI() end
                ui.drawRectFilled(vec2(0, 0), ui.windowSize(), rgbm.colors.transparent)
        end)
end

return camera
