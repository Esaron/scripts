#!/bin/bash
#Filename: apodwallpaper
#Purposes: Downloads NASA Astronomy Picture of the Day and displays it as the GNOME background
#Author(s): acvwJosh of Ubuntu Forums, modified by Colin Dean <http://cad.cx>, o1911

# change this if you want the image to be in a different directory
DIRECTORY=$HOME/Pictures/APoD
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
		BIGFILESIZE=$(find apod/ -printf '%s\n' | sort -nr | head -1)

		# check if biggest file is a dir (no picture today)
		if [ $BIGFILESIZE == 4096 ]; then
		## there is no picture for today
			# set today's picture to be yesterday's
			YESTERDAY=$(( $(date +%s) - 86400 )) # 86400 seconds in a day
			ln -sf "$(find $DIRECTORY/ | grep -i $(date -d "@$YESTERDAY" +%Y_%B_%d))" "$HOME/wallpaper"

			## set today's picture to be a random one
			#NUMBEROFFILES=$(find . | wc -l)
			#NUMBER=$(( $RANDOM % $NUMBEROFFILES ))
			#ln -sf "$DIRECTORY/$(ls | tail -$NUMBEROFFILES | head -$NUMBER | tail -1)" $HOME/wallpaper

			rm -rf ap* *.apod robots.txt* index.html*
			exit 0
		fi

		## we have a picture for today
		# get its relative path for movement to ${DIRECTORY}
		BIGGESTFILE=$(find apod/ -size ${BIGFILESIZE}c)
		# also get its base filename to append
		BIGGESTFILENAME=$(find apod/ -size ${BIGFILESIZE}c -printf '%f\n')
		# declare our final filename for today's picture
		WALLPAPER=$FILENAME-$BIGGESTFILENAME
		# move it to the proposed directory
		mv $BIGGESTFILE $DIRECTORY/$WALLPAPER
	else
		WALLPAPER=$(find $DIRECTORY/ -name $FILENAME* -printf "%f\n")
	fi
else # wget failed. internet up?
	exit 1
fi

env DISPLAY=:0 gsettings set org.gnome.desktop.background picture-uri file:///home/jdn/Pictures/APoD/$WALLPAPER

# get rid of cruft
rm -rf ap* *.apod robots.txt* index.html*
exit 0
