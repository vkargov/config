# TODO
# For whatever reason it doesn't work correctly as xinitrc.
# I need to investigate the cause and merge the 2 files together.
xmodmap ~/.xmodmap && xbindkeys && xcape -e 'Control_R=Return'
xinput set-prop "SynPS/2 Synaptics TouchPad" "Synaptics Finger" 50 90 255
