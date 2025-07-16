local setupapps = {}

local function sandboxedRequire(directory, module)
        local env = { script = {} }
        env._G = env

        env.require = function(name)
                if string.find(name, "shared") then return require(name) end
                local chunk, err = loadfile(directory .. "\\" .. name:gsub("%.", "\\") .. ".lua")
                if not chunk then error("sandboxed require failed: " .. err) end
                setfenv(chunk, env)
                return chunk()
        end

        setmetatable(env, { __index = _G })

        local chunk = assert(loadfile(module))
        setfenv(chunk, env)
        chunk()

        env.package.path = env.package.path .. ";" .. directory

        return env.script
end

local luaAppsDir = ac.getFolder(ac.FolderID.ACAppsLua)

-- ac.onFolderChanged(luaAppsDir)

local function scanApp(appName, appDirectory)
        local appManifest = appDirectory .. "\\manifest.ini"

        if not io.fileExists(appManifest) then return end

        local appManifestINI = ac.INIConfig.load(appManifest, ac.INIFormat.Extended)

        for _, section in appManifestINI:iterate("WINDOW") do
                local windowFlags = appManifestINI:get(section, "FLAGS", {})
                if table.contains(windowFlags, "SETUP_INLINE") then
                        package.add("..\\%s" % appName)
                        local name = appManifestINI:get(section, "NAME", appName)

                        if name ~= "Setup Exchange" then
                                setupapps[name] = {
                                        inline = true,
                                        script = sandboxedRequire(
                                                appDirectory,
                                                string.format("%s\\%s.lua", appDirectory, appName)
                                        ),
                                        setupWindow = appManifestINI:get(section, "FUNCTION_MAIN", "windowMain"),
                                }
                        end
                elseif table.contains(windowFlags, "SETUP") or table.contains(windowFlags, "SETUP_HIDDEN") then
                end
        end
end

local function scanLuaApps()
        io.scanDir(luaAppsDir, function(dirName)
                local appDir = luaAppsDir .. "\\" .. dirName

                if io.dirExists(appDir) then scanApp(dirName, appDir) end
        end)
end

scanLuaApps()

return setupapps
