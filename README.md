# SmallUI
Open sourced.  Usable. Not everywhere tho


usage 

```
local smallUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/AzxerMan000/SmallUI/main/Source.lua"))()
local Win = smallUI:Init({Title = "smallUI", Size = UDim2.new(0, 650, 0, 450)})

local Main = Win:CreateTab("Main", "🏠")
Main:CreateLabel("Welcome!")
Main:CreateButton("Click Me", function() print("Clicked!") end)
Main:CreateToggle("Speed", false, function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v and 100 or 16 end)
Main:CreateSlider("Jump", 50, 200, 50, function(v) game.Players.LocalPlayer.Character.Humanoid.JumpPower = v end)

Win:Notify("Loaded!", "smallUI ready!", 3, "Success") ```
