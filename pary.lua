-- [[ DETEKTOR REMOTE SKILL SEJATI ]]
-- Menangkap SEMUA FireServer dari manapun, print path + argumen.

local function hookAllRemoteEvents(parent)
    for _, obj in ipairs(parent:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            if not obj._hooked then
                obj._hooked = true
                local old = obj.FireServer
                obj.FireServer = function(self, ...)
                    local path = self:GetFullName()
                    print("🔥 REMOTE TERPAKAI: " .. path)
                    print("📦 ARGUMEN:", ...)
                    -- Copy path ke clipboard
                    if setclipboard then setclipboard(path) end
                    print("📋 Path sudah di-copy ke clipboard!")
                    return old(self, ...)
                end
            end
        end
    end
end

-- Hook semua RemoteEvent di seluruh game
hookAllRemoteEvents(game)
game.DescendantAdded:Connect(function(child)
    if child:IsA("RemoteEvent") then
        hookAllRemoteEvents(child)
    end
end)

print("============================================")
print("✅ DETEKTOR AKTIF!")
print("📌 Sekarang main game, pakai Killer Hidden.")
print("📌 Klik tombol skill M2 / Leap / Ultimate di layar.")
print("📌 Lihat console: akan muncul path dan argumen.")
print("📌 Path-nya otomatis ke-copy, paste ke sini.")
print("============================================")
