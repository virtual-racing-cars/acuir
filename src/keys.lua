local keys = {
        keyList = {
                [ac.KeyIndex.Space] = { string = " ", hex = "0x20" },
                [ac.KeyIndex.D0] = { string = "0", hex = "0x30" },
                [ac.KeyIndex.D1] = { string = "1", hex = "0x31" },
                [ac.KeyIndex.D2] = { string = "2", hex = "0x32" },
                [ac.KeyIndex.D3] = { string = "3", hex = "0x33" },
                [ac.KeyIndex.D4] = { string = "4", hex = "0x34" },
                [ac.KeyIndex.D5] = { string = "5", hex = "0x35" },
                [ac.KeyIndex.D6] = { string = "6", hex = "0x36" },
                [ac.KeyIndex.D7] = { string = "7", hex = "0x37" },
                [ac.KeyIndex.D8] = { string = "8", hex = "0x38" },
                [ac.KeyIndex.D9] = { string = "9", hex = "0x39" },
                [ac.KeyIndex.A] = { string = "A", hex = "0x41" },
                [ac.KeyIndex.B] = { string = "B", hex = "0x42" },
                [ac.KeyIndex.C] = { string = "C", hex = "0x43" },
                [ac.KeyIndex.D] = { string = "D", hex = "0x44" },
                [ac.KeyIndex.E] = { string = "E", hex = "0x45" },
                [ac.KeyIndex.F] = { string = "F", hex = "0x46" },
                [ac.KeyIndex.G] = { string = "G", hex = "0x47" },
                [ac.KeyIndex.H] = { string = "H", hex = "0x48" },
                [ac.KeyIndex.I] = { string = "I", hex = "0x49" },
                [ac.KeyIndex.J] = { string = "J", hex = "0x4A" },
                [ac.KeyIndex.K] = { string = "K", hex = "0x4B" },
                [ac.KeyIndex.L] = { string = "L", hex = "0x4C" },
                [ac.KeyIndex.M] = { string = "M", hex = "0x4D" },
                [ac.KeyIndex.N] = { string = "N", hex = "0x4E" },
                [ac.KeyIndex.O] = { string = "O", hex = "0x4F" },
                [ac.KeyIndex.P] = { string = "P", hex = "0x50" },
                [ac.KeyIndex.Q] = { string = "Q", hex = "0x51" },
                [ac.KeyIndex.R] = { string = "R", hex = "0x52" },
                [ac.KeyIndex.S] = { string = "S", hex = "0x53" },
                [ac.KeyIndex.T] = { string = "T", hex = "0x54" },
                [ac.KeyIndex.U] = { string = "U", hex = "0x55" },
                [ac.KeyIndex.V] = { string = "V", hex = "0x56" },
                [ac.KeyIndex.W] = { string = "W", hex = "0x57" },
                [ac.KeyIndex.X] = { string = "X", hex = "0x58" },
                [ac.KeyIndex.Y] = { string = "Y", hex = "0x59" },
                [ac.KeyIndex.Z] = { string = "Z", hex = "0x5A" },
                [ac.KeyIndex.Oem1] = { string = ";", hex = "0xBA" },
                [ac.KeyIndex.OemPlus] = { string = "+", hex = "0xBB" },
                [ac.KeyIndex.OemComma] = { string = ",", hex = "0xBC" },
                [ac.KeyIndex.OemMinus] = { string = "-", hex = "0xBD" },
                [ac.KeyIndex.OemPeriod] = { string = ".", hex = "0xBE" },
                [ac.KeyIndex.Oem2] = { string = "/", hex = "0xBF" },
                [ac.KeyIndex.Oem3] = { string = "`", hex = "0xC0" },
                [ac.KeyIndex.SquareOpenBracket] = { string = "[", hex = "0xDB" },
                [ac.KeyIndex.SquareCloseBracket] = { string = "]", hex = "0xDD" },
        },
        indexStringList = {},
        indexHexList = {},
        hexIndexList = {},
        hexStringList = {},
}

for k, v in pairs(keys.keyList) do
        keys.indexStringList[k] = v.string
        keys.indexHexList[k] = v.hex
        keys.hexIndexList[v.hex] = k
        keys.hexStringList[v.hex] = v.string
end

return keys
