#!/bin/bash

original_window=`xdotool getactivewindow`
xdotool click 1
xdotool windowactivate $original_window
