#!/bin/bash

# ADD FLICKR TAGS TO ME and watch the magic...
TAGS=("wildlife" "seascape" "landscape" "storm" "weather" "cityscape" "desert" "ocean" "microscopic" "space" "galaxy" "computer" "animals" "water" "rain" "fire" "flame" "sky" "clouds" "plants" "ice" "geology" "astronomy")

# Get platform
OS=$(uname)

IMGPATH="/Users/esaron/Pictures/flickrWallpapers/_current"
MINWID=1920
MINHT=1080
function join { local IFS="$1"; shift; echo "$*"; }
URL="loremflickr.com/g/$MINWID/$MINHT/$(join , ${TAGS[@]})"
mv "$IMGPATH/_current" "$IMGPATH/_previous"
echo "------------------Getting wallpaper from Flickr---------------"
curl -o "$IMGPATH" "$URL"
# Linux (Gnome only)
if [[ "$OS" == 'Linux' ]]; then
  # Need to get the DBUS_SESSION_BUS_ADDRESS var pid because gnome is stupid
  PID=$(pgrep gnome-session)
  export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2-)
  env DISPLAY=:0 gsettings set org.gnome.desktop.background picture-uri "file://$IMGPATH"
# Mac
elif [[ "$OS" == 'Darwin' ]]; then
  osascript -e "tell application \"Finder\"" -e "set desktop picture to POSIX file \"$IMGPATH\"" -e "end tell"
fi
