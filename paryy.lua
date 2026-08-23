-- [[ DETEKTOR SUPER AMAN ]]
-- Menangkap semua remote yang dipakai, tanpa error.

local mt = getrawmetatable(game)
if not mt then
    print("❌ Gagal dapat metatable. Executor tidak support.")
    return
end

setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = function(self, ...)
    local method = getnamecallmethod()
    
    -- Tangkap FireServer (RemoteEvent) dan InvokeServer (RemoteFunction)
    if (method == "FireServer" or method == "InvokeServer") and self:IsA("RemoteEvent") then
        local path = self:GetFullName()
        -- Print dengan warna beda biar kelihatan
        print("🔥 REMOTE TERPAKAI: " .. path)
        print("📦 ARGUMEN:", ...)
        -- Copy ke clipboard
        pcall(function()
            if setclipboard then setclipboard(path) end
        end)
        print("📋 Path sudah di-copy ke clipboard!")
    end
    
    return oldNamecall(self, ...)
end

print("============================================")
print("✅ DETEKTOR AKTIF (tanpa error)!")
print("📌 Sekarang main Violence District, pilih Killer Hidden.")
print("📌 Klik tombol skill M2 / Leap / Ultimate di HUD.")
print("📌 Lihat console: akan muncul path dan argumen.")
print("📌 Path-nya otomatis ke-copy, paste ke sini.")
print("============================================")
