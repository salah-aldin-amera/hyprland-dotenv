pactl load-module module-loopback source=mono_stereo_mic latency_msec=50

ipactl load-module module-remap-source master=YOUR_MIC_NAME channels=2 channel_map=front-left,front-right source_name=mono_stereo_mic

pactl unload-module module-loopback
