local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local savedPosition = nil

local Window = Rayfield:CreateWindow({
   Name = "DreamSolutions",
   LoadingTitle = "Loading Interface",
   LoadingSubtitle = "Steal Games",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = false
   }
})

local Tab = Window:CreateTab("Movement")

local noclipToggle = Tab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "noclip",
   Callback = function(Value)
      if Value then
         enableNoclip()
      else
         disableNoclip()
      end
   end
})

local jumpToggle = Tab:CreateToggle({
   Name = "Super Jump",
   CurrentValue = false,
   Flag = "jump",
   Callback = function(Value)
      if Value then
         enableSuperJump()
      else
         disableSuperJump()
      end
   end
})

local invisToggle = Tab:CreateToggle({
   Name = "Invisibility",
   CurrentValue = false,
   Flag = "invis",
   Callback = function(Value)
      local char = player.Character
      if not char then return end
      if Value then
         applyInvisibility(char, true)
      else
         applyInvisibility(char, false)
      end
   end
})

local positionSection = Tab:CreateSection("Position System")

local saveBtn = Tab:CreateButton({
   Name = "Save Current Position",
   Callback = function()
      local char = player.Character
      if char and char:FindFirstChild("HumanoidRootPart") then
         savedPosition = char.HumanoidRootPart.CFrame
         Rayfield:Notify({
            Title = "Position Saved",
            Content = "Location saved successfully",
            Duration = 3
         })
      end
   end
})

local loadBtn = Tab:CreateButton({
   Name = "Teleport to Saved Position",
   Callback = function()
      local char = player.Character
      if char and char:FindFirstChild("HumanoidRootPart") then
         if savedPosition then
            char.HumanoidRootPart.CFrame = savedPosition
            Rayfield:Notify({
               Title = "Teleported",
               Content = "Position restored successfully",
               Duration = 3
            })
         else
            Rayfield:Notify({
               Title = "Error",
               Content = "No saved position found",
               Duration = 3
            })
         end
      end
   end
})

local noclipEnabled = false
local noclipConnection

function setCollision(char, state)
   for _, part in ipairs(char:GetDescendants()) do
      if part:IsA("BasePart") then
         part.CanCollide = not state
      end
   end
end

function enableNoclip()
   if noclipEnabled then return end
   noclipEnabled = true
   
   noclipConnection = RunService.Stepped:Connect(function()
      local char = player.Character
      if not char then return end
      setCollision(char, true)
   end)
end

function disableNoclip()
   noclipEnabled = false
   if noclipConnection then
      noclipConnection:Disconnect()
      noclipConnection = nil
   end
   local char = player.Character
   if char then
      setCollision(char, false)
   end
end

local jumpEnabled = false
local originalJumpPower = 50

function enableSuperJump()
   if jumpEnabled then return end
   jumpEnabled = true
   
   local char = player.Character
   if char then
      local humanoid = char:FindFirstChildOfClass("Humanoid")
      if humanoid then
         originalJumpPower = humanoid.JumpPower
         humanoid.JumpPower = 100
      end
   end
end

function disableSuperJump()
   jumpEnabled = false
   
   local char = player.Character
   if char then
      local humanoid = char:FindFirstChildOfClass("Humanoid")
      if humanoid then
         humanoid.JumpPower = originalJumpPower
      end
   end
end

local transparencyBackup = {}

function applyInvisibility(char, enabled)
   for _, obj in ipairs(char:GetDescendants()) do
      if obj:IsA("BasePart") or obj:IsA("Decal") then
         if enabled then
            transparencyBackup[obj] = obj.Transparency
            obj.Transparency = 1
         else
            if transparencyBackup[obj] ~= nil then
               obj.Transparency = transparencyBackup[obj]
            else
               obj.Transparency = 0
            end
         end
      elseif obj:IsA("Accessory") and obj.Handle then
         local handle = obj.Handle
         if enabled then
            transparencyBackup[handle] = handle.Transparency
            handle.Transparency = 1
         else
            if transparencyBackup[handle] ~= nil then
               handle.Transparency = transparencyBackup[handle]
            else
               handle.Transparency = 0
            end
         end
      end
   end
end

player.CharacterAdded:Connect(function(char)
   if jumpEnabled then
      wait(1)
      local humanoid = char:FindFirstChildOfClass("Humanoid")
      if humanoid then
         humanoid.JumpPower = 100
      end
   end
end)

player.CharacterRemoving:Connect(function()
   if noclipEnabled then disableNoclip() end
end)