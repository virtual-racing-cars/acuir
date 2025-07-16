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

return camera
