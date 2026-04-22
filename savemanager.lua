--[[
get better get skidware xd
]]
local httpService = game:GetService('HttpService')

local SaveManager = {} do
	SaveManager.Folder = 'LinoriaLibSettings'
	SaveManager.Ignore = {}
	SaveManager.CurrentConfig = "N/A"
	SaveManager.Custom = {}

	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object)
				local ok, result = pcall(function()
					return { type = 'Toggle', idx = idx, value = object.Value }
				end)
				if not ok then warn(result) end
				return result
			end,
			Load = function(idx, data)
				local ok, err = pcall(function()
					if Toggles[idx] then
						Toggles[idx]:SetValue(data.value)
					end
				end)
				if not ok then warn(err) end
			end,
		},

		Slider = {
			Save = function(idx, object)
				local ok, result = pcall(function()
					return { type = 'Slider', idx = idx, value = tostring(object.Value) }
				end)
				if not ok then warn(result) end
				return result
			end,
			Load = function(idx, data)
				local ok, err = pcall(function()
					if Options[idx] then
						Options[idx]:SetValue(data.value)
					end
				end)
				if not ok then warn(err) end
			end,
		},

		Dropdown = {
			Save = function(idx, object)
				local ok, result = pcall(function()
					return { type = 'Dropdown', idx = idx, value = object.Value, mutli = object.Multi }
				end)
				if not ok then warn(result) end
				return result
			end,
			Load = function(idx, data)
				local ok, err = pcall(function()
					if Options[idx] then
						Options[idx]:SetValue(data.value)
					end
				end)
				if not ok then warn(err) end
			end,
		},

		ColorPicker = {
			Save = function(idx, object)
				local ok, result = pcall(function()
					return {
						type = 'ColorPicker',
						idx = idx,
						value = object.Value:ToHex(),
						transparency = object.Transparency
					}
				end)
				if not ok then warn(result) end
				return result
			end,
			Load = function(idx, data)
				local ok, err = pcall(function()
					if Options[idx] then
						Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
					end
				end)
				if not ok then warn(err) end
			end,
		},

		KeyPicker = {
			Save = function(idx, object)
				local ok, result = pcall(function()
					return {
						type = 'KeyPicker',
						idx = idx,
						mode = object.Mode,
						key = object.Value
					}
				end)
				if not ok then warn(result) end
				return result
			end,
			Load = function(idx, data)
				local ok, err = pcall(function()
					if Options[idx] then
						Options[idx]:SetValue({ data.key, data.mode })
					end
				end)
				if not ok then warn(err) end
			end,
		},

		Input = {
			Save = function(idx, object)
				local ok, result = pcall(function()
					return { type = 'Input', idx = idx, text = object.Value }
				end)
				if not ok then warn(result) end
				return result
			end,
			Load = function(idx, data)
				local ok, err = pcall(function()
					if Options[idx] and type(data.text) == 'string' then
						Options[idx]:SetValue(data.text)
					end
				end)
				if not ok then warn(err) end
			end,
		},
	}

	function SaveManager:AddCustom(name, get, set)
		self.Custom[name] = { get = get, set = set }
	end

	function SaveManager:Serialize(value)
		local t = typeof(value)

		if t == "Color3" then
			return { __type = "Color3", r = value.R, g = value.G, b = value.B }

		elseif t == "Vector3" then
			return { __type = "Vector3", x = value.X, y = value.Y, z = value.Z }

		elseif t == "CFrame" then
			return { __type = "CFrame", components = { value:GetComponents() } }

		elseif t == "UDim2" then
			return {
				__type = "UDim2",
				xs = value.X.Scale, xo = value.X.Offset,
				ys = value.Y.Scale, yo = value.Y.Offset
			}

		elseif t == "table" then
			local new = {}
			for k, v in pairs(value) do
				new[k] = self:Serialize(v)
			end
			return new
		end

		return value
	end

	function SaveManager:Deserialize(value)
		if type(value) ~= "table" then
			return value
		end

		if value.__type == "Color3" then
			return Color3.new(value.r, value.g, value.b)

		elseif value.__type == "Vector3" then
			return Vector3.new(value.x, value.y, value.z)

		elseif value.__type == "CFrame" then
			return CFrame.new(unpack(value.components))

		elseif value.__type == "UDim2" then
			return UDim2.new(value.xs, value.xo, value.ys, value.yo)
		end

		local new = {}
		for k, v in pairs(value) do
			new[k] = self:Deserialize(v)
		end
		return new
	end

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function SaveManager:Save(name)
		if not name then
			return false, 'no config file is selected'
		end

		local fullPath = self.Folder .. '/settings/' .. name .. '.json'

		local data = {
			objects = {},
			lastupd = os.time()
		}

		for idx, toggle in next, Toggles do
			if self.Ignore[idx] then continue end
			table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
		end

		for idx, option in next, Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end
			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end	

		for name, custom in next, self.Custom do
			local ok, result = pcall(custom.get)
			if ok then
				table.insert(data.objects, {
					type = "Custom",
					idx = name,
					value = self:Serialize(result)
				})
			end
		end

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return false, 'failed to encode data'
		end

		writefile(fullPath, encoded)
		return true
	end

	function SaveManager:Load(name)
		if not name then
			return false, "no config file is selected"
		end

		local file = self.Folder .. "/settings/" .. name .. ".json"
		if not isfile(file) then
			return false, "invalid file"
		end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then
			return false, "decode error"
		end

		for _, option in next, decoded.objects do
			if option.type == "Custom" then
				local custom = self.Custom[option.idx]
				if custom then
					local value = self:Deserialize(option.value)
					pcall(custom.set, value)
				end
				continue
			end

			local parser = self.Parser[option.type]
			if parser then
				parser.Load(option.idx, option)
			end
		end

		local time = decoded.lastupd
		if time then
			local formatted = os.date("%Y-%m-%d %H:%M:%S", time)
			if self.LastUpdatedLabel then
				self.LastUpdatedLabel:SetText("Last Updated: " .. formatted)
			end
		end

		return true
	end

	function SaveManager:BuildFolderTree()
		local paths = {
			self.Folder,
			self.Folder .. '/themes',
			self.Folder .. '/settings'
		}

		for _, str in ipairs(paths) do
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	SaveManager:BuildFolderTree()
end

return SaveManager
