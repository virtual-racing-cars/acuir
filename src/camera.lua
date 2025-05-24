local cui = require("ui.cui")
local sim = ac.getSim()

local camera = { FOV = sim.cameraFOV }

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

return camera
