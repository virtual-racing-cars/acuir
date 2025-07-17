local audio = require("audio")
local banner = require("ui.cui.banner")
local button = require("ui.cui.button")
local callback = require("callback")
local checkbox = require("ui.cui.checkbox")
local combo = require("ui.cui.combo")
local cursor = require("ui.cui.cursor")
local dialog = require("ui.cui.dialog")
local input = require("ui.cui.input")
local scale = require("ui.cui.scale")
local settings = require("settings")
local slider = require("ui.cui.slider")
local text = require("ui.cui.text")
local window = require("ui.cui.window")
local sim = ac.getSim()

local vec2Temp1 = vec2()
local vec2Temp2 = vec2()

local cui = {}

cui.scale = scale.get

cui.menuBanner = banner.menu

cui.setCursor = cursor.set
cui.setCursorX = cursor.setX
cui.setCursorY = cursor.setY
cui.offsetCursor = cursor.offset
cui.offsetCursorX = cursor.offsetX
cui.offsetCursorY = cursor.offsetY
cui.snapCursor = cursor.snap

cui.button = button.button
cui.settingsButton = button.settings
cui.modalButton = button.modal
cui.selectable = button.selectable
cui.menuButton = button.menu
cui.windowTabButton = button.windowTab
cui.bindingButton = button.binding
cui.bindingAxleButton = button.bindingAxle
cui.driveButton = button.drive
cui.iconButton = button.icon
cui.iconTopBarButton = button.iconTopBar
cui.emojiButton = button.emoji
cui.smallButton = button.small
cui.smallIconButton = button.smallIcon
cui.setupSelectButton = button.setupSelect
cui.treeNodeChildButton = button.treeNodeChild
cui.treeNodeButton = button.treeNode

cui.textWriteWrapped = text.writeWrapped
cui.textWrite = text.write
cui.textWriteAligned = text.writeAligned
cui.textWriteBodyAligned = text.writeBodyAligned

cui.inputText = input.text

cui.combo = combo.box

cui.checkbox = checkbox.checkbox

cui.spinner = slider.spinner
cui.slider = slider.slider

cui.modalDialog = dialog.modal
cui.promptShutdownACDialog = dialog.promptShutdownAC

cui.childWindow = window.child
cui.contentWindow = window.content
cui.pushWindow = window.push
cui.popWindow = window.pop
cui.pushContentWindow = window.pushContent
cui.popContentWindow = window.popContent
cui.pushWidgetWindow = window.pushWidget
cui.popWidgetWindow = window.popWidget
cui.pushFullWindow = window.pushFull
cui.pushFittedWindow = window.pushFitted

cui.menuPanAvailable = false
cui.menuZoomAvailable = false

function cui.globalDisable() return callback.dialog ~= nil end

function cui.dummy(x, y) ui.dummy(vec2Temp1:set(x * cui.scale(), y * cui.scale())) end

return cui
