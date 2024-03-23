local sim = ac.getSim()
local car = ac.getCar(0)

function viewSettings()
	ui.setNextItemWidth(300)
	local value, changed = ui.slider("##fpv_slider", sim.firstPersonCameraFOV, 30, 120, "First Person FOV: %.0f")

	if changed then
		ac.setFirstPersonCameraFOV(value)
	end

	ui.sameLine()
	if ui.modernButton("##reset_fpv_fov", vec2(30, 30), ui.ButtonFlags.None, ui.Icons.Restart) then
		ac.resetFirstPersonCameraFOV()
	end
end
