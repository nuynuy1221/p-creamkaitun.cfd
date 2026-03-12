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

local request =
syn and syn.request or
http_request or
request or
fluxus and fluxus.request

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

local url = COMMAND_SERVER.."?key="..KEY.."&account="..player.Name

local response = request({
Url = url,
Method = "GET"
})

if response and response.Body then

local result = HttpService:JSONDecode(response.Body)

if result.cmd == "rejoin" then
game.Players.LocalPlayer:Kick("You have been kicked form Website.")
end

end

end

-- =========================
-- SEND DATA
-- =========================

local function sendData()

local data = {

key = KEY,

username = player.Name,
robloxUsername = player.Name,
displayName = player.DisplayName,

level = getLevel(),
presents = getPresents()

}

pcall(function()

request({

Url = SERVER,
Method = "POST",

Headers = {
["Content-Type"] = "application/json"
},

Body = HttpService:JSONEncode(data)

})

end)

end

-- =========================
-- LOOP
-- =========================

while true do

sendData()
checkCommand()

task.wait(SEND_DELAY)

end
