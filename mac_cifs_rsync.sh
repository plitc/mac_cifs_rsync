#!/bin/sh

### LICENSE (BSD 2-Clause) // ###
#
# Copyright (c) 2014, Daniel Plominski (Plominski IT Consulting)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice, this
# list of conditions and the following disclaimer in the documentation and/or
# other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
### // LICENSE (BSD 2-Clause) ###

### ### ### PLITC ### ### ###

### ### ### ### ### ### ### ### ###   ### ### ### ### ### ### ### ### ###
### # CONFIGURATION VARIABLES # ###   ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ###   ### ### ### ### ### ### ### ### ###



### ### ### ### ### ### ### ### ###   ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ###   ### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ###   ### ### ### ### ### ### ### ### ###

### stage0 // ###
UNAME=$(uname)
MYNAME=$(whoami)
#
PRG="$0"
##/ need this for relative symlinks
   while [ -h "$PRG" ] ;
   do
         PRG=$(readlink "$PRG")
   done
DIR=$(dirname "$PRG")
#
#/ spinner
spinner()
{
   local pid=$1
   local delay=0.01
   local spinstr='|/-\'
   while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
         local temp=${spinstr#?}
         printf " [%c]  " "$spinstr"
         local spinstr=$temp${spinstr%"$temp"}
         sleep $delay
         printf "\b\b\b\b\b\b"
   done
   printf "    \b\b\b\b"
}
### // stage0 ###

### stage1 // ###
case $UNAME in
Darwin)
   ### MacOS ###
OSXVERSION=$(sw_vers -productVersion)
BREW=$(/usr/bin/which brew)
MRSYNC=$(/usr/bin/find /usr/bin /usr/local/bin -name "rsync" | grep -c "rsync")
LASTUSER=$(/usr/bin/last | head -n 1 | awk '{print $1}')

#/ LASTGROUP=$(/usr/bin/id "$LASTUSER" | grep -o 'gid=[^(]*[^)]*)' | sed 's/[0-9]//g' | sed 's/gid=(//g' | sed 's/)//g')
##/ for OS X Yosemite
LASTGROUP=$(/usr/bin/id "$LASTUSER" | awk '{print $2}' | sed 's/gid=//g')
### ### ### ### ### ### ### ### ###

if [ "$MYNAME" = root ]
then
   : # dummy
else
   echo "<--- --- --->"
   echo ""
   echo "ERROR: You must be root to run this script"
   exit 1
fi

if [ -z "$BREW" ]
then
   echo "<--- --- --->"
   echo "need homebrew"
   echo "<--- --- --->"
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
   echo "<--- --- --->"
fi

if [ "$MRSYNC" = "1" ]
then
   echo "<--- --- --->"
   echo "need rsync"
   echo "<--- --- --->"
        /usr/sbin/chown -R "$LASTUSER:$LASTGROUP" /usr/local
        /usr/sbin/chown -R "$LASTUSER:$LASTGROUP" /Library/Caches/Homebrew
        sudo -u "$LASTUSER" -s "/usr/local/bin/brew install rsync"
   echo "<--- --- --->"
fi

(
##/ clean up
/bin/rm -rf /tmp/mac_cifs_rsync*.txt
)

### stage2 // ###

### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ###

while getopts ":s:i:r:m:u:p:" opt; do
  case "$opt" in
    s) source=$OPTARG ;;
    i) ip=$OPTARG ;;
    r) remote=$OPTARG ;;
    m) mountpoint=$OPTARG ;;
    u) user=$OPTARG ;;
    p) password=$OPTARG ;;
  esac
done
shift $(( OPTIND - 1 ))

##/ check source - empty argument
if [ -z "$source" ]
then
   echo "" # dummy
   echo "usage:   ./mac_cifs_rsync.sh -s {local source} -i {remote ip} -r {remote path} -m {local mountpoint} -u {user} -p {password}"
   echo "example: -s /Users -i 192.168.1.1 -r storage/rpool -m /freenas -u root -p 123"
   echo "" # dummy
   exit 1
fi

##/ check ip - empty argument
if [ -z "$ip" ]
then
   echo "" # dummy
   echo "usage:   ./mac_cifs_rsync.sh -s {local source} -i {remote ip} -r {remote path} -m {local mountpoint} -u {user} -p {password}"
   echo "example: -s /Users -i 192.168.1.1 -r storage/rpool -m /freenas -u root -p 123"
   echo "" # dummy
   exit 1
fi

##/ check remote - empty argument
if [ -z "$remote" ]
then
   echo "" # dummy
   echo "usage:   ./mac_cifs_rsync.sh -s {local source} -i {remote ip} -r {remote path} -m {local mountpoint} -u {user} -p {password}"
   echo "example: -s /Users -i 192.168.1.1 -r storage/rpool -m /freenas -u root -p 123"
   echo "" # dummy
   exit 1
fi

##/ check mountpoint - empty argument
if [ -z "$mountpoint" ]
then
   echo "" # dummy
   echo "usage:   ./mac_cifs_rsync.sh -s {local source} -i {remote ip} -r {remote path} -m {local mountpoint} -u {user} -p {password}"
   echo "example: -s /Users -i 192.168.1.1 -r storage/rpool -m /freenas -u root -p 123"
   echo "" # dummy
   exit 1
fi

##/ check user - empty argument
if [ -z "$user" ]
then
   echo "" # dummy
   echo "usage:   ./mac_cifs_rsync.sh -s {local source} -i {remote ip} -r {remote path} -m {local mountpoint} -u {user} -p {password}"
   echo "example: -s /Users -i 192.168.1.1 -r storage/rpool -m /freenas -u root -p 123"
   echo "" # dummy
   exit 1
fi

##/ check password - empty argument
if [ -z "$password" ]
then
   echo "" # dummy
   echo "usage:   ./mac_cifs_rsync.sh -s {local source} -i {remote ip} -r {remote path} -m {local mountpoint} -u {user} -p {password}"
   echo "example: -s /Users -i 192.168.1.1 -r storage/rpool -m /freenas -u root -p 123"
   echo "" # dummy
   exit 1
fi

#/ check ip - numeric
cip="$(echo "$ip" | sed 's/[^0-9,^.,^:,]*//g')"
if [ "$cip" != "$ip" ]
then
   echo "" # dummy
   echo "[ERROR] string -ip '"$ip"' has characters which are not numeric"
   echo "" # dummy
   exit 1
fi

##/ umount mountpoint
umount "$mountpoint" > /dev/null 2>&1
if [ $? -eq 0 ]
then
   printf "\033[1;32m1. mac_cifs_rsync (old) unmount successful\033[0m\n"
   #/ echo "" # dummy
fi

##/ mount
mount -t smbfs //"$user":"$password"@"$ip"/"$remote" "$mountpoint"
if [ $? -eq 0 ]
then
   printf "\033[1;32m2. mac_cifs_rsync (new) mount successful\033[0m\n"
   #/ echo "" # dummy
else
   echo "" # dummy
   echo "[ERROR] can't mount"
   echo "" # dummy
   exit 1
fi

##/ file caching
ls -all "$mountpoint" > /dev/null 2>&1

##/ rsync
echo "" # dummy
echo "---> starting: RSYNC in 5 seconds..."
echo "" # dummy
(sleep 5) & spinner $!
##/ RUN
#/ /usr/local/bin/rsync -rltD --progress --no-perms --no-owner --no-group --update --delete "$source"/ "$mountpoint"/
/usr/local/bin/rsync -rltD --no-perms --no-owner --no-group --update --delete "$source"/ "$mountpoint"/
if [ $? -eq 0 ]
then
   printf "\033[1;31mmac_cifs_rsync finished.\033[0m\n"
else
   printf "\033[1;33mmac_cifs_rsync (partial) finished.\033[0m\n"
fi

### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ###

### // stage2 ###
;;
*)
    # error 1
    echo "<--- --- --->"
    echo ""
    echo "ERROR: Plattform = unknown"
    exit 1
    ;;
esac

#
### // stage1 ###

exit 0
### ### ### PLITC ### ### ###
# EOF
