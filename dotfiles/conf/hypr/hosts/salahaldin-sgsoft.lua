-- Host: salahaldin-sgsoft (192.168.1.202)
--
-- Single GPU (only /dev/dri/card1 present), so no AQ_DRM_DEVICES pinning —
-- setting it here would name a node that does not exist.
--
-- rkvm client: receives keyboard/mouse from salahaldin-pc. Switch with
-- left-alt + left-ctrl on the server side.

------------------
---- MONITORS ----
------------------

-- Auto-detect: preferred mode, auto placement. Replace with explicit
-- hl.monitor() calls once the real display layout is known —
-- `hyprctl monitors all` lists the outputs.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
