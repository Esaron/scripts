#!/bin/bash

# ADD REDDIT FEEDS TO ME and watch the magic...
FEEDS=("wallpapers" "earthporn" "spaceporn" "MinimalWallpaper" "wallpaper")

FEEDNUMBER=$(( ($RANDOM % ${#FEEDS[@]}) ))
BASEPATH="/home/jdn/Pictures/redditWallpapers/"
#DATEPREFIX=$(date +%Y%m%d)
#TIMEPREFIX=$(date +%H.%M.%S)
FEED="http://www.reddit.com/r/${FEEDS[$FEEDNUMBER]}/.rss"
IMGPATTERN='http://\(i.\)\?imgur.com/\([0-9a-zA-Z_-]*\)\(.jpg\)\?'
RAWURLS=$(curl --silent $FEED | grep -o -e $IMGPATTERN)
echo $RAWURLS
URLS=($RAWURLS)
URL=${URLS[$(( $RANDOM % ${#URLS[@]} ))]}

if [ "$(echo $URL | grep 'http://i.' )" == "" ] ; then
  URL="http://i.${URL:7:${#URL}}"
fi
if [ "$(echo $URL | grep '.jpg' )" == "" ] ; then
  URL="$URL.jpg"
fi
IMG=$(basename "$URL")
echo $URL
IMGPATH=$(find $BASEPATH -type f -name *$IMG)
if [ -z "$IMGPATH" ] ; then
  IMGURL=$URL
  #IMGPATH=${BASEPATH}${DATEPREFIX}-${TIMEPREFIX}_${IMG}
  IMGPATH=${BASEPATH}${IMG}
else
  echo "$IMGURL already downloaded."
fi
if [ ! -z "$IMGPATH" ] ; then
  if [ ! -z "$IMGURL" ] ; then
    wget -O "$IMGPATH" "$IMGURL"
  fi
  env DISPLAY=:0 gsettings set org.gnome.desktop.background picture-uri "file://$IMGPATH"
  #OLDFILES=$(find "$BASEPATH" -type f -not -name "$DATEPREFIX*" -delete)
  #for FILE in $OLDFILES
  #do
    #rm $FILE
  #done
fi
