-- [[ SPAM SEMUA SKILL HIDDEN 100x (Termasuk Ultimate) ]]
-- Copas ke executor, Execute, lalu main.

local RS = game:GetService("ReplicatedStorage")
local folder = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("Killers") and RS.Remotes.Killers:FindFirstChild("Hidden")

if not folder then
    print("❌ Folder Hidden tidak ditemukan! Pastikan kamu pakai Killer Hidden.")
    return
end

-- Kumpulkan semua RemoteEvent di folder Hidden
local remotes = {}
for _, obj in ipairs(folder:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        table.insert(remotes, obj)
    end
end

if #remotes == 0 then
    print("❌ Tidak ada RemoteEvent ditemukan.")
    return
end

print("✅ Ditemukan " .. #remotes .. " remote skill Hidden.")

-- Spam masing-masing remote 100 kali
for _, remote in ipairs(remotes) do
    local name = remote.Name
    print("🔥 Memulai spam: " .. name)
    for i = 1, 100 do
        pcall(function()
            remote:FireServer()
        end)
        task.wait(0.02) -- delay super cepat
    end
    print("✅ Selesai spam " .. name .. " 100x")
end

print("🎉 SEMUA SKILL (termasuk ULTIMATE) SUDAH DI-SPAM 100 KALI!")
