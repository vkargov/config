
#!/bin/sh

# command <=> alt
# control <=> capslock
xmodmap ~/.xmodmap

# enter becomes "control" when not released instantly
xcape -e 'Control_R=Return'

