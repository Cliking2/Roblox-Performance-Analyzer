-- Roblox Performance Analyzer v1.0.0
-- Copyright (c) 2026 Roblox Performance Analyzer contributors
-- MIT licensed. This is a read-only Studio plugin: it NEVER edits your place.
-- Save this Script as a Local Plugin in Roblox Studio; do not run it as a game Script.

assert(plugin, "Roblox Performance Analyzer must be run as a Roblox Studio plugin")

local Selection = game:GetService("Selection")
local Workspace = game:GetService("Workspace")

local TOOLBAR_NAME = "Performance Analyzer"
local MAX_VISIBLE_FINDINGS = 250
local UI_FONT = Enum.Font.Gotham
local UI_BOLD = Enum.Font.GothamBold

-- These values are REVIEW TRIGGERS, not official Roblox engine limits.
local LIMITS = {
    emitterRate = 150,
    estimatedParticles = 500,
    shadowLights = 12,
    dynamicParts = 200,
    parts = 5000,
    activeEmitters = 80,
    decalsAndTextures = 600,
    preciseMeshes = 50,
    preciseRenderMeshes = 100,
}

local COLORS = {
    background = Color3.fromRGB(20, 24, 33),
    panel = Color3.fromRGB(31, 37, 49),
    button = Color3.fromRGB(55, 74, 105),
    buttonHover = Color3.fromRGB(68, 92, 131),
    text = Color3.fromRGB(238, 242, 249),
    muted = Color3.fromRGB(180, 191, 207),
    warning = Color3.fromRGB(246, 193, 100),
    info = Color3.fromRGB(131, 195, 245),
    border = Color3.fromRGB(59, 70, 89),
}

local function create(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function roundCorners(gui, radius)
    create("UICorner", { CornerRadius = UDim.new(0, radius) }, gui)
end

local function safeFullName(instance)
    local success, name = pcall(function()
        return instance:GetFullName()
    end)
    return success and name or "[destroyed instance]"
end

local function shorten(value, maxLength)
    if #value <= maxLength then
        return value
    end
    return string.sub(value, 1, maxLength - 3) .. "..."
end

local toolbar = plugin:CreateToolbar(TOOLBAR_NAME)
local toggleButton = toolbar:CreateButton(
    "PerformanceAnalyzerToggle",
    "Open or close the read-only performance inspector",
    "",
    "Performance Analyzer"
)

local widgetInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Right,
    false,
    false,
    480,
    600,
    320,
    370
)
local widget = plugin:CreateDockWidgetPluginGuiAsync("RobloxPerformanceAnalyzer_Main_1", widgetInfo)
widget.Title = "Roblox Performance Analyzer"

local rootGui = create("Frame", {
    Name = "Root",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLORS.background,
    BorderSizePixel = 0,
}, widget)

create("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 14, 0, 12),
    Size = UDim2.new(1, -28, 0, 30),
    Font = UI_BOLD,
    TextSize = 19,
    Text = "PERFORMANCE ANALYZER",
    TextColor3 = COLORS.text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, rootGui)

create("TextLabel", {
    Name = "Subheading",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 14, 0, 43),
    Size = UDim2.new(1, -28, 0, 35),
    Font = UI_FONT,
    TextSize = 12,
    TextWrapped = true,
    Text = "Static heuristics only. No FPS measurement or automatic changes.",
    TextColor3 = COLORS.muted,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
}, rootGui)

local actions = create("Frame", {
    Name = "Actions",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 14, 0, 82),
    Size = UDim2.new(1, -28, 0, 38),
}, rootGui)

create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, actions)

local function actionButton(name, text, width, order)
    local button = create("TextButton", {
        Name = name,
        LayoutOrder = order,
        Size = UDim2.new(width, -4, 1, 0),
        BackgroundColor3 = COLORS.button,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        TextColor3 = COLORS.text,
        Font = UI_BOLD,
        TextSize = 12,
        Text = text,
    }, actions)
    roundCorners(button, 6)
    return button
end

local scanWorkspaceButton = actionButton("ScanWorkspace", "Scan Workspace", 0.38, 1)
local scanSelectionButton = actionButton("ScanSelection", "Scan selection", 0.35, 2)
local reportButton = actionButton("ToggleReport", "Report", 0.27, 3)

local summary = create("TextLabel", {
    Name = "Summary",
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 14, 0, 132),
    Size = UDim2.new(1, -28, 0, 66),
    TextColor3 = COLORS.muted,
    Font = UI_FONT,
    TextSize = 12,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    Text = "Choose a scan above. Click any finding to select its object in Explorer.",
}, rootGui)
roundCorners(summary, 6)
create("UIPadding", {
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10),
}, summary)

local findingsScroll = create("ScrollingFrame", {
    Name = "Findings",
    Position = UDim2.new(0, 14, 0, 210),
    Size = UDim2.new(1, -28, 1, -224),
    BackgroundColor3 = COLORS.background,
    BorderSizePixel = 0,
    ScrollBarThickness = 5,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollingDirection = Enum.ScrollingDirection.Y,
}, rootGui)

local listLayout = create("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, findingsScroll)
create("UIPadding", {
    PaddingRight = UDim.new(0, 7),
    PaddingBottom = UDim.new(0, 8),
}, findingsScroll)

local reportView = create("TextBox", {
    Name = "PlainTextReport",
    Visible = false,
    Position = UDim2.new(0, 14, 0, 210),
    Size = UDim2.new(1, -28, 1, -224),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
    ClearTextOnFocus = false,
    MultiLine = true,
    TextEditable = false,
    TextWrapped = false,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    Font = Enum.Font.Code,
    TextSize = 12,
    TextColor3 = COLORS.text,
    Text = "No report yet. Scan Workspace or selection first.\n\nUse Ctrl+A / Ctrl+C to copy this text when selected.",
}, rootGui)
roundCorners(reportView, 6)
create("UIPadding", {
    PaddingTop = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8),
}, reportView)

local showingReport = false
local scanVersion = 0
local currentFindings = {}
local lastResult = nil

local function showReport(visible)
    showingReport = visible
    reportView.Visible = visible
    findingsScroll.Visible = not visible
    reportButton.Text = visible and "Findings" or "Report"
end

local function clearFindings()
    for _, child in ipairs(findingsScroll:GetChildren()) do
        if child:IsA("TextButton") or child.Name == "EmptyState" then
            child:Destroy()
        end
    end
end

local function findingCard(finding, order)
    local button = create("TextButton", {
        Name = "Finding_" .. tostring(order),
        LayoutOrder = order,
        Size = UDim2.new(1, -2, 0, 83),
        BackgroundColor3 = COLORS.panel,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Text = "",
    }, findingsScroll)
    roundCorners(button, 7)
    create("UIStroke", {
        Color = COLORS.border,
        Thickness = 1,
    }, button)

    local accent = finding.severity == "REVIEW" and COLORS.warning or COLORS.info
    create("TextLabel", {
        Name = "Headline",
        Position = UDim2.new(0, 10, 0, 6),
        Size = UDim2.new(1, -20, 0, 20),
        BackgroundTransparency = 1,
        Text = finding.severity .. "  |  " .. finding.title,
        TextColor3 = accent,
        TextSize = 12,
        Font = UI_BOLD,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, button)
    create("TextLabel", {
        Name = "Detail",
        Position = UDim2.new(0, 10, 0, 27),
        Size = UDim2.new(1, -20, 0, 34),
        BackgroundTransparency = 1,
        Text = finding.detail,
        TextColor3 = COLORS.text,
        TextSize = 11,
        Font = UI_FONT,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }, button)
    create("TextLabel", {
        Name = "Path",
        Position = UDim2.new(0, 10, 1, -18),
        Size = UDim2.new(1, -20, 0, 14),
        BackgroundTransparency = 1,
        Text = shorten(finding.path, 115),
        TextColor3 = COLORS.muted,
        TextSize = 10,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, button)
    button.MouseButton1Click:Connect(function()
        if finding.instance and finding.instance.Parent then
            Selection:Set({ finding.instance })
        else
            summary.Text = "This instance no longer exists. Run the scan again."
        end
    end)
end

local function calculateStats()
    return {
        instances = 0,
        parts = 0,
        unanchoredParts = 0,
        preciseCollisionMeshes = 0,
        preciseRenderMeshes = 0,
        emitters = 0,
        activeEmitters = 0,
        shadowLights = 0,
        decalsTextures = 0,
    }
end

local function makeResult(scope)
    return {
        scope = scope,
        stats = calculateStats(),
        findings = {},
        suppressed = 0,
    }
end

local function addFinding(result, severity, ruleId, title, detail, instance)
    local findings = result.findings
    if #findings >= MAX_VISIBLE_FINDINGS then
        result.suppressed += 1
        return
    end
    table.insert(findings, {
        severity = severity,
        ruleId = ruleId,
        title = title,
        detail = detail,
        instance = instance,
        path = safeFullName(instance),
    })
end

local function inspectInstance(result, instance)
    local stats = result.stats
    stats.instances += 1

    if instance:IsA("BasePart") and not instance:IsA("Terrain") then
        stats.parts += 1
        if not instance.Anchored then
            stats.unanchoredParts += 1
        end
    end

    if instance:IsA("MeshPart") then
        if instance.CollisionFidelity == Enum.CollisionFidelity.PreciseConvexDecomposition then
            stats.preciseCollisionMeshes += 1
            addFinding(result, "REVIEW", "MESH_COLLISION", "Precise mesh collision",
                "CollisionFidelity uses precise decomposition. Check whether lower fidelity fits this asset.", instance)
        end
        if instance.RenderFidelity == Enum.RenderFidelity.Precise then
            stats.preciseRenderMeshes += 1
        end
    end

    if instance:IsA("ParticleEmitter") then
        stats.emitters += 1
        if instance.Enabled then
            stats.activeEmitters += 1
            local rate = instance.Rate
            local upperBound = rate * instance.Lifetime.Max
            if rate >= LIMITS.emitterRate then
                addFinding(result, "REVIEW", "PARTICLE_RATE", "High emitter rate",
                    string.format("Rate %.0f/s. Review visual cost on a low-end device.", rate), instance)
            end
            if upperBound >= LIMITS.estimatedParticles then
                addFinding(result, "REVIEW", "PARTICLE_ESTIMATE", "Large particle upper estimate",
                    string.format("Rate × max Lifetime ≈ %.0f (not a measured live particle count).", upperBound), instance)
            end
        end
    end

    if instance:IsA("Light") and instance.Enabled and instance.Shadows then
        stats.shadowLights += 1
    end

    if instance:IsA("Decal") or instance:IsA("Texture") then
        stats.decalsTextures += 1
    end
end

local function finishInspection(result, representative)
    local stats = result.stats
    if stats.parts >= LIMITS.parts then
        addFinding(result, "INFO", "PART_COUNT", "Large part count",
            string.format("%d BaseParts in scope. Profile actual rendering and physics before optimizing.", stats.parts), representative)
    end
    if stats.unanchoredParts >= LIMITS.dynamicParts then
        addFinding(result, "REVIEW", "UNANCHORED", "Many unanchored parts",
            string.format("%d unanchored BaseParts. Check which really need physics simulation.", stats.unanchoredParts), representative)
    end
    if stats.shadowLights >= LIMITS.shadowLights then
        addFinding(result, "REVIEW", "SHADOW_LIGHTS", "Many shadow-enabled lights",
            string.format("%d enabled lights cast shadows. Inspect scene lighting and mobile performance.", stats.shadowLights), representative)
    end
    if stats.activeEmitters >= LIMITS.activeEmitters then
        addFinding(result, "INFO", "EMITTER_COUNT", "Many enabled emitters",
            string.format("%d enabled ParticleEmitters. Consider visibility, placement and overlapping effects.", stats.activeEmitters), representative)
    end
    if stats.decalsTextures >= LIMITS.decalsAndTextures then
        addFinding(result, "INFO", "DECAL_COUNT", "Many decals and textures",
            string.format("%d Decal / Texture instances. Review whether visible density affects rendering.", stats.decalsTextures), representative)
    end
    if stats.preciseCollisionMeshes >= LIMITS.preciseMeshes then
        addFinding(result, "INFO", "PRECISE_COLLISION_TOTAL", "Many precise collision meshes",
            string.format("%d precise collision meshes found. Check unnecessary precision first.", stats.preciseCollisionMeshes), representative)
    end
    if stats.preciseRenderMeshes >= LIMITS.preciseRenderMeshes then
        addFinding(result, "REVIEW", "PRECISE_RENDER_TOTAL", "Many precise render meshes",
            string.format("%d meshes use RenderFidelity.Precise. Consider automatic LOD when suitable.", stats.preciseRenderMeshes), representative)
    end
    table.sort(result.findings, function(a, b)
        if a.severity ~= b.severity then
            return a.severity == "REVIEW"
        end
        if a.ruleId ~= b.ruleId then
            return a.ruleId < b.ruleId
        end
        return a.path < b.path
    end)
end

local function buildReport(result)
    local s = result.stats
    local lines = {
        "ROBLOX PERFORMANCE ANALYZER - STATIC REPORT",
        "Scope: " .. result.scope,
        "",
        "NOT an FPS benchmark or proof of a performance defect.",
        "Rule thresholds are review heuristics, not official Roblox limits.",
        "Dynamic scripts, networking, device FPS and GPU timings are NOT analyzed.",
        "",
        "COUNTS",
        "Instances inspected: " .. s.instances,
        "BaseParts: " .. s.parts,
        "Unanchored BaseParts: " .. s.unanchoredParts,
        "MeshParts with precise collision: " .. s.preciseCollisionMeshes,
        "MeshParts with precise rendering: " .. s.preciseRenderMeshes,
        "ParticleEmitters: " .. s.emitters,
        "Enabled emitters: " .. s.activeEmitters,
        "Enabled lights with shadows: " .. s.shadowLights,
        "Decals and Textures: " .. s.decalsTextures,
        "",
        "FINDINGS (first " .. tostring(MAX_VISIBLE_FINDINGS) .. " maximum)",
    }
    if #result.findings == 0 then
        table.insert(lines, "No configured heuristics triggered. This does NOT mean the game is optimized.")
    end
    for index, f in ipairs(result.findings) do
        table.insert(lines, string.format("%d. [%s] %s (%s)", index, f.severity, f.title, f.ruleId))
        table.insert(lines, "   " .. f.path)
        table.insert(lines, "   " .. f.detail)
    end
    if result.suppressed > 0 then
        table.insert(lines, string.format("... %d additional finding(s) omitted from display/report.", result.suppressed))
    end
    table.insert(lines, "")
    table.insert(lines, "Next: verify candidates in Studio's MicroProfiler, performance stats, and Device Emulator.")
    return table.concat(lines, "\n")
end

local function render(result)
    lastResult = result
    currentFindings = result.findings
    clearFindings()
    findingsScroll.CanvasPosition = Vector2.new(0, 0)
    for index, finding in ipairs(currentFindings) do
        findingCard(finding, index)
    end
    summary.Text = string.format(
        "%s  |  %d objects | %d parts | %d findings%s\nClick a finding to select an instance. Heuristics only.",
        shorten(result.scope, 42), result.stats.instances, result.stats.parts,
        #result.findings, result.suppressed > 0 and (" (+" .. result.suppressed .. " hidden)") or ""
    )
    reportView.Text = buildReport(result)
    if #currentFindings == 0 then
        local empty = create("TextLabel", {
            Name = "EmptyState",
            Size = UDim2.new(1, -5, 0, 72),
            BackgroundTransparency = 1,
            TextColor3 = COLORS.muted,
            Font = UI_FONT,
            TextSize = 13,
            TextWrapped = true,
            Text = "No configured review triggers found. This is not an FPS measurement or a clean bill of health.",
        }, findingsScroll)
        empty.LayoutOrder = 1
    end
end

local function scanRoots(roots, scope)
    scanVersion += 1
    local thisScan = scanVersion
    summary.Text = "Scanning " .. scope .. "..."
    local result = makeResult(scope)
    local visited = {}
    local inspected = 0
    for _, scanRoot in ipairs(roots) do
        local descendants = scanRoot:GetDescendants()
        table.insert(descendants, 1, scanRoot)
        for _, instance in ipairs(descendants) do
            if thisScan ~= scanVersion then
                return
            end
            if not visited[instance] then
                visited[instance] = true
                inspectInstance(result, instance)
                inspected += 1
                if inspected % 1000 == 0 then
                    summary.Text = string.format("Scanning %s... %d objects checked", scope, inspected)
                    task.wait()
                end
            end
        end
    end
    if thisScan ~= scanVersion then
        return
    end
    finishInspection(result, roots[1])
    render(result)
end

scanWorkspaceButton.MouseButton1Click:Connect(function()
    task.spawn(scanRoots, { Workspace }, "Workspace")
end)

scanSelectionButton.MouseButton1Click:Connect(function()
    local selected = Selection:Get()
    if #selected == 0 then
        summary.Text = "Select one or more objects in Explorer first, then choose Scan selection."
        return
    end
    task.spawn(scanRoots, selected, #selected == 1 and safeFullName(selected[1]) or (tostring(#selected) .. " selected roots"))
end)

reportButton.MouseButton1Click:Connect(function()
    showReport(not showingReport)
    if showingReport and lastResult then
        reportView.Text = buildReport(lastResult)
    end
end)

toggleButton.Click:Connect(function()
    widget.Enabled = not widget.Enabled
end)

widget:GetPropertyChangedSignal("Enabled"):Connect(function()
    toggleButton:SetActive(widget.Enabled)
end)

plugin.Unloading:Connect(function()
    scanVersion += 1
end)

showReport(false)
