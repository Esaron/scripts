#!/bin/bash
# Filename: apodwallpaper
# Purposes: Downloads NASA Astronomy Picture of the Day and displays it as the GNOME background
# Author(s): acvwJosh of Ubuntu Forums, modified by Colin Dean <http://cad.cx>, o1911
# modified by Esaron

[ "$(uname)" = 'Darwin' ]; IS_MAC=true

# change this if you want the image to be in a different directory
DIRECTORY=$HOME/Pictures/apod
cd $DIRECTORY

# fetch the apod site's text, to determine the latest apod
SITE=http://apod.nasa.gov/apod/index.html

if $(wget $SITE); then
  # the prefix of the filename is to be the current date
  FILENAME=$(cat $(echo $SITE | rev | cut -d "/" -f -1 | rev) | grep $(date +%Y) | head -1)

  # format this date to have underscores instead of spaces
  FILENAME=$(echo $FILENAME | tr " " "_")

  # check if today's file exists
  if [ ! -f $FILENAME* ]; then
    # if not, download image from apod site
    wget -A.jpg,.JPG -R.txt -r -l1 --no-parent -nH $SITE

    # find largest file (biggest res. picture)
    if [ "$IS_MAC" = true ]; then
      BIGFILESIZE=$(find $DIRECTORY -print0 | xargs -0 stat -f '%z'| sort -nr | head -1)
    else
      BIGFILESIZE=$(find $DIRECTORY -printf '%s\n' | sort -nr | head -1)
    fi

    # check if biggest file is a dir (no picture today)
    if [ $BIGFILESIZE == 4096 ]; then
      ## there is no picture for today
      # set today's picture to be yesterday's
      YESTERDAY=$(( $(date +%s) - 86400 )) # 86400 seconds in a day
      ln -sf "$(find $DIRECTORY | grep -i $(date -d "@$YESTERDAY" +%Y_%B_%d))" "$DIRECTORY/wallpaper"

      ## set today's picture to be a random one
      #NUMBEROFFILES=$(find . | wc -l)
      #NUMBER=$(( $RANDOM % $NUMBEROFFILES ))
      #ln -sf "$DIRECTORY/$(ls | tail -$NUMBEROFFILES | head -$NUMBER | tail -1)" $HOME/wallpaper

      rm -rf ap* *.apod robots.txt* index.html*
      exit 0
    fi

    ## we have a picture for today
    # get its relative path for movement to ${DIRECTORY}
    BIGGESTFILE=$(find apod -size ${BIGFILESIZE}c)
    # also get its base filename to append
    if [ "$IS_MAC" = true  ]; then
      BIGGESTFILENAME=$(find apod -size ${BIGFILESIZE}c -print0 | xargs -0 stat -f '%N')
      BIGGESTFILENAME=$(basename $BIGGESTFILENAME)
    else
      BIGGESTFILENAME=$(find apod -size ${BIGFILESIZE}c -printf '%f\n')
    fi
    # declare our final filename for today's picture
    WALLPAPER=$FILENAME-$BIGGESTFILENAME
    # move it to the proposed directory
    mv $BIGGESTFILE $DIRECTORY/$WALLPAPER
  else
    if [ "$IS_MAC" = true   ]; then
      WALLPAPER=$(find $DIRECTORY -name $FILENAME* -print0 | xargs -0 stat -f '%N')
      WALLPAPER=$(basename $WALLPAPER)
    else
      WALLPAPER=$(find $DIRECTORY -name $FILENAME* -printf "%f\n")
    fi
  fi
else # wget failed. internet up?
  exit 1
fi

if [ "$IS_MAC" = true ]; then
  osascript -e "tell application \"System Events\" to set picture of every desktop to \"$DIRECTORY/$WALLPAPER\""
  #sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db "update data set value = '$DIRECTORY/$WALLPAPER'" && killall Dock
else # Assume Ubuntu or the like
  env DISPLAY=:0 gsettings set org.gnome.desktop.background picture-uri file://$DIRECTORY/$WALLPAPER
fi

# get rid of cruft
rm -rf ap* *.apod robots.txt* index.html*
exit 0
