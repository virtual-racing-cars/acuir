local gamepad = {
        buttonList = {
                [ac.GamepadButton.DPadUp] = { string = "D-Pad Up", code = "DPAD_UP" },
                [ac.GamepadButton.DPadDown] = { string = "D-Pad Down", code = "DPAD_DN" },
                [ac.GamepadButton.DPadLeft] = { string = "D-Pad Left", code = "DPAD_LEFT" },
                [ac.GamepadButton.DPadRight] = { string = "D-Pad Right", code = "DPAD_RIGHT" },
                [ac.GamepadButton.Start] = { string = "Start", code = "START" },
                [ac.GamepadButton.Back] = { string = "Back", code = "BACK" },
                [ac.GamepadButton.LeftThumb] = { string = "Left Thumb", code = "LTHUMB_PRESS" },
                [ac.GamepadButton.RightThumb] = { string = "Right Thumb", code = "RTHUMB_PRESS" },
                [ac.GamepadButton.LeftShoulder] = { string = "L-Shoulder", code = "LEFTSHOULDER" },
                [ac.GamepadButton.RightShoulder] = { string = "R-Shoulder", code = "RIGHTSHOULDER" },
                [ac.GamepadButton.L2] = { string = "L2", code = "L2" },
                [ac.GamepadButton.R2] = { string = "R2", code = "R2" },
                [ac.GamepadButton.A] = { string = "A", code = "A" },
                [ac.GamepadButton.B] = { string = "B", code = "B" },
                [ac.GamepadButton.X] = { string = "X", code = "X" },
                [ac.GamepadButton.Y] = { string = "Y", code = "Y" },
                [ac.GamepadButton.PlayStation] = { string = "PlayStation", code = "PLAYSTATION" },
                [ac.GamepadButton.Microphone] = { string = "Microphone", code = "MICROPHONE" },
                [ac.GamepadButton.Pad] = { string = "Pad", code = "PAD" },
                [ac.GamepadButton.Extra] = { string = "Extra", code = "EXTRA" },
        },
        axisList = {

                [0] = { string = "L2", axis = ac.GamepadAxis.LeftTrigger, min = 0, max = 1 },
                [1] = { string = "R2", axis = ac.GamepadAxis.RightTrigger, min = 0, max = 1 },
                [2] = { string = "Left stick (Y+)", axis = ac.GamepadAxis.LeftThumbY, min = 0, max = 1 },
                [3] = { string = "Left stick (Y−)", axis = ac.GamepadAxis.LeftThumbY, min = 0, max = -1 },
                [4] = { string = "Right stick (Y+)", axis = ac.GamepadAxis.RightThumbY, min = 0, max = 1 },
                [5] = { string = "Right stick (Y−)", axis = ac.GamepadAxis.RightThumbY, min = 0, max = -1 },
                [6] = { string = "Left stick (X+)", axis = ac.GamepadAxis.LeftThumbX, min = 0, max = 1 },
                [7] = { string = "Left stick (X−)", axis = ac.GamepadAxis.LeftThumbX, min = 0, max = -1 },
                [8] = { string = "Right stick (X+)", axis = ac.GamepadAxis.RightThumbX, min = 0, max = 1 },
                [9] = { string = "Right stick (X−)", axis = ac.GamepadAxis.RightThumbX, min = 0, max = -1 },
                [10] = { string = "LEFT", axis = ac.GamepadAxis.LeftThumbX, min = -1, max = 1 },
                [11] = { string = "RIGHT", axis = ac.GamepadAxis.RightThumbX, min = -1, max = 1 },
        },

        indexStringList = {},
        indexCodeList = {},
        codeIndexList = {},
        codeStringList = {},
}

for k, v in pairs(gamepad.buttonList) do
        gamepad.indexStringList[k] = v.string
        gamepad.indexCodeList[k] = v.code
        gamepad.codeIndexList[v.code] = k
        gamepad.codeStringList[v.code] = v.string
end

return gamepad
