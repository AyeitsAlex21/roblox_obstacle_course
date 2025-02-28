print("fSWAffsFsZFGgzdesrgzdghxdzseghzsxedthzxdrhh")
local guiControllerModule = script.Parent.Parent:FindFirstChild("GuiController")
if guiControllerModule then
	print("GuiController found:", guiControllerModule.Name, guiControllerModule.ClassName)
else
	print("GuiController not found!")
end


local StarterPlayer = game:GetService("StarterPlayer")
local GuiController = require(script.Parent.Parent.GuiController)


local Gui = GuiController.Guis.Shop
local Frame = Gui.Frame
local Exit = Frame.Exit
local OpenButton = GuiController.Guis.Right.Frame.Buttons.Shop
print("Shop GUI:", Gui)
print("Exit Button:", Exit)
print("Open Button:", OpenButton)


local Local = {}
local Shared = {}

function Shared.OnStart()
    print("IM MOUSECLICKING")
    OpenButton.MouseButton1Click:Connect(Local.UpdateEnabled)
    Exit.MouseButton1Click:Connect(Local.UpdateEnabled)
	print("EXITING")
end

function Local.UpdateEnabled()
	print("Button clicked. Toggling UI...")
	if Gui:IsA("ScreenGui") then
		Gui.Enabled = not Gui.Enabled
		print("Toggled Enabled to:", Gui.Enabled)
	else
		Gui.Visible = not Gui.Visible
		print("Toggled Visible to:", Gui.Visible)
	end
end

Shared.OnStart()

return Shared