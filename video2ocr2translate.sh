#!/bin/bash

# video2ocr2Translate 20231122 19h00
# https://tsurugi-linux.org
# OCR extraction from video files like mov,mp4,m4a,3gp,3g2,mj2

# THIS SCRIPT HAS BEEN CREATED BY Antonio 'Visi@n' Broi antonio@tsurugi-linux.org && Giovanni 'Sug4r' Rattaro 
# Script released under Gnu-Linux GPL Open Source License


# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

check_root () {
        #check if root user
        if [ "$(id -u)" == "0" ]; then
			clear && echo -e "\n\033[40m\033[1;31m [!]  Sorry, this script doesn't work with root user  [!] $1\033[0m \n" >&2
			exit 1
        fi
}

make_working_directory () {
	WORKING_DIRECTORY="$HOME/02.computer_vision/04.video2ocr"

	for DIRECTORY in "$WORKING_DIRECTORY"/01.video "$WORKING_DIRECTORY"/02.images "$WORKING_DIRECTORY"/03.imagesgrey "$WORKING_DIRECTORY"/04.ocr_output; do
		if [ !  -d "$DIRECTORY" ]; then
			echo "The working directory \""$DIRECTORY"\" doesn't exist and it will be created" && mkdir -p "$DIRECTORY"
		fi
	done
				
	echo -e "O.C.R. directory tree has been created inside \""$HOME"\" \n Now it's possible to copy viddeo files in \""$HOME"/02.computer_vision/01.VIDEO\" or image files inside \""$HOME"/02.computer_vision/02.images\""
}

input_check () {
WORKING_DIRECTORY="$HOME/02.computer_vision/04.video2ocr"
CV_DIRECTORIES="01.video 02.images 03.imagesgrey 04.ocr_output"

help="
Copy your video files inside the "$WORKING_DIRECTORY/01.video" directory and run the script.
When the process will end a detailed report with results will be displayed in html format.

      --help        display this help and exit
      --langs       display all supported langs for ocr process detection
      --version     display version information and exit

Usage examples: 
video2ocr2translate <language> <framerate> 
video2ocr2translate eng 5 it

By default, if the framerate is not specified, its value is 1 (one image per second): 
video2ocr2translate eng 

Report bugs to <antonio@tsurugi-linux.org>
"

version="0.2 video2ocr (ocr extraction from video files)
Copyright (C) 2007, 2011-2013 Free Software Foundation, Inc.
This is free software.  You may redistribute copies of it under the terms of
the GNU General Public License <http://www.gnu.org/licenses/gpl.html>.
There is NO WARRANTY, to the extent permitted by law.

Written by Antonio 'Visi@n' Broi && Giovanni 'Sug4r' Rattaro"

langs="afr
amh
ara
asm
aze
aze_cyrl
bel
ben
bod
bos
bul
cat
ceb
ces
chi_sim
chi_tra
chr
cym
dan
dan_frak
deu
deu_frak
dzo
ell
eng
enm
epo
equ
est
eus
fas
fin
fra
frk
frm
gle
gle_uncial
glg
grc
guj
hat
heb
hin
hrv
hun
iku
ind
isl
ita
ita_old
jav
jpn
kan
kat
kat_old
kaz
khm
kir
kor
kur
lao
lat
lav
lit
mal
mar
mkd
mlt
msa
mya
nep
nld
nor
ori
osd
pan
pol
por
pus
ron
rus
san
sin
slk
slk_frak
slv
spa
spa_old
sqi
srp
srp_latn
swa
swe
syr
tam
tel
tgk
tgl
tha
tir
tur
uig
ukr
urd
uzb
uzb_cyrl
vie
yid
"

bindir="$WORKING_DIRECTORY"
case "$1" in
	--__bindir) bindir=${2?}; shift; shift;;
esac
PATH=$bindir:$PATH

case "$1" in
	-h)    	   exec echo "$help";;
	--help)    exec echo "$help";;
	--h)       exec echo "$help";;
	-help)     exec echo "$help";;
	--version) exec echo "$version";;
	--langs)   exec echo "$langs";;
esac

if [ -z "$1" ]; then
	echo -e "###  Please specify one of the installed Tesseract OCR languages  ###\n"
	tesseract --list-langs
	echo "" && exit 1
fi

#check framerate settings
check='^[0-9]+$'
if [ -z "$2" ] || ! [[ "$2" =~ $check ]]; then
        FRAMERATE="1"
     else
        FRAMERATE="$2"
fi


# check if language is less than 3 caracters
if [ "$(echo -n $1 | wc -c)" -lt "3" ]; then
   echo "The specified language is not correct" && exit 1
fi

INSTALLED_LANGUAGES=$(tesseract --list-langs | grep -v available)
# check if the specified language is installed
if [[ $INSTALLED_LANGUAGES != *"$1"* ]]; then
	echo -e "\nWARNING: the specified \""$1"\" language is still not installed\n\nYou can search about it using the command \"aptitude search tesseract-ocr-\"\nor install all supported languages typing the command \"sudo aptitude install tesseract-ocr-all -y\"\n"
	exit 1
fi


for dir in $CV_DIRECTORIES; do
   mkdir -p "$WORKING_DIRECTORY/$dir"
done
}

video2png () {
	#check if empty dir
	if [ "$(ls "$WORKING_DIRECTORY"/02.images/*.png 2>/dev/null | wc -l)" -ge '1' ]; then
	   dialog --title "SETUP" --yesno  "Some PNG files have been found inside \""$WORKING_DIRECTORY"/02.images/\" directory, do you want perform a new analysis on these files (YES) or dicard all of them before to proceed (NO)? " 12 40 
	   answer="$?"
	   #if yes
           if [ "$answer" == "0" ]; then
	      clear && ocr_extraction "$1" && exit 1
	    else
	     #if no clean working directories
	     rm -f "$WORKING_DIRECTORY"/02.images/*.png 
	     #rm -f "$WORKING_DIRECTORY"/03.imagesgrey/*.jpg 
	     rm -f "$WORKING_DIRECTORY"/04.ocr_output/*.txt 
	   fi
	fi
	if [ -z "$(ls -A "$WORKING_DIRECTORY"/01.video/)" ]; then
		echo -e "\nWARNING \"$WORKING_DIRECTORY/01.video/\" directory is empty! \n" && exit 1
	fi
	clear && echo -e "\nUSED FRAMERATE = $FRAMERATE per second\n" && sleep 1
	for file in "$WORKING_DIRECTORY"/01.video/*; do
	  ffmpeg -i "$file" -r "$FRAMERATE" -f image2 "$file-%4d.png"	
	done
	echo -e '\n#########################################'
	echo -e  '1/3 conversion in png files terminated'
	echo -e '#########################################\n'
	mv "$WORKING_DIRECTORY"/01.video/*.png "$WORKING_DIRECTORY"/02.images/

}

ocr_extraction () {
	echo -e 'NOW OCR EXTRACTION IS ONGOING, PLEASE WAIT...\n'
	#check if empty dir
	if [ -z "$(ls -A "$WORKING_DIRECTORY"/02.images/)" ]; then
		echo -e "\nWARNING \"$WORKING_DIRECTORY/02.images/\" directory is empty! \n" && exit 1
	fi
	for file in "$WORKING_DIRECTORY"/02.images/*.png; do
		[[ -e "$file" ]] || break
		tesseract -l "$1" "$file" "$file" 2>/dev/null
		testo=$(cat $file.txt)
		translate -d it "$testo" > "$file".txt.csv
	done
	mv "$WORKING_DIRECTORY"/02.images/*.txt "$WORKING_DIRECTORY"/04.ocr_output/
	mv "$WORKING_DIRECTORY"/02.images/*.csv "$WORKING_DIRECTORY"/04.ocr_output/
	echo -e '\n#########################################'
	echo -e '2/3 OCR "Optical character recognition IS TERMINATED'
	echo -e '#########################################\n'
	html_report "$1"
}

html_report () {
	echo "<html><head><title>video2ocr Tsurugi [$1]</title></head><body><table with=90%>"> "$WORKING_DIRECTORY"/index_"$1"_color.html
	for file in "$WORKING_DIRECTORY"/04.ocr_output/*.txt; do
		[[ -e "$file" ]] || break
		#filename
		echo "<tr with=99%>">> "$WORKING_DIRECTORY"/index_"$1"_color.html
		
		
		
		#original image path
		IMAGE_PATH="$(echo "$file" | sed 's/04.ocr_output/02.images/g' | awk -F ".txt" '{print $1}')"
		
		#OCR output to HTML
		echo "<td with=20% ><a href=\""$IMAGE_PATH"\" target=_blank ><img width=500px src=\""$IMAGE_PATH"\"></a></td>">> "$WORKING_DIRECTORY"/index_"$1"_color.html
		
#		echo "<td><a href=\""$file"\" target=_blank >\"" >> "$WORKING_DIRECTORY"/index_"$1"_color.html
#		cat "$file" >> "$WORKING_DIRECTORY"/index_"$1"_color.html
#		echo "\"</a></td>" >> "$WORKING_DIRECTORY"/index_"$1"_color.html
		
		
		echo "<td with=80%><a href=\""$file.csv"\" target=_blank >\"" >> "$WORKING_DIRECTORY"/index_"$1"_color.html
		cat  "$file".csv  >> "$WORKING_DIRECTORY"/index_"$1"_color.html
		echo "\"</a></td></tr>" >> "$WORKING_DIRECTORY"/index_"$1"_color.html
		
		
		
		
	done
	echo "</table></body></html>">> "$WORKING_DIRECTORY"/index_"$1"_color.html
	echo -e '\n#########################################'
	echo -e '3/3 OK all tasks are terminated'
	echo -e '#########################################\n'

	firefox -new-tab "$WORKING_DIRECTORY"/index_"$1"_color.html 2>/dev/null &
}


## MAIN ##
check_root
make_working_directory
input_check "$1" "$2"
video2png "$1"
#image_grey_scale "$1"
ocr_extraction "$1"
