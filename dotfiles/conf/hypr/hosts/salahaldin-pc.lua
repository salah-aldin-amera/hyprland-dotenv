-- Host: salahaldin-pc (main desktop, 192.168.1.201)
--
-- Four monitors, two GPUs, rkvm server, UPS on USB.

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "HDMI-A-1", mode = "1920x1080",     position = "0x0",     scale = 1 }) -- main
hl.monitor({ output = "DP-3",     mode = "1920x1080",     position = "1920x0",  scale = 1 }) -- right
hl.monitor({ output = "DP-1",     mode = "1920x1080",     position = "0x-1080", scale = 1 }) -- top
hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@144", position = "0x-1080", scale = 1 }) -- top (Gigabyte 144Hz)

-------------
---- GPU ----
-------------

-- Multi-GPU: pin primary to the card driving the 2 HP monitors
-- (PCI 01:00.0 -> card1). 03:00.0 -> card0.
--
-- NOTE: AQ_DRM_DEVICES splits on ':', so by-path names (pci-0000:01:00.0)
-- break. Use cardN nodes.
--
-- This is host-specific: a single-GPU box must not set it, or Hyprland will
-- fail to find the named node.
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card0")

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("kdeconnectd")
    hl.exec_cmd("nextcloud --background")

    -- glance: cargo-installed, so not in PATH for a Wayland session
    hl.exec_cmd(os.getenv("HOME") .. "/.cargo/bin/glance watch")
end)

-- glance drag picker
hl.bind("SUPER + G", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.cargo/bin/glance drag"))
