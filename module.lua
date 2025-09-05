--hello
local scripts = {}
function script.new_connection(type, func)
    return type:Connect(func)
end
return scripts
