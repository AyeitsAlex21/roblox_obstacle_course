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
    Gui.Enabled = not Gui.Enabled
end

return Shared