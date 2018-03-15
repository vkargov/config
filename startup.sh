# TODO
# For whatever reason it doesn't work correctly as xinitrc.
# I need to investigate the cause and merge the 2 files together.
xcape -e 'Control_R=Return' # && xbindkeys
xinput set-prop "SynPS/2 Synaptics TouchPad" "Synaptics Finger" 50 90 255 # After some testing, this seems to make no difference.
xinput set-prop 13 "Synaptics Noise Cancellation" 15 15 # This seems to be the right value

# Make gnome usability a little bit less terrible
gsettings set org.gnome.shell.overrides edge-tiling false

# Mindfulness bell thing
n bash -c 'i=0; while true; do date; if [[ $i -eq 0 ]]; then notify-send "$(cat ~/derp/bell/quotes.txt | grep -o "^[^#]*" | shuf -n 1)"; fi; mpv --really-quiet ~/derp/bell/bells/thinhChuong.wav; sleep 300; i=$((($i+1)%3)); done'

# Don't flip the screen after plugging in a PS3 controller. (Now I've seen everything.)
gsettings set org.gnome.settings-daemon.peripherals.touchscreen orientation-lock true
