xmodmap .xmodmap
if ! pgrep xcape >&/dev/null; then
  xcape -t 200 -e Control_R=Return
fi
if ! mountpoint -q ~/notes; then
  rclone mount --daemon 'dropbox:notes' ~/notes
fi
if ! mountpoint -q ~/ag; then
  rclone mount --daemon 'dropbox:ag' ~/ag
fi
if ! mountpoint -q ~/dokidoki; then
  (eval `ssh-agent`; ssh-add; rclone mount --daemon dokidoki: ~/dokidoki/)
fi