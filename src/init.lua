ac.setWindowOpen("main", true)
-- ac.store("adv_setup_open", 0)

setupINI = ac.INIConfig.carData(0, "setup.ini")

tabs = {}

for k, v in pairs(setupINI.sections) do
	table.insert(tabs, setupINI:get(k, "TAB", ""))
	table.removeItem(tabs, "")
end

tabs = table.distinct(tabs)
table.removeItem(tabs, "")
table.sort(tabs)
table.removeItem(tabs, "ELECTRONICS")
table.removeItem(tabs, "TYRES")
table.removeItem(tabs, "FUEL")
table.insert(tabs, 1, "ELECTRONICS")
table.insert(tabs, 1, "FUEL")
table.insert(tabs, 1, "TYRES")
table.insert(tabs, 1, "GEARS")
table.insert(tabs, 1, "PITSTOP STRATEGY")
-- table.insert(tabs, 1, "SETUP I/O")
ac.log(tabs)
