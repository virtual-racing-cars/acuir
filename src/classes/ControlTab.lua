local ControlTab = class("ControlTab")

function ControlTab:initialize(name) self.name = name end

function ControlTab:addGroup(name)
        if not self.groups then
                self.groups = {}
                self.tabOrder = {}
        end

        table.insert(self.groups, { name = name, content = {} })
        table.insert(self.tabOrder, name)
end

function ControlTab:addControl(controlBinding)
        if controlBinding ~= nil then
                local tab = controlBinding.tab
                local tabIndex = table.indexOf(self.tabOrder, tab)

                if controlBinding.order ~= 0 then
                        self.groups[tabIndex].content[controlBinding.order] = controlBinding
                else
                        table.insert(self.groups[tabIndex].content, controlBinding)
                end
        end
end

return ControlTab
