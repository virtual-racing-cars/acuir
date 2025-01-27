PageManager = class("PageManager")

function PageManager:initialize()
	self.pages = {}
	self.parentName = nil
	self.currentPage = nil
	self.currentPageName = nil

	self._history = {}
	self._history_pos = 0
end

function PageManager:registerPage(name, parentName, page)
	self.pages[name] = page
	self.parentName = parentName

	if not parentName then
		self.currentPage = self.pages[name]
		self.currentPageName = name
	end
end

function PageManager:setPage(name)
	if self.pages[name] then
		self.currentPage = self.pages[name]
		self.currentPageName = name
	else
		ac.error(string.format("Page %s is not valid", name))
	end
end

function PageManager:draw()
	if self.currentPage then
		return self.currentPage.draw(self)
	end
end

function PageManager:LoadStuff(name)
	self:setPage(name)
end

function PageManager:undo()
	if self._history_pos > 1 then
		self._history_pos = self._history_pos - 1
		self:LoadStuff(self._history[self._history_pos])
	end
end

function PageManager:isUndoAvailable()
	if self._history_pos > 1 then
		return true
	end
	return false
end

function PageManager:redo()
	if self._history_pos < #self._history then
		self._history_pos = self._history_pos + 1
		self:LoadStuff(self._history[self._history_pos])
	end
end

function PageManager:isRedoAvailable()
	if self._history_pos < #self._history then
		return true
	end
	return false
end

function PageManager:cleanUndoHistory()
	-- delete higher undo steps
	for i = #self._history, self._history_pos + 1, -1 do
		table.remove(self._history, i)
	end
end

function PageManager:makeUndo()
	local tmp = self.currentPageName

	self:cleanUndoHistory()

	table.insert(self._history, self._history_pos + 1, tmp)
	self._history_pos = #self._history
end

function PageManager:resetUndo()
	self._history = {}
	self._history_pos = 0
	self:makeUndo()
end
