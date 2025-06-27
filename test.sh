#!/bin/sh

# Set NEWT_COLORS for black background and white text in whiptail dialogs
export NEWT_COLORS='
root=,grey
window=,black
shadow=,blue
border=blue,black
title=blue,black
textbox=blue,black
radiolist=black,black
label=black,blue
checkbox=black,blue
compactbutton=black,blue
button=black,red
'

# Function to print plain text
color_printf() {
    printf "%s\n" "$1"
}

# Test if whiptail is installed
if ! command -v whiptail >/dev/null 2>&1
then
    color_printf "whiptail could not be found. Please install it first."
    exit 1
fi

# Info box
whiptail --title "Whiptail Test" --msgbox "Welcome to the Whiptail test script!" 10 50

# Yes/No box
if whiptail --title "Question" --yesno "Do you want to continue testing?" 10 60; then
    color_printf "User chose Yes"
else
    color_printf "User chose No"
    exit 0
fi

# Input box
NAME=`whiptail --title "Input Box" --inputbox "What is your name?" 10 60 3>&1 1>&2 2>&3`

EXIT_STATUS=$?
if [ "$EXIT_STATUS" = 0 ]; then
    color_printf "Hello, $NAME!"
else
    color_printf "User canceled the input box."
    exit 1
fi

# Password box
PASSWORD=`whiptail --title "Password Box" --passwordbox "Enter a password:" 10 60 3>&1 1>&2 2>&3`

# Menu
CHOICE=`whiptail --title "Main Menu" --menu "Choose an option:" 15 60 4 \
"1" "Show current date/time" \
"2" "List files in current directory" \
"3" "Show disk usage" \
"4" "Exit" 3>&1 1>&2 2>&3`

case "$CHOICE" in
    1)
        whiptail --title "Current Date/Time" --msgbox "`date`" 10 60
        ;;
    2)
        whiptail --title "File List" --msgbox "`ls -lah`" 20 60
        ;;
    3)
        whiptail --title "Disk Usage" --msgbox "`df -h`" 20 60
        ;;
    4)
        whiptail --title "Goodbye" --msgbox "Exiting..." 10 50
        ;;
    *)
        color_printf "Invalid choice or user canceled."
        ;;
esac
