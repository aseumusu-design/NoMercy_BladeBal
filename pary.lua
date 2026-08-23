-- COPY PATH REMOTE SKILL VIOLENCE DISTRICT
local function copy(t)
    if setclipboard then setclipboard(t) elseif toclipboard then toclipboard(t) end
end

local oldFire
oldFire = hookfunction(Instance.new("RemoteEvent").FireServer, function(r, ...)
    local p = r:GetFullName()
    print("Skill kepakai! Path: " .. p)
    copy(p)
    return oldFire(r, ...)
end)

local oldInvoke
oldInvoke = hookfunction(Instance.new("RemoteFunction").InvokeServer, function(r, ...)
    local p = r:GetFullName()
    print("Skill kepakai! Path: " .. p)
    copy(p)
    return oldInvoke(r, ...)
end)

print("Siap! Pakai skill kamu, nanti path remote otomatis ke copy.")
