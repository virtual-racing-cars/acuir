require("classes.SetupItem")
require("classes.PitstopItem")

local sim = ac.getSim()
local car = ac.getCar(0)
local pitstop = require("pitstop")
local setupINI = ac.INIConfig.carData(0, "setup.ini")
local assistsINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.Cfg) .. "\\assists.ini")

local setupFixedFile = ac.getFolder(ac.FolderID.UserSetups) .. "\\server_temp.ini"
local setupFixedINI = ac.INIConfig.load(setupFixedFile)
local setupFixed = io.lastWriteTime(setupFixedFile) > os.time() - 10

local gearSetupSpinners = {}
local function createGearDefaults()
        for i = 1, ac.getCar(0).gearCount do
                gearSetupSpinners["INTERNAL_GEAR_" .. i] = { xPos = 0.5, yPos = i - 1, zeroDefault = false }
        end
        gearSetupSpinners["FINAL_RATIO"] = { xPos = 0.5, yPos = ac.getCar(0).gearCount, zeroDefault = false }
end

local electronicsDefaults = {}
local electronicsIndex = 0
local function createElectronicsDefaults()
        if car.tractionControlModes > 0 or assistsINI:get("ASSISTS", "TRACTION_CONTROL", 0) == 2 then
                electronicsDefaults["TRACTION_CONTROL"] = { yPos = electronicsIndex }
                electronicsIndex = electronicsIndex + 1

                if car.tractionControlModes == 0 then ac.setSetupSpinnerValue("TRACTION_CONTROL", 1) end
        end

        if car.tractionControl2Modes > 0 then
                electronicsDefaults["TRACTION_CONTROL_2"] = { yPos = electronicsIndex }
                electronicsIndex = electronicsIndex + 1
        end

        if car.absModes > 0 or assistsINI:get("ASSISTS", "ABS", 0) == 2 then
                electronicsDefaults["ABS"] = { yPos = electronicsIndex }
                electronicsIndex = electronicsIndex + 1

                if car.absModes == 0 then ac.setSetupSpinnerValue("ABS", 1) end
        end

        if car.hasCockpitERSDelivery then
                electronicsDefaults["MGUK_DELIVERY"] = { yPos = electronicsIndex }
                electronicsIndex = electronicsIndex + 1
        end

        if car.hasCockpitERSRecovery then
                electronicsDefaults["MGUK_RECOVERY"] = { yPos = electronicsIndex }
                electronicsIndex = electronicsIndex + 1
        end

        if car.hasCockpitMGUHMode then
                electronicsDefaults["MGUH_MODE"] = { yPos = electronicsIndex }
                electronicsIndex = electronicsIndex + 1
        end

        if car.hasEngineBrakeSettings then
                electronicsDefaults["BRAKE_ENGINE"] = { yPos = electronicsIndex }
                electronicsIndex = electronicsIndex + 1
        end
end

local pitstopsINI =
        ac.INIConfig.load(string.format("%s\\%s", ac.getFolder(ac.FolderID.Root), "system\\cfg\\pitstop.ini"))
local presetsCount = pitstopsINI:get("SETTINGS", "PRESETS_COUNT", 1)

local function gisub(text, patterns)
        for _, v in ipairs(patterns) do
                local pattern = v[1]
                local replacement = v[2]

                local insensitivePattern = pattern:gsub(
                        "%a",
                        function(c) return string.format("[%s%s]", c:lower(), c:upper()) end
                )

                insensitivePattern = insensitivePattern:gsub("%s+", " ")
                text = text:gsub(insensitivePattern, replacement)
        end

        return text
end

local wing1Name = setupINI:get("WING_1", "NAME", "WING_1")
local wing2Name = setupINI:get("WING_2", "NAME", "WING_2")

local positionShorthandDict = {
        { "FRONT LEFT", "LF" },
        { "FRONT RIGHT", "RF" },
        { "LEFT FRONT", "LF" },
        { "RIGHT FRONT", "RF" },
        { "WINGS", "" },
        { "WING", "" },
}

local pitstopStratItemDefaults = {
        FUEL = { name = "Fuel to Add", nameAlt = "Fuel to Add", units = "L", xPos = 0.5, yPos = 2, default = 0 },
        COMPOUND = {
                name = "Compound",
                nameAlt = "Compound",
                tab = "Tyres",
                units = "",
                xPos = 0.5,
                yPos = 3.5,
                default = -1,
        },
        PRESSURE_LF = { name = "Pressure LF", nameAlt = "LF", tab = "Tyres", units = "psi", xPos = 0, yPos = 5 },
        PRESSURE_RF = { name = "Pressure RF", nameAlt = "RF", tab = "Tyres", units = "psi", xPos = 1, yPos = 5 },
        PRESSURE_LR = { name = "Pressure LR", nameAlt = "LR", tab = "Tyres", units = "psi", xPos = 0, yPos = 6 },
        PRESSURE_RR = { name = "Pressure RR", nameAlt = "RR", tab = "Tyres", units = "psi", xPos = 1, yPos = 6 },
        WING_1 = {
                name = wing1Name,
                nameAlt = gisub(wing1Name, positionShorthandDict),
                tab = "Wings",
                units = "",
                xPos = 1,
                yPos = 8,
                default = pitstop.wings[1].angle,
        },
        WING_2 = {
                name = wing2Name,
                nameAlt = gisub(wing2Name, positionShorthandDict),
                tab = "Wings",

                units = "",
                xPos = 0,
                yPos = 8,
                default = pitstop.wings[2].angle,
        },
        REPAIR_BODY = { name = "Repair Body", nameAlt = "Body", tab = "Repair", repair = true, xPos = 0, yPos = -3 },
        REPAIR_SUSPENSION = {
                name = "Repair Suspension",
                nameAlt = "Suspension",
                tab = "Repair",
                repair = true,
                xPos = 0,
                yPos = -4,
        },
        REPAIR_ENGINE = {
                name = "Repair Engine",
                nameAlt = "Engine",
                tab = "Repair",
                repair = true,
                xPos = 0,
                yPos = -5,
        },
}

local function createPitstopStratItems()
        local pitstopStratItems = {}

        table.insert(
                pitstopStratItems,
                PitstopItem(
                        "PRESET",
                        -1,
                        -1,
                        "Preset",
                        "",
                        "",
                        1,
                        presetsCount,
                        1,
                        1,
                        {},
                        "%.0f",
                        0.5,
                        0,
                        true,
                        1,
                        1 == presetsCount
                )
        )

        for preset = 1, presetsCount do
                for psItemIndex, psItem in ipairs(ac.getPitstopSpinners()) do
                        local id = psItem.name
                        local index = psItemIndex
                        local name = pitstopStratItemDefaults[id].name
                        local nameAlt = pitstopStratItemDefaults[id].nameAlt
                        local tab = pitstopStratItemDefaults[id].tab
                        local min = psItem.min
                        local max = psItem.max
                        local step = 1
                        local multiplier = 1
                        local units = pitstopStratItemDefaults[id].units or ""
                        local format = "%.0f " .. units
                        local items = nil
                        local xPos = pitstopStratItemDefaults[id].xPos
                        local yPos = pitstopStratItemDefaults[id].yPos
                        local default = pitstopStratItemDefaults[id].default and pitstopStratItemDefaults[id].default
                                or ac.getSetupSpinnerValue(id, 0)
                        local wingIndex = nil

                        if tab == "Wings" then wingIndex = tonumber(id:gsub("WING_", "")[1]) end

                        if id == "COMPOUND" then
                                items = {}

                                format = "%s"

                                items[0] = "NO CHANGE"

                                for i = 1, psItem.max + 1 do
                                        items[#items + 1] = ac.getTyresLongName(0, i - 1)
                                end

                                items[#items + 1] = "NO CHANGE"

                                for i = 1, psItem.max + 1 do
                                        items[#items + 1] = ac.getTyresName(0, i - 1)
                                end
                        end

                        if tab == "Repair" then items = { "No", "Yes" } end

                        table.insert(
                                pitstopStratItems,
                                PitstopItem(
                                        id,
                                        index,
                                        preset - 1,
                                        name,
                                        nameAlt,
                                        tab,
                                        min,
                                        max,
                                        step,
                                        multiplier,
                                        items,
                                        format,
                                        xPos,
                                        yPos,
                                        false,
                                        default,
                                        psItem.readOnly,
                                        wingIndex
                                )
                        )
                end
        end

        return pitstopStratItems
end
createPitstopStratItems()

local populatedTabs = {}
local pairedItems = {}
local setupSpinners = {}
local function loadSetupSpinners()
        createElectronicsDefaults()
        createGearDefaults()

        for i in ipairs(setupSpinners) do
                setupSpinners[i] = nil
        end

        for _, v in pairs(ac.getSetupSpinners()) do
                local id = v.name
                local tab = setupINI:get(id, "TAB", "")
                local name = v.label
                local min = v.min
                local max = v.max
                local step = v.step
                local multiplier = v.displayMultiplier or 1
                local units = v.units or ""
                local format = (multiplier == 1 and "%.0f " or "%.2f ") .. (units == "%" and "%%" or units)
                local items = v.items or {}
                local xPos = setupINI:get(id, "POS_X", 0.5)
                local yPos = setupINI:get(id, "POS_Y", 0)

                for i in ipairs(items) do
                        if string.find(items[i], "%%") then items[i] = string.replace(items[i], "%", "%%") end
                end

                if electronicsDefaults[id] then
                        tab = "ELECTRONICS"
                        yPos = electronicsDefaults[id].yPos
                end

                if tab == "ELECTRONICS" then yPos = math.round(yPos) end

                if id == "COMPOUND" then
                        tab = "TYRES"
                        min = 0
                        max = #items - 1
                end

                if id == "GEARSET" then
                        name = "GEAR SET"
                        tab = "GEARS"
                        min = 0
                        max = #items - 1
                end

                if gearSetupSpinners[id] then
                        tab = "GEARS"
                        xPos = gearSetupSpinners[id].xPos
                        yPos = gearSetupSpinners[id].yPos
                end

                if id == "FUEL" then tab = "FUEL" end

                if tab == "GEARS" then xPos = 0 end

                local fixed = setupFixed and sim.isOnlineRace and setupFixedINI:get(id, "VALUE", -12345) ~= -12345

                if not table.contains(populatedTabs, tab) then table.insert(populatedTabs, tab) end

                local uid = bit.tohex(ac.checksumXXH(stringify({ tab, xPos, yPos })))

                table.insert(
                        setupSpinners,
                        SetupItem(
                                id,
                                tab,
                                name,
                                min,
                                max,
                                step,
                                multiplier,
                                items,
                                format,
                                xPos,
                                yPos,
                                uid,
                                false,
                                nil,
                                fixed or v.readOnly
                        )
                )

                if not pairedItems[uid] then
                        pairedItems[uid] = { id }
                else
                        table.insert(pairedItems[uid], 1, id)
                end
        end

        for uid, uidPairs in pairs(pairedItems) do
                if #uidPairs > 1 then
                        for _, parent in pairs(setupSpinners) do
                                if parent.uid == uid then
                                        if parent.id == uidPairs[1] then
                                                parent.idPairs = uidPairs
                                        else
                                                parent.child = true
                                        end
                                end
                        end
                end
        end

        return setupSpinners
end

SetupTab = class("SetupTab")

function SetupTab:initialize(name)
        self.name = name
        self.setupSpinners = {}
end

SetupManager = class("SetupManager")

function SetupManager:initialize()
        self._setupSpinners = loadSetupSpinners()
        self._pitSpinners = createPitstopStratItems()
        self._defaultTabNames = { "ELECTRONICS", "PITSTOP STRATEGY", "FUEL", "TYRES", "GEARS", "APPS" }
        self._tabNames = {}
        self._tabCount = 0
        self._defaultSetup = ac.stringifyCurrentSetup()

        for k, _ in pairs(setupINI.sections) do
                local tabName = setupINI:get(k, "TAB", "")

                if tabName ~= "" and not table.contains(self._defaultTabNames, tabName) then
                        table.insert(self._tabNames, tabName)
                end
        end

        self._tabNames = table.distinct(self._tabNames)
        table.removeItem(self._tabNames, "")
        table.sort(self._tabNames)

        for i = 1, #self._defaultTabNames do
                local tab = self._defaultTabNames[i]
                table.insert(self._tabNames, 1, tab)
        end

        self.setupTabs = {}

        for i = 1, #self._tabNames do
                table.insert(self.setupTabs, SetupTab(self._tabNames[i]))
        end

        for k, v in pairs(self._setupSpinners) do
                for i in ipairs(self.setupTabs) do
                        if self.setupTabs[i].name == v.tab then
                                table.insert(self.setupTabs[i].setupSpinners, self._setupSpinners[k])
                        end
                end
        end

        for _, v in pairs(self.setupTabs) do
                if
                        v.name ~= "SETUP I/O"
                        and v.name ~= "PITSTOP STRATEGY"
                        and v.name ~= "GEARS"
                        and #v.setupSpinners == 0
                        and v.name ~= "APPS"
                then
                        table.removeItem(self.setupTabs, v)
                else
                        self._tabCount = self._tabCount + 1
                end
        end

        self._apps = require("setup_apps")

        for appName, app in pairs(self._apps) do
                if app.inline then table.insert(self.setupTabs, { name = appName, setupSpinners = {} }) end
        end

        self.savedSetupDir = ac.getFolder(ac.FolderID.UserSetups) .. "\\" .. ac.getCarID(0)

        self._history = {}
        self._history_pos = 0

        self:makeUndo()
end

function SetupManager:resetSetup() self:LoadStuff(self._defaultSetup) end

function SetupManager:tabCount() return self._tabCount end

function SetupManager:LoadStuff(tbl)
        ac.loadSetup(tbl)

        for _, v in pairs(self._setupSpinners) do
                if v.mirrored then
                        if ac.getSetupSpinnerValue(v.idMirror) ~= ac.getSetupSpinnerValue(v.id) then
                                v.mirrored = false
                        end
                end

                v:setValue(ac.getSetupSpinnerValue(v.id, v.default))
        end

        self:loadPitstopStrategy(tbl)
end

function SetupManager:loadPitstopStrategy(file)
        local spFileString = string.replace(file, ".ini", ".sp")

        if not io.fileExists(spFileString) then return end

        local tempSpFile = ac.INIConfig.load(spFileString)

        for _, spinner in ipairs(self._pitSpinners) do
                if spinner.index ~= -1 then
                        local preset = spinner.preset
                        local newValue = tempSpFile:get(
                                "PRESET_" .. preset,
                                spinner.id:gsub("_PRESET_" .. preset, ""),
                                spinner.default
                        )
                        spinner:setValue(spinner.id == "COMPOUND" and newValue + 1 or newValue)
                end
        end
end

function SetupManager:saveSetup(file)
        ac.saveCurrentSetup(file)

        local spFileString = string.replace(file, ".ini", ".sp")
        local tempSpFile = ac.INIConfig.load(spFileString)

        for _, spinner in ipairs(self._pitSpinners) do
                if spinner.index ~= -1 then
                        local preset = spinner.preset
                        local setValue = string.find(spinner.id, "COMPOUND") and spinner.value - 1 or spinner.value

                        tempSpFile:set("PRESET_" .. preset, spinner.id:gsub("_PRESET_" .. preset, ""), setValue)
                end
        end

        tempSpFile:save(spFileString)
end

function SetupManager:undo()
        if self._history_pos > 1 then
                self._history_pos = self._history_pos - 1
                self:LoadStuff(self._history[self._history_pos])
        end
end

function SetupManager:isUndoAvailable()
        if self._history_pos > 1 then return true end
        return false
end

function SetupManager:redo()
        if self._history_pos < #self._history then
                self._history_pos = self._history_pos + 1
                self:LoadStuff(self._history[self._history_pos])
        end
end

function SetupManager:isRedoAvailable()
        if self._history_pos < #self._history then return true end
        return false
end

function SetupManager:cleanUndoHistory()
        for i = #self._history, self._history_pos + 1, -1 do
                table.remove(self._history, i)
        end
end

function SetupManager:makeUndo()
        local tmp = ac.stringifyCurrentSetup()

        self:cleanUndoHistory()

        table.insert(self._history, self._history_pos + 1, tmp)
        self._history_pos = #self._history
end

function SetupManager:resetUndo()
        self._history = {}
        self._history_pos = 0
        self:makeUndo()
end
