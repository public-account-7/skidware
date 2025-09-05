--hello
local scripts = {}
function scripts.new_connection(type, func)
    return type:Connect(func)
end
return scripts
