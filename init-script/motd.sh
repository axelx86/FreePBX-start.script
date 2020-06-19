#!/bin/bash -x


RUNAS=asterisk

# Are we root?
if [ "$(/usr/bin/id -u)" == "0" ]; then
	SU="/bin/su $RUNAS -c"
else
	SU=""
fi

# Are we logging in?
if [ "$PS1" ] ; then
	# Does fwconsole exist?
	if [ -L /usr/sbin/fwconsole ]; then
		FWCONSOLE=$(/bin/readlink /usr/sbin/fwconsole)
	else
		FWCONSOLE=/usr/sbin/fwconsole
	fi

	if [ -e "$FWCONSOLE" ] ; then
/usr/bin/itpr_intro
		[ "$SU" ] && $SU "$FWCONSOLE motd" || $FWCONSOLE motd
	elif [ -e /usr/local/bin/motd ] ; then
		$SU /usr/local/bin/motd
	else
		bold=$(tput smso)
		ul=$(tput smul)
		eul=$(tput rmul)
		normal=$(tput sgr0)

		echo -e "\n${bold}** CRITICAL SYSTEM ERROR **${normal}\n\nUnable to generate MOTD.\nThe ${ul}/usr/sbin/fwconsole${eul} file is not accessible\n"
		echo -e "You are likely to experience significant system issues.\n"
	fi
fi
