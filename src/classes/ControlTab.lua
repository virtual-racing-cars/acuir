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
                local tabIndex = table.indexOf(self.tabOrder, controlBinding.tab)

                if not tabIndex then return end

                if controlBinding.order == 0 then
                        table.insert(self.groups[tabIndex].content, controlBinding)
                elseif tabIndex then
                        self.groups[tabIndex].content[controlBinding.order] = controlBinding
                end
        end
end

return ControlTab
