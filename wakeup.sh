xsetwacom set "Wacom Intuos S 2 Pad pad" Button 3 key "F9" # drawning/cursor switch
xsetwacom set "Wacom Intuos S 2 Pad pad" Button 1 key "Shift" # Eraser
xsetwacom set "Wacom Intuos S 2 Pad pad" Button 9 key "Shift F9" # Clear
xsetwacom set "Wacom Intuos S 2 Pad pad" Button 8 key "F10" # Undo
sudo rivalcfg -b os -c 000000
# (while true; do color=`printf '#%.2x%.2x%.2x' $((RANDOM%255)) $((RANDOM%255)) $((RANDOM%255))`; echo $color; sudo rivalcfg -b os -c $color; read; done)
# for color exploration
# 050101 is dark pink-ish, but it sucks
