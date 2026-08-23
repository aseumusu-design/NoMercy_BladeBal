-- [[ AUTO COPY PATH REMOTE SKILL VIOLENCE DISTRICT ]]
-- Memakai __namecall biar semua remote tanpa terkecuali ke-detect

local mt = getrawmetatable(game)
if not mt then
    print("Gagal dapat metatable!")
    return
end

setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = function(self, ...)
    local method = getnamecallmethod()
    
    -- Tangkap FireServer (RemoteEvent)
    if method == "FireServer" and self:IsA("RemoteEvent") then
        local path = self:GetFullName()
        print("🔴 [REMOTE EVENT] Path: " .. path)
        print("🟡 Data yang dikirim: ", ...)
        -- Copy ke clipboard
        if setclipboard then
            setclipboard(path)
        elseif toclipboard then
            toclipboard(path)
        end
        print("✅ Path sudah di-copy ke clipboard!")
    
    -- Tangkap InvokeServer (RemoteFunction)
    elseif method == "InvokeServer" and self:IsA("RemoteFunction") then
        local path = self:GetFullName()
        print("🔵 [REMOTE FUNCTION] Path: " .. path)
        print("🟡 Data yang dikirim: ", ...)
        if setclipboard then
            setclipboard(path)
        elseif toclipboard then
            toclipboard(path)
        end
        print("✅ Path sudah di-copy ke clipboard!")
    end
    
    -- Jalankan fungsi aslinya biar skill tetap kepakai
    return oldNamecall(self, ...)
end

print("🚀 SCRIPT AKTIF! Sekarang setiap kali kamu pakai skill apa pun,")
print("📋 path remote skill akan otomatis tercopy ke clipboard.")
print("📌 Cek console ini untuk lihat path-nya.")
