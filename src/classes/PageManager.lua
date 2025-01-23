PageManager = class("PageManager")

function PageManager:initialize()
	self.pages = {}
	self.parentName = nil
	self.currentPage = nil
end

function PageManager:registerPage(name, parentName, page)
	self.pages[name] = page
	self.parentName = parentName

	if not parentName then
		self.currentPage = self.pages[name]
	end
end

function PageManager:setPage(name)
	if self.pages[name] then
		self.currentPage = self.pages[name]
	else
		ac.error(string.format("Page %s is not valid", name))
	end
end

function PageManager:draw()
	if self.currentPage then
		return self.currentPage.draw(self)
	end
end
