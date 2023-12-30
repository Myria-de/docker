#! /bin/bash
rm /tmp/.X99-lock
if pgrep -x "Xvfb" >/dev/null
then
   echo "Already running"
   exit 0
else
echo "Start Xvfb"
Xvfb :99 -ac -listen tcp -screen 0 1400x1050x24 &
sleep 3
/usr/bin/fluxbox -display :99 -screen 0 &
sleep 3
x11vnc -noxdamage -ncache 10 -forever -display :99.0 -passwd ${X11VNC_PASSWORD:-password}
#-forever
fi
