# TODO
# For whatever reason it doesn't work correctly as xinitrc.
# I need to investigate the cause and merge the 2 files together.
xbindkeys && xcape -e 'Control_R=Return'
xinput set-prop "SynPS/2 Synaptics TouchPad" "Synaptics Finger" 50 90 255 # After some testing, this seems to make no difference.
xinput set-prop 13 "Synaptics Noise Cancellation" 15 15 # This seems to be the right value

# Mindfulness bell thing
n bash -c 'i=0; while true; do date; if [[ $i -eq 0 ]]; then notify-send "$(cat ~/derp/bell/quotes.txt | grep -o "^[^#]*" | shuf -n 1)"; fi; mpv --really-quiet ~/derp/bell/bells/thinhChuong.wav; sleep 300; i=$((($i+1)%3)); done'
