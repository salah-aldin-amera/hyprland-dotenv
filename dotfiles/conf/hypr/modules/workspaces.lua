-- Workspace binds
local mainMod = "SUPER"

-- Switch workspaces with mainMod + [0-9], move active window with + SHIFT
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Cycle next/previous workspace
hl.bind(mainMod .. " + ALT + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + ALT + left",  hl.dsp.focus({ workspace = "e-1" }))

-- Additional workspaces
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("~/.config/hypr/scripts/new_workspace.sh"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("~/.config/hypr/scripts/new_workspace_and_move.sh"))
