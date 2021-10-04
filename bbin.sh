#!/bin/bash
# bbin.sh
# (c) 2020 Henryk M. Kowalski
# Last edit 

#------------------------------------------------------------------------------------------------
# Back up my binaries directory
# This directory contains Python and Perl programs as well as shell scripts and test directories
#------------------------------------------------------------------------------------------------

#-----------------------------
#   Functions
#-----------------------------

#-----------------------------------------------
proceeddialog() {
echo
echo "Currently set Hard drive is: $mydesthd"
echo "Currently set usb drive is: $myusbdevice"
echo #skipusb = $skipusb #debug
echo "Please make sure that this is correct."
echo "Please make sure that the usb drive is plugged in and *mounted*(!)"
read -p "Ready to proceed? " -n 1 -r #This reads exactly 1 character
echo

if [[ ! $REPLY =~ ^[Yy]$ ]];    #Check to see if reply is not y
	then 
        echo 'Quitting'
        exit 1 
    else echo "Proceeding with backup"
fi
}

#-----------------------------------------------
getusbdrive(){
skipusb=0

defaultusb=sdc1 #define  default drive

echo "Please enter USB drive name and number, eg ($defaultusb): "
read -p "[Enter] for default ($defaultusb). 'n' to skip. :  "  myusbdrive

if [ -z $myusbdrive ]; then
    myusbdrive=$defaultusb;  #set default
    echo; echo "default value: - $myusbdrive - used."; echo;
    myusbdevice=/mnt/$myusbdrive/
    
elif [[ $myusbdrive =~ ^[Nn]$ ]];
	then skipusb=1
    echo Skipping USB backup.
    myusbdevice=''
    
else echo; 
	echo "Using: - $myusbdrive - for external backup."; 
    echo;
    myusbdevice=/mnt/$myusbdrive/
    
fi

#echo $myusbdevice #debug
}

#-----------------------------------------------
getharddrive(){

defhd=sda5  #define  default drive

echo "Please enter *Destination* Hard drive partition letter and number, eg ($defhd): "
read -p "Or press [Enter] for the default value: ($defhd):  "  mydesthd

if [ -z $mydesthd ]; then
    mydesthd=$defhd;  #set default
    echo; echo "default value: - $mydesthd - used."; echo;
else echo; echo "Using: Hard drive - $mydesthd - for internal backup."; echo;
fi

mydesthd=/mnt/$mydesthd/
}

#-----------------------------------------------

updatedestdirs(){
# updates and generates the destination directories

for hdir in ${hddir[@]}; do
	destdir+=( $mydesthd$hdir )
done

if [ $skipusb -eq 0 ]; then
 for udir in ${usbdir[@]}; do
	destdir+=( $myusbdevice$udir )
 done
fi

}

#-----------------------------
#   Vars
#-----------------------------

# Source dir
# This directory contains Python and Perl programs as well 
# as shell scripts and test directories
myscriptdir='/home/personal/bin/'

# Destination devices
#myusbdevice='/mnt/sdc1/'
myusbdevice=''


#arrays
declare -a destdir	# this array will hold the destination directories

hddir=(
	'bin/'
    'bin2/'
)

usbdir=(
    'hmk/bin/'
    'hmk/ComputerCode/bin/'
    )

#-----------------------------
# Start
#-----------------------------

clear; echo ;

getharddrive	# get hd archive destination drive info
echo
getusbdrive		# get usb archive destination drive info
echo
proceeddialog   # usb plugged in?
echo
updatedestdirs   #update the hd and usb directories based on the info provided
echo
#echo ${destdir[*]}; exit  #debug
for mdir in ${destdir[@]}; do
    if [ ! -d $mdir ]; then
        echo Creating destination directory: "$mdir"
        mkdir -vp $mdir
    fi
    
 echo --------------------------------------------------------------------
 echo "Performing: rsync -avh --del $myscriptdir $mdir"
 echo --------------------------------------------------------------------
 rsync -avh --del $myscriptdir $mdir
    
done

# Now write out the info to all disks
echo
echo ----------------------------------------------------------
echo "Writing out all disk operations: -- sync -- Please wait."
echo ----------------------------------------------------------
echo
sync
echo All done.; echo

read -p "Press any key to exit." -n 1 -r #This reads exactly 1 character

exit 0
