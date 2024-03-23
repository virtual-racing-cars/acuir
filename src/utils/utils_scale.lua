setCursorY = function(pos)
	ui.setCursorY(pos * UI_SCALE_Y / 100)
end

setCursorX = function(pos)
	ui.setCursorX(pos * UI_SCALE_X / 100)
end

-- local scale = {}

-- function scale()

-- end

childWindow = function(id, size, border, flags, content)
	ui.childWindow(id, size, false, flags, content)
end
