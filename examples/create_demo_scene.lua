-- Optional MANUAL test fixture. Run once from Roblox Studio's Command Bar.
-- Creates only a small, anchored demo scene under Workspace.
-- Delete Workspace/PerformanceAnalyzer_Demo afterwards.

local workspaceService = game:GetService("Workspace")
local previous = workspaceService:FindFirstChild("PerformanceAnalyzer_Demo")
if previous then
    error("PerformanceAnalyzer_Demo already exists. Delete it before rerunning.")
end

local model = Instance.new("Model")
model.Name = "PerformanceAnalyzer_Demo"
model.Parent = workspaceService

local anchor = Instance.new("Part")
anchor.Name = "ParticleAndLightHolder"
anchor.Anchored = true
anchor.Size = Vector3.new(4, 1, 4)
anchor.Position = Vector3.new(0, 12, 0)
anchor.Parent = model

local emitter = Instance.new("ParticleEmitter")
emitter.Name = "HighRateTestEmitter"
emitter.Enabled = true
emitter.Rate = 220
emitter.Lifetime = NumberRange.new(4, 5)
emitter.Parent = anchor

local light = Instance.new("PointLight")
light.Name = "ShadowTestLight"
light.Enabled = true
light.Shadows = true
light.Range = 15
light.Parent = anchor

print("Demo created. Select PerformanceAnalyzer_Demo in Explorer, then Scan selection.")
print("Expect at least PARTICLE_RATE and PARTICLE_ESTIMATE findings.")
print("Delete Workspace/PerformanceAnalyzer_Demo when finished.")
