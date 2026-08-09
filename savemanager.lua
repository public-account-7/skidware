local a, b = game:GetService'HttpService', {}

do
    b.Folder = 'LinoriaLibSettings'
    b.Ignore = {}
    b.Custom = {}
    b.CurrentConfig = 'N/A'
    b.Parser = {
        Toggle = {
            Save = function(c, d)
                local e, f = pcall(function()
                    return {
                        type = 'Toggle',
                        idx = c,
                        value = d.Value,
                    }
                end)

                if not e then
                    warn(f)
                end

                return f
            end,
            Load = function(c, d)
                local e, f = pcall(function()
                    if Toggles[c] then
                        Toggles[c]:SetValue(d.value)
                    end
                end)

                if not e then
                    warn(f)
                end
            end,
        },
        Slider = {
            Save = function(c, d)
                local e, f = pcall(function()
                    return {
                        type = 'Slider',
                        idx = c,
                        value = tostring(d.Value),
                    }
                end)

                if not e then
                    warn(f)
                end

                return f
            end,
            Load = function(c, d)
                local e, f = pcall(function()
                    if Options[c] then
                        Options[c]:SetValue(d.value)
                    end
                end)

                if not e then
                    warn(f)
                end
            end,
        },
        Dropdown = {
            Save = function(c, d)
                local e, f = pcall(function()
                    return {
                        type = 'Dropdown',
                        idx = c,
                        value = d.Value,
                        mutli = d.Multi,
                    }
                end)

                if not e then
                    warn(f)
                end

                return f
            end,
            Load = function(c, d)
                local e, f = pcall(function()
                    if Options[c] then
                        Options[c]:SetValue(d.value)
                    end
                end)

                if not e then
                    warn(f)
                end
            end,
        },
        ColorPicker = {
            Save = function(c, d)
                local e, f = pcall(function()
                    return {
                        type = 'ColorPicker',
                        idx = c,
                        value = d.Value:ToHex(),
                        transparency = d.Transparency,
                    }
                end)

                if not e then
                    warn(f)
                end

                return f
            end,
            Load = function(c, d)
                local e, f = pcall(function()
                    if Options[c] then
                        Options[c]:SetValueRGB(Color3.fromHex(d.value), d.transparency)
                    end
                end)

                if not e then
                    warn(f)
                end
            end,
        },
        KeyPicker = {
            Save = function(c, d)
                local e, f = pcall(function()
                    return {
                        type = 'KeyPicker',
                        idx = c,
                        mode = d.Mode,
                        key = d.Value,
                    }
                end)

                if not e then
                    warn(f)
                end

                return f
            end,
            Load = function(c, d)
                local e, f = pcall(function()
                    if Options[c] then
                        Options[c]:SetValue{
                            d.key,
                            d.mode,
                        }
                    end
                end)

                if not e then
                    warn(f)
                end
            end,
        },
        Input = {
            Save = function(c, d)
                local e, f = pcall(function()
                    return {
                        type = 'Input',
                        idx = c,
                        text = d.Value,
                    }
                end)

                if not e then
                    warn(f)
                end

                return f
            end,
            Load = function(c, d)
                local e, f = pcall(function()
                    if Options[c] and type(d.text) == 'string' then
                        Options[c]:SetValue(d.text)
                    end
                end)

                if not e then
                    warn(f)
                end
            end,
        },
    }

    function b.AddCustom(c, d, e, f)
        c.Custom[d] = {
            get = e,
            set = f,
        }
    end
    function b.SetIgnoreIndexes(c, d)
        for e, f in next, d do
            c.Ignore[f] = true
        end
    end
    function b.Serialize(c, d)
        local e = typeof(d)

        if e == 'Color3' then
            return {
                __type = 'Color3',
                r = d.R,
                g = d.G,
                b = d.B,
            }
        elseif e == 'Vector3' then
            return {
                __type = 'Vector3',
                x = d.X,
                y = d.Y,
                z = d.Z,
            }
        elseif e == 'CFrame' then
            return {
                __type = 'CFrame',
                components = {
                    d:GetComponents(),
                },
            }
        elseif e == 'UDim2' then
            return {
                __type = 'UDim2',
                xs = d.X.Scale,
                xo = d.X.Offset,
                ys = d.Y.Scale,
                yo = d.Y.Offset,
            }
        elseif e == 'table' then
            local f = {}

            for g, h in pairs(d)do
                f[g] = c:Serialize(h)
            end

            return f
        end

        return d
    end
    function b.Deserialize(c, d)
        if type(d) ~= 'table' then
            return d
        end
        if d.__type == 'Color3' then
            return Color3.new(d.r, d.g, d.b)
        elseif d.__type == 'Vector3' then
            return Vector3.new(d.x, d.y, d.z)
        elseif d.__type == 'CFrame' then
            return CFrame.new(unpack(d.components))
        elseif d.__type == 'UDim2' then
            return UDim2.new(d.xs, d.xo, d.ys, d.yo)
        end

        local e = {}

        for f, g in pairs(d)do
            e[f] = c:Deserialize(g)
        end

        return e
    end
    function b.SetFolder(c, d)
        c.Folder = d

        c:BuildFolderTree()
    end
    function b.Save(c, d)
        if (not d) then
            return false, 'no config file is selected'
        end

        local e, f = c.Folder .. '/settings/' .. d .. '.json', {
            objects = {},
            lastupd = os.time(),
        }

        for g, h in next, Toggles do
            if c.Ignore[g] then
                continue
            end

            local i = c.Parser[h.Type].Save(g, h)

            if i then
                table.insert(f.objects, i)
            end
        end
        for g, h in next, Options do
            if not c.Parser[h.Type] then
                continue
            end
            if c.Ignore[g] then
                continue
            end

            local i = c.Parser[h.Type].Save(g, h)

            if i then
                table.insert(f.objects, i)
            end
        end
        for g, h in next, c.Custom do
            local i, j = pcall(h.get)

            if i then
                table.insert(f.objects, {
                    type = 'Custom',
                    idx = g,
                    value = c:Serialize(j),
                })
            end
        end

        local g, h = pcall(a.JSONEncode, a, f)

        if not g then
            return false, 'failed to encode data'
        end

        writefile(e, h)

        return true
    end
    function b.GetJsonCFG(c)
        local d = {
            objects = {},
            lastupd = os.time(),
        }

        for e, f in next, Toggles do
            if c.Ignore[e] then
                continue
            end

            local g = c.Parser[f.Type].Save(e, f)

            if g then
                table.insert(d.objects, g)
            end
        end
        for e, f in next, Options do
            if not c.Parser[f.Type] then
                continue
            end
            if c.Ignore[e] then
                continue
            end

            local g = c.Parser[f.Type].Save(e, f)

            if g then
                table.insert(d.objects, g)
            end
        end
        for e, f in next, c.Custom do
            local g, h = pcall(f.get)

            if g then
                table.insert(d.objects, {
                    type = 'Custom',
                    idx = e,
                    value = c:Serialize(h),
                })
            end
        end

        local e, f = pcall(a.JSONEncode, a, d)

        if not e then
            return false, 'failed to encode data'
        end

        return f
    end
    function b.Delete(c, d)
        if (not d) then
            return false, 'no config file is selected'
        end

        local e = c.Folder .. '/settings/' .. d .. '.json'

        if not isfile(e) then
            return false, 'config file does not exist'
        end

        delfile(e)

        return true
    end
    function b.Load(c, d)
        if not d then
            return false, 'no config file is selected'
        end

        local e = c.Folder .. '/settings/' .. d .. '.json'

        if not isfile(e) then
            return false, 'invalid file'
        end

        local f, g = pcall(a.JSONDecode, a, readfile(e))

        if not f then
            return false, 'decode error'
        end

        for h, i in next, g.objects do
            if i.type == 'Custom' then
                local j = c.Custom[i.idx]

                if j then
                    local k = c:Deserialize(i.value)

                    pcall(j.set, k)
                end

                continue
            end

            local j = c.Parser[i.type]

            if j then
                j.Load(i.idx, i)
            else
                warn(('[option: %s] is not found, skipping...'):format(tostring(i.type)))
            end
        end

        local h = g.lastupd

        if h then
            local i = os.date('%Y-%m-%d %H:%M:%S', h)

            b.LastUpdatedLabel:SetText('Last Updated: ' .. i)
        else
            b.LastUpdatedLabel:SetText'Last Updated: nil'
        end

        return true
    end
    function b.IgnoreThemeSettings(c)
        c:SetIgnoreIndexes{
            'BackgroundColor',
            'MainColor',
            'AccentColor',
            'OutlineColor',
            'FontColor',
            'ThemeManager_ThemeList',
            'ThemeManager_CustomThemeList',
            'ThemeManager_CustomThemeName',
        }
    end
    function b.BuildFolderTree(c)
        local d = {
            c.Folder,
            c.Folder .. '/themes',
            c.Folder .. '/settings',
        }

        for e = 1, #d do
            local f = d[e]

            if not isfolder(f) then
                makefolder(f)
            end
        end
    end
    function b.RefreshConfigList(c)
        local d, e = listfiles(c.Folder .. '/settings'), {}

        for f = 1, #d do
            local g = d[f]

            if g:sub(-5) == '.json' then
                local h = g:find('.json', 1, true)
                local i, j = h, g:sub(h, h)

                while j ~= '/' and j ~= '\\' and j ~= '' do
                    h = h - 1
                    j = g:sub(h, h)
                end

                if j == '/' or j == '\\' then
                    table.insert(e, g:sub(h + 1, i - 1))
                end
            end
        end

        return e
    end
    function b.SetLibrary(c, d)
        c.Library = d
    end
    function b.LoadAutoloadConfig(c)
        if isfile(c.Folder .. '/settings/autoload.txt') then
            local d = readfile(c.Folder .. '/settings/autoload.txt')
            local e, f = c:Load(d)

            if not e then
                return c.Library:Notify('Failed to load autoload config: ' .. f)
            end

            b.CurrentConfig = d

            c.Library:Notify(string.format('Auto loaded config %q', d))
            c.Library:UpdateDependencyBoxes()
        end
    end
    function b.BuildConfigSection(c, d)
        assert(c.Library, 'Must set SaveManager.Library')

        local e = d:AddRightGroupbox'Configuration'

        e:AddInput('SaveManager_ConfigName', {
            Text = 'Config name',
        })
        e:AddDropdown('SaveManager_ConfigList', {
            Text = 'Config list',
            Values = c:RefreshConfigList(),
            AllowNull = true,
        })
        e:AddDivider()
        e:AddButton('Create config', function()
            local f = Options.SaveManager_ConfigName.Value

            if f:gsub(' ', '') == '' then
                return c.Library:Notify('Invalid config name (empty)', 2)
            end

            local g, h = c:Save(f)

            if not g then
                return c.Library:Notify('Failed to save config: ' .. h)
            end

            c.Library:Notify(string.format('Created config %q', f))
            Options.SaveManager_ConfigList:SetValues(c:RefreshConfigList())
            Options.SaveManager_ConfigList:SetValue(nil)
        end):AddButton('Load config', function()
            local f = Options.SaveManager_ConfigList.Value
            local g, h = c:Load(f)

            if not g then
                return c.Library:Notify('Failed to load config: ' .. h)
            end

            b.CurrentConfig = f

            c.Library:Notify(string.format('Loaded config %q', f))
            c.Library:UpdateDependencyBoxes()
        end)
        e:AddButton('Overwrite config', function()
            local f = Options.SaveManager_ConfigList.Value
            local g, h = c:Save(f)

            if not g then
                return c.Library:Notify('Failed to overwrite config: ' .. h)
            end

            c.Library:Notify(string.format('Overwrote config %q', f))
        end)
        e:AddButton('Delete config', function()
            local f = Options.SaveManager_ConfigList.Value
            local g, h = c:Delete(f)

            if not g then
                return c.Library:Notify('Failed to delete config: ' .. h)
            end

            Options.SaveManager_ConfigList:SetValues(c:RefreshConfigList())
            Options.SaveManager_ConfigList:SetValue(nil)
            c.Library:Notify(string.format('Deleted config %q', f))
        end)
        e:AddButton('Refresh list', function()
            Options.SaveManager_ConfigList:SetValues(c:RefreshConfigList())
            Options.SaveManager_ConfigList:SetValue(nil)
        end)
        e:AddButton('Set as autoload', function()
            local f = Options.SaveManager_ConfigList.Value

            writefile(c.Folder .. '/settings/autoload.txt', f)
            b.AutoloadLabel:SetText('Current autoload config: ' .. f)
            c.Library:Notify(string.format('Set %q to auto load', f))
        end)

        b.AutoloadLabel = e:AddLabel('Current autoload config: none', true)
        b.LastUpdatedLabel = e:AddLabel('Last Updated: nil', true)

        if isfile(c.Folder .. '/settings/autoload.txt') then
            local f = readfile(c.Folder .. '/settings/autoload.txt')

            b.AutoloadLabel:SetText('Current autoload config: ' .. f)
        end

        b:SetIgnoreIndexes{
            'SaveManager_ConfigList',
            'SaveManager_ConfigName',
        }
    end

    b:BuildFolderTree()
end

return b
