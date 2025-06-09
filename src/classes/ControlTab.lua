local ControlTab = class("ControlTab")

function ControlTab:initialize(name) self.name = name end

function ControlTab:addGroup(name)
        if not self.tabs then
                self.tabs = {}
                self.tabOrder = {}
        end

        table.insert(self.tabs, { name = name, content = {} })
        table.insert(self.tabOrder, name)
end

function ControlTab:addControl(controlBinding)
        if controlBinding ~= nil then
                local tab = controlBinding.tab
                local tabIndex = table.indexOf(self.tabOrder, tab)

                if controlBinding.order ~= 0 then
                        self.tabs[tabIndex].content[controlBinding.order] = controlBinding
                else
                        table.insert(self.tabs[tabIndex].content, controlBinding)
                end
        end
end

return ControlTab
