#!/bin/bash

# ADD REDDIT FEEDS TO ME and watch the magic...
FEEDS=("wallpapers" "earthporn" "spaceporn" "MinimalWallpaper" "wallpaper" "cityporn" "villageporn" "architectureporn" "infrastructureporn" "abandonedporn" "ruralporn" "aerialporn" "adrenalineporn" "animalporn" "macroporn" "microporn" "waterporn" "skyporn" "fireporn" "botanicalporn" "WQHD_Wallpaper" "iceporn" "seacreatureporn")

FEEDNUMBER=$(( ($RANDOM % ${#FEEDS[@]}) ))
FEED=${FEEDS[$FEEDNUMBER]}
BASEPATH="/home/jdn/Pictures/redditWallpapers/"
MINWID=1280
MINHT=720
#DATEPREFIX=$(date +%Y%m%d)
#TIMEPREFIX=$(date +%H.%M.%S)
FEEDURL="http://www.reddit.com/r/${FEED}/.rss"
IMGPATTERN='http://\(i.\)\?imgur.com/\([0-9a-zA-Z_-]*\)\(.jpg\)\?'
RAWURLS=$(curl --silent $FEEDURL | grep -o -e $IMGPATTERN)
echo "Found raw urls:"
echo $RAWURLS
echo
URLS=($RAWURLS)
RETRIES=5
while [ $RETRIES -gt 0 ] ; do
  echo "------------------Getting wallpaper from subreddit: $FEED---------------"
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
    if [[ $IMGWIDTH -ge $MINWID && $IMGHEIGHT -gt $MINHT ]] ; then
      env DISPLAY=:0 gsettings set org.gnome.desktop.background picture-uri "file://$IMGPATH"
      RETRIES=0
    else
      echo "Not setting desktop to $IMGPATH as image is too small (${IMGWIDTH}x${IMGHEIGHT})"
      echo
      let RETRIES=$RETRIES-1
    fi
    #OLDFILES=$(find "$BASEPATH" -type f -not -name "$DATEPREFIX*" -delete)
    #for FILE in $OLDFILES
    #do
      #rm $FILE
    #done
  fi
done
