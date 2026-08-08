-- ydotool-driven mouse control from the keyboard.
-- Required by machine/pc.lua only; the touchpad covers this on a laptop.
--
-- Needs the ydotoold daemon running (install.sh enables it) and the user in
-- the input group.
local socket = "YDOTOOL_SOCKET=$XDG_RUNTIME_DIR/.ydotool_socket"

-- NOTE: the old SUPER+ALT+arrow mousemove binds are dropped — they collided with
-- workspace next/prev in modules/workspaces.lua. CTRL+ALT+arrows below cover movement.

-- Repeatable movement (fires while held)
hl.bind("CTRL + ALT + left",  hl.dsp.exec_cmd(socket .. " ydotool mousemove -x -20 -y 0"), { repeating = true })
hl.bind("CTRL + ALT + right", hl.dsp.exec_cmd(socket .. " ydotool mousemove -x 20 -y 0"),  { repeating = true })
hl.bind("CTRL + ALT + up",    hl.dsp.exec_cmd(socket .. " ydotool mousemove -x 0 -y -20"), { repeating = true })
hl.bind("CTRL + ALT + down",  hl.dsp.exec_cmd(socket .. " ydotool mousemove -x 0 -y 20"),  { repeating = true })

-- Clicks
hl.bind("SUPER + ALT + Return",  hl.dsp.exec_cmd(socket .. " ydotool click 0xC0")) -- Left Click
hl.bind("SUPER + ALT + Shift_R", hl.dsp.exec_cmd(socket .. " ydotool click 0xC1")) -- Right Click
hl.bind("SUPER + ALT + Menu",    hl.dsp.exec_cmd(socket .. " ydotool click 0xC2")) -- Middle Click
