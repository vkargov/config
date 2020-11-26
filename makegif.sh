#!/usr/bin/env bash

# Convert mp4 into gif.
# Inspired by https://engineering.giphy.com/how-to-make-gifs-with-ffmpeg/.
# TODO better argument handling

bad_syntax() {
    echo "makegif [-t time] movie.mp4 movie.gif"
    exit 1
}

while [[ $# -gt 0 ]]; do
    key=$1
    case $key in
	-t)
	    FF_PARAMS="${FF_PARAMS} -t ${2}"
	    shift
	    shift
	    ;;
	*)
	    break
	    ;;
    esac
done

if [[ $# -ne 2 ]]; then
    bad_syntax
fi

ffmpeg $FF_PARAMS -i "${1}" -filter_complex "[0:v] fps=12,scale=w=480:h=-1,split [a][b];[a] palettegen=stats_mode=single [p];[b][p] paletteuse=new=1" "${2}"
