#!/bin/bash

######################################
# test if logged in tech is an admin #
######################################
if id -Gn | grep -q "admin"
# if tech is an admin, echo message and proceed
	then echo "You are an admin; proceeding with reimaging."
# if tech is not an admin, stop script with message
	else
		clear
		echo "You are not an admin.  Log in as an admin and re-run this script."
		exit 1
fi

###################################
# test if Macintosh HD is mounted #
###################################

while test ! -d /Volumes/Macintosh\ HD
	do
	clear
	echo "Please attach target computer in target disk mode."
	read -ep "Rescan/Quit?" -n1
		case $REPLY in 
		q|Q) clear; echo "Imaging stopped, target not present"; exit 0
		esac
	done
		

############################################################################
# test if COMMON-DEV$ is mounted, if not, offer choice to stop or continue #
############################################################################

if test ! -d /Volumes/COMMON-DEV\$
	then
		clear
		read -ep "COMMON-DEV$ is not mounted, image and packages will not be updated from server.  Continue (y/n)?" -n1
		case $REPLY in
		n|N) clear; echo "Reimage stopped"; exit 0
		esac
fi

################################################################################
# if COMMON-DEV is present, update local copy of Macintosh HD image if needed. #
################################################################################

if test ! -e /Users/Shared/Images/Macintosh\ HD_asr.dmg -o /Users/Shared/Images/Macintosh\ HD_asr.dmg -ot /Volumes/COMMON-DEV\$/APPLE_OSX/Production\ Images/Modular/Macintosh\ HD_asr.dmg
then
cp /Volumes/COMMON-DEV\$/APPLE_OSX/Production\ Images/Modular/Macintosh\ HD_asr.dmg /Users/Shared/Images/Macintosh\ HD_asr.dmg
fi

##############################################################
# if COMMON-DEV is present, update local packages if needed. #
##############################################################

for packageage in $( ls /Volumes/COMMON-DEV\$/APPLE_OSX/Software/Packages/ );
	do
	if test ! -e /Users/Shared/Packages/$packageage -o /Users/Shared/Packages/$packageage -ot /Volumes/COMMON-DEV\$/APPLE_OSX/Software/Packages/$packageage
	then echo copying $packageage ; cp -R /Volumes/COMMON-DEV\$/APPLE_OSX/Software/Packages/$packageage /Users/Shared/Packages/$packageage
	fi
done

###############################
# apply image to Macintosh HD #
###############################

sudo asr restore -source /Users/Shared/Images/Macintosh\ HD_asr.dmg -target /Volumes/Macintosh\ HD -erase -noprompt

#######################
# apply image to Data #
#######################

sudo asr restore -source /Users/Shared/Images/Data_asr.dmg -target /Volumes/Data -erase -noprompt

##########################
# rename target computer #
##########################

computername=x
computername2=y
while test $computername != $computername2
	do	
	clear
	read -ep "enter target computer name: " computername
	clear
	read -ep "verify target computer name: " computername2
	done

clear 
echo "The target computer will be named " $computername
read -ep "Continue (y/n)?" -n1
case $REPLY in 
n|N) clear; echo "Renaming stopped"; exit 0
esac

PlistBuddy -c "Set :System:Network:HostNames:LocalHostName $computername" /Volumes/Macintosh\ HD/Library/Preferences/SystemConfiguration/preferences.plist
PlistBuddy -c "Set :System:System:ComputerName $computername" /Volumes/Macintosh\ HD/Library/Preferences/SystemConfiguration/preferences.plist

echo "Target computer renamed" $computername

##################################
# install all necessary packages #
##################################

# core packages

for i in $( ls -d /Users/Shared/Packages/cor* );
	do
	fn=$i
	sudo installer -pkg $i -target /Volumes/Macintosh\ HD/
done

# printer drivers

for k in $( ls -d /Users/Shared/Packages/prt* );
	do
	fn=$k
	sudo installer -pkg $k -target /Volumes/Macintosh\ HD/
done

# security updates

for m in $( ls -d /Users/Shared/Packages/sec* );
	do
	fn=$m
	sudo installer -pkg $m -target /Volumes/Macintosh\ HD/
done

# hardware specific
platform=`arch`

if test $platform == "i386"
	then for n in $( ls -d /Users/Shared/Packages/intel/* );
	do
	fn=$n
	sudo installer -pkg $n -target /Volumes/Macintosh\ HD/
done
fi

if test $platform == "ppc"
	then for n in $( ls -d /Users/Shared/Packages/ppc/* );
	do
	fn=$n
	sudo installer -pkg $n -target /Volumes/Macintosh\ HD/
done
fi

# determine department, install departmental software

## advertising
if echo $computername | grep -q "ad"
then for j in $( ls -d /Users/Shared/Packages/dad* );
	do
	fn=$j
	sudo installer -pkg $j -target /Volumes/Macintosh\ HD/
done
fi

## home collection
if echo $computername | grep -q "hc"
then for j in $( ls -d /Users/Shared/Packages/dhc* );
	do
	fn=$j
	sudo installer -pkg $j -target /Volumes/Macintosh\ HD/
done
fi

## men's art
if echo $computername | grep -q "ma"
then for j in $( ls -d /Users/Shared/Packages/dma* );
	do
	fn=$j
	sudo installer -pkg $j -target /Volumes/Macintosh\ HD/
done
fi

#################
# notify & exit #
#################

echo $computername " is reimaged and software is up to date"

exit 0