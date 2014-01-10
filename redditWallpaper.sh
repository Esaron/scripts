#!/bin/bash

# ADD REDDIT FEEDS TO ME and watch the magic...
FEEDS=("wallpapers" "earthporn" "spaceporn" "MinimalWallpaper" "wallpaper" "cityporn" "villageporn" "architectureporn" "infrastructureporn" "abandonedporn" "ruralporn" "aerialporn" "adrenalineporn" "animalporn" "macroporn" "microporn" "waterporn" "skyporn" "fireporn" "botanicalporn" "WQHD_Wallpaper")

FEEDNUMBER=$(( ($RANDOM % ${#FEEDS[@]}) ))
BASEPATH="/home/jdn/Pictures/redditWallpapers/"
#DATEPREFIX=$(date +%Y%m%d)
#TIMEPREFIX=$(date +%H.%M.%S)
FEED="http://www.reddit.com/r/${FEEDS[$FEEDNUMBER]}/.rss"
IMGPATTERN='http://\(i.\)\?imgur.com/\([0-9a-zA-Z_-]*\)\(.jpg\)\?'
RAWURLS=$(curl --silent $FEED | grep -o -e $IMGPATTERN)
echo $RAWURLS
URLS=($RAWURLS)
COUNTER=5
while [ $COUNTER -gt 0 ] ; do
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
      attr -s url -V "$IMGURL" "$IMGPATH"
    fi
    IMGWIDTHHEIGHT=$(identify -format "%w,%h" $IMGPATH)
    IMGWIDTH=$(echo $IMGWIDTHHEIGHT | cut -d "," -f 1)
    IMGHEIGHT=$(echo $IMGWIDTHHEIGHT | cut -d "," -f 2)
    if [[ $IMGWIDTH -gt 1100 && $IMGHEIGHT -gt 700 ]] ; then
      env DISPLAY=:0 gsettings set org.gnome.desktop.background picture-uri "file://$IMGPATH"
      COUNTER=0
    else
      echo "Not setting desktop to $IMGPATH as image is too small (${IMGWIDTH}x${IMGHEIGHT})"
      let COUNTER=$COUNTER-1
    fi
    #OLDFILES=$(find "$BASEPATH" -type f -not -name "$DATEPREFIX*" -delete)
    #for FILE in $OLDFILES
    #do
      #rm $FILE
    #done
  fi
done
