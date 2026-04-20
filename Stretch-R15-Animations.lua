--[[ Made by MRGLUCKINGBALL & R_MP6

█▀ ▀█▀ █▀█ █▀▀ ▀█▀ █▀▀ █░█ █▀▀ █▀▄
▄█ ░█░ █▀▄ ██▄ ░█░ █▄▄ █▀█ ██▄ █▄▀

]]

------------------- SETTINGS -------------------

local KEY_MOVESET1 = Enum.KeyCode.Z
local BUTTON1_IMAGE_ON = "rbxassetid://93088560418548"   -- when custom animations active
local BUTTON1_IMAGE_OFF = "rbxassetid://132573142038191"  -- when custom animations disabled

local IdleAnimId = "rbxassetid://91348372558295"
local WalkAnimId = "rbxassetid://134010853417610"
local Move1AnimId = "rbxassetid://129469072457859"

local Move1Cooldown = 3

-- Move1 timing
local MOVE1_START_TIME = 6   -- seconds
local MOVE1_FIRST_DURATION = 2 -- first press
local MOVE1_SECOND_DURATION = 6 -- second press

------------------------------------------------

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

------------------------------------------------
-- SETUP FUNCTION
------------------------------------------------

local function Setup(char)
	local humanoid = char:WaitForChild("Humanoid")

	task.wait(0.2)
	local animate = char:FindFirstChild("Animate")
	if animate then animate.Disabled = true end

	------------------------------------------------
	-- BASE ANIMATIONS
	------------------------------------------------

	local idle = Instance.new("Animation")
	idle.AnimationId = IdleAnimId
	local idleTrack = humanoid:LoadAnimation(idle)
	idleTrack.Looped = true
	idleTrack.Priority = Enum.AnimationPriority.Movement

	local walk = Instance.new("Animation")
	walk.AnimationId = WalkAnimId
	local walkTrack = humanoid:LoadAnimation(walk)
	walkTrack.Looped = true
	walkTrack.Priority = Enum.AnimationPriority.Movement

	local customMovementEnabled = true

	------------------------------------------------
	-- BUTTON IMAGE UPDATE
	------------------------------------------------
	local btn -- will store mobile button

	local function UpdateButtonImage()
		if btn then
			if customMovementEnabled then
				btn.Image = BUTTON1_IMAGE_ON
			else
				btn.Image = BUTTON1_IMAGE_OFF
			end
		end
	end

	------------------------------------------------
	-- CUSTOM MOVEMENT FUNCTIONS
	------------------------------------------------

	local function enableCustomMovement()
		customMovementEnabled = true
		idleTrack:Play()
		if animate then animate.Disabled = true end
		UpdateButtonImage()
	end

	local function disableCustomMovement()
		customMovementEnabled = false
		idleTrack:Stop()
		walkTrack:Stop()
		if animate then animate.Disabled = false end
		UpdateButtonImage()
	end

	enableCustomMovement()

	humanoid.Running:Connect(function(speed)
		if not customMovementEnabled then return end
		if speed > 1 then
			if not walkTrack.IsPlaying then
				idleTrack:Stop()
				walkTrack:Play()
			end
		else
			if not idleTrack.IsPlaying then
				walkTrack:Stop()
				idleTrack:Play()
			end
		end
	end)

	------------------------------------------------
	-- MOVE1 ANIMATION
	------------------------------------------------

	local move1 = Instance.new("Animation")
	move1.AnimationId = Move1AnimId
	local move1Track = humanoid:LoadAnimation(move1)
	move1Track.Priority = Enum.AnimationPriority.Action

	local move1Ready = true
	local move1Toggled = false
	local isUsingMove = false

	local function PlayMove1()
		if not move1Ready or isUsingMove then return end
		isUsingMove = true
		move1Ready = false

		task.delay(Move1Cooldown, function()
			move1Ready = true
		end)

		move1Track:Stop()
		move1Track:Play()
		RunService.Heartbeat:Wait()

		if not move1Toggled then
			-- FIRST PRESS: start at 6s, play 2s
			move1Track.TimePosition = MOVE1_START_TIME
			disableCustomMovement()
			move1Toggled = true

			task.delay(MOVE1_FIRST_DURATION, function()
				if move1Track.IsPlaying then
					move1Track:Stop()
				end
				isUsingMove = false
			end)
		else
			-- SECOND PRESS: start at 0s, play 6s
			move1Track.TimePosition = 0

			task.delay(0.05, function()
				enableCustomMovement()
				move1Toggled = false
			end)

			task.delay(MOVE1_SECOND_DURATION, function()
				if move1Track.IsPlaying then
					move1Track:Stop()
				end
				isUsingMove = false
			end)
		end
	end

	------------------------------------------------
	-- INPUT
	------------------------------------------------

	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == KEY_MOVESET1 then
			PlayMove1()
		end
	end)

	PlayMove1Global = PlayMove1

	------------------------------------------------
	-- MOBILE BUTTON
	------------------------------------------------

	local function CreateButton(imageId, position, callback)
		local gui = player.PlayerGui:FindFirstChild("ScreenGui")
		if not gui then
			gui = Instance.new("ScreenGui")
			gui.Name = "ScreenGui"
			gui.ResetOnSpawn = false
			gui.Parent = player.PlayerGui
		end

		btn = Instance.new("ImageButton")
		btn.Size = UDim2.new(0, 90, 0, 90)
		btn.Position = position
		btn.Image = imageId
		btn.BackgroundTransparency = 1
		btn.Parent = gui
		btn.MouseButton1Click:Connect(callback)
	end

	CreateButton(BUTTON1_IMAGE_ON, UDim2.new(0.05, 0, 0.75, 0), function()
		if PlayMove1Global then PlayMove1Global() end
	end)
end

------------------------------------------------
-- CHARACTER LOAD
------------------------------------------------

player.CharacterAdded:Connect(Setup)
if player.Character then Setup(player.Character) end
