function unholdblob()
    local char = game.Players.LocalPlayer.Character
    if not char then return nil end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) then return nil end

    local inv = workspace:FindFirstChild(services.me.Name .. "SpawnedInToys")
    if not inv then return nil end

    local blobman = nil
    for _, v in ipairs(inv:GetChildren()) do
        if v.Name == "CreatureBlobman" or v.Name == "UnHoldableBlobman" then
            blobman = v
            break
        end
    end

    if not blobman then
        pcall(function()
            ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(
                "CreatureBlobman", hrp.CFrame, Vector3.zero
            )
        end)
        local waited = 0
        repeat
            RunService.Heartbeat:Wait()
            waited = waited + 0.016
            for _, v in ipairs(inv:GetChildren()) do
                if v.Name == "CreatureBlobman" then blobman = v; break end
            end
        until blobman or waited >= 3
    end

    if not blobman then return nil end

    local seat = blobman:FindFirstChild("VehicleSeat")
    if not seat then return nil end

    if seat.Occupant and seat.Occupant.Parent == char then
        blobman.Name = "UnHoldableBlobman"
        blobman:SetAttribute("UnHoldableBlobmanSetup", true)
        return blobman
    end

    hum.Health = 0
    task.wait(1)

    local t = tick()
    local firstExec = false

    while tick() - t < 6 do
        if not unholdableBlobmanEnabled then return nil end
        services.rse.Heartbeat:Wait()

        if not blobman or not blobman.Parent then return nil end

        local currentChar = game.Players.LocalPlayer.Character
        if currentChar and currentChar ~= char then
            char = currentChar
            hum = char:FindFirstChildOfClass("Humanoid")
            hrp = char:FindFirstChild("HumanoidRootPart")
            firstExec = false
        end

        if seat.Occupant and seat.Occupant.Parent == char then
            blobman.Name = "UnHoldableBlobman"
            blobman:SetAttribute("UnHoldableBlobmanSetup", true)
            return blobman
        end

        if hum and hrp then
            hum.EvaluateStateMachine = false
            hum.BreakJointsOnDeath = false

            if not firstExec then
                pcall(function()
                    services.rs.CharacterEvents.RagdollRemote:FireServer(hrp, math.huge)
                end)
                firstExec = true
            end

            if not hum.SeatPart then hum.Sit = false end
            pcall(function() seat:Sit(hum) end)
            pcall(function()
                fireproximityprompt(seat:FindFirstChildOfClass("ProximityPrompt"))
            end)
            hum.EvaluateStateMachine = true
        end
    end

    return nil
end
