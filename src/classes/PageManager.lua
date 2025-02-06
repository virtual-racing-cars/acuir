PageManager = class("PageManager")

function PageManager:initialize()
	self.pages = {}
	self.currentPage = nil
	self.currentPageName = nil
	self.parentName = nil

	self._history = {}
	self._history_pos = 0
end

function PageManager:registerPage(name, page)
	self.pages[name] = page
end

function PageManager:setPage(name, skipUndo)
	if self.pages[name] then
		self.currentPage = self.pages[name]
		self.currentPageName = name
		if not skipUndo then
			self:makeUndo()
		end
	else
		ac.error(string.format("Page %s is not valid", name))
		ac.fuck()
	end
end

function PageManager:setParentPageName(name)
	self:resetUndo(true)
	self.parentName = name
end

function PageManager:draw()
	if self.currentPage then
		return self.currentPage.draw(self)
	end
end

function PageManager:LoadStuff(name)
	self:setPage(name, true)
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

function PageManager:resetUndo(skipUndo)
	self._history = {}
	self._history_pos = 0

	if not skipUndo then
		self:makeUndo()
	end
end
