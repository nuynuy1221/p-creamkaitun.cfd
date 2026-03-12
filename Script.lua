repeat task.wait() until game:IsLoaded()
task.wait(5)

-- =========================
-- CONFIG (อ่านจากภายนอก)
-- =========================

local config = getgenv().CONFIG or {}

local KEY = config.KEY or "NO_KEY"

local SERVER = "https://p-creamkaitun.cfd/update"
local COMMAND_SERVER = "https://p-creamkaitun.cfd/command"
local SEND_DELAY = 20

-- =========================
-- SERVICES
-- =========================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
repeat task.wait() until player

local playerGui = player:WaitForChild("PlayerGui",60)

-- =========================
-- GET REQUEST FUNCTION
-- =========================

local function getRequest()

return syn and syn.request
or http_request
or request
or (fluxus and fluxus.request)

end

-- =========================
-- HELPER
-- =========================

local function toNumber(str)

if not str then return 0 end

str = tostring(str)
str = str:gsub("[^%d.]", "")

local firstDot = str:find("%.")

if firstDot then
str = str:sub(1, firstDot) .. str:sub(firstDot+1):gsub("%.", "")
end

return tonumber(str) or 0

end

-- =========================
-- MAP
-- =========================

local function getMap()

local place = game.PlaceId

if place == 16146832113 then
return "Lobby"
elseif place == 16277809958 then
return "Farm"
else
return "Unknown"
end

end

-- =========================
-- LEVEL
-- =========================

local function getLevel()

for _, n in ipairs({"Level","level","PlayerLevel","Player_Level"}) do

local v = player:GetAttribute(n)

if v ~= nil then
return tonumber(v) or toNumber(v)
end

end

local ok, levelObj = pcall(function()
return playerGui.HUD.Main.Level.Level
end)

if ok and levelObj and levelObj.Text then
return toNumber(levelObj.Text)
end

return 0

end

-- =========================
-- PRESENTS
-- =========================

local function getPresents()

local v = player:GetAttribute("Presents26")

if v ~= nil then
return tonumber(v) or toNumber(v)
end

local ls = player:FindFirstChild("leaderstats")

if ls then

for _,obj in ipairs(ls:GetChildren()) do

if obj.Name:lower():find("present") then
return tonumber(obj.Value) or toNumber(obj.Value)
end

end

end

return 0

end

-- =========================
-- COMMAND
-- =========================

local function checkCommand()

pcall(function()

local req = getRequest()
if not req then return end

local url = COMMAND_SERVER.."?key="..KEY.."&account="..player.Name

local response = req({
Url = url,
Method = "GET"
})

if response and response.Body then

local result = HttpService:JSONDecode(response.Body)

if result.cmd == "rejoin" then
player:Kick("You have been kicked from Website.")
end

end

end)

end

-- =========================
-- TRAIT COUNT
-- =========================

local function getTraitCount()

local possibleNames = {
"TraitRerolls","traitRerolls","TraitReroll",
"Rerolls","RerollCount","TraitRerollCount","TraitTokens"
}

for _,name in ipairs(possibleNames) do

local ok,v = pcall(function()
return player:GetAttribute(name)
end)

if ok and v ~= nil then
return tonumber(v) or 0
end

end

return 0

end


-- =========================
-- ICE QUEEN
-- =========================

local function hasIceQueen()

if game.PlaceId ~= 16277809958 then
return false
end

local units

pcall(function()
units = playerGui.Windows.Units.Holder.Main.Units
end)

if not units then return false end

for _,uuid in ipairs(units:GetChildren()) do

local ok,label = pcall(function()
return uuid.Container.Holder.Main.UnitName
end)

if ok and label then

local name = (label.ContentText or label.Text or ""):gsub("%s+$","")

if name == "Ice Queen (Release)" then
return true
end

end

end

return false

end


-- =========================
-- MEMORIA
-- =========================

local function hasIceQueenMemoria()

if game.PlaceId ~= 16146832113 then
return false
end

local items

pcall(function()
items = playerGui.Windows.GlobalInventory.Holder.LeftContainer.FakeScrollingFrame.Items:GetChildren()
end)

if not items then return false end

for _,group in ipairs(items) do

for _,uuid in ipairs(group:GetChildren()) do

local ok,label = pcall(function()
return uuid.Container.Holder.Main.MemoriaName
end)

if ok and label then

local name = (label.ContentText or label.Text or ""):gsub("%s+$","")

if name == "Ice Queen's Rest" then
return true
end

end

end

end

return false

end

-- =========================
-- SEND DATA
-- =========================

local data = {

key = KEY,

username = player.Name,
robloxUsername = player.Name,
displayName = player.DisplayName,

level = getLevel(),
presents = getPresents(),

map = getMap(),
placeId = game.PlaceId,
jobId = game.JobId,

trait = getTraitCount(),
iceQueen = hasIceQueen(),
memoria = hasIceQueenMemoria()

}

-- =========================
-- LOOP
-- =========================

while true do

sendData()
checkCommand()

task.wait(SEND_DELAY)

end
