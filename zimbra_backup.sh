# Script to backup Zimbra mailbox accounts.
# Written by Drew Bentley.
#
# Usage:  ./zimbra_backup backup-type domain
# 
# Copyright 2019 DREW BENTLEY
# drew.bentley@gmail.com

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details. <http://www.gnu.org/licenses/>.

DATE=`date +%Y%m%d`
WEEKAGO=$(date -d "$date -8 days" +"%m/%d/%Y")
YESTERDAY=$(date -d "$date -2 days" +"%m/%d/%Y")
DOMAIN=$2
BACKUPDIR=/mnt/BACKUP/backups

# Let's create a list of acounts to backup from but lets make a new list based on accounts present:
if [ -e $BACKUPDIR/."$DOMAIN"_accounts.list ]; then
	rm -f $BACKUPDIR/."$DOMAIN"_accounts.list
fi

# Let's exclude the galsync accounts as they're not needed (we grep with @ as zmaccts grabs other cruft that isn't a email account):
# You can alter the grep to exclude accounts or add as you see fit.
zmaccts | grep "@$DOMAIN" | grep -v galsync | cut -d" " -f1 >> $BACKUPDIR/."$DOMAIN"_accounts.list

full_backup ()
{
    for ACCT in `cat $BACKUPDIR/."$DOMAIN"_accounts.list`
	do
		zmmailbox -z -m $ACCT gru -u https://localhost "//?fmt=tgz" > $BACKUPDIR/full/${ACCT}_FULL_${DATE}.tgz
		SIZE=`stat --printf="%s" $BACKUPDIR/full/"$ACCT"_FULL_$DATE.tgz`
		echo "Backup date and time: `date` - Full backup of $ACCT created at $SIZE bytes." >> $BACKUPDIR/logs/full_backup_$DATE.log
	done
	# Let's remove all the fulls that were 0 bytes in size (sometimes people have no new email):
	/bin/find $BACKUPDIR/full/*.tgz -type f -size 0 -exec rm -rf {} \;
}

diff_backup ()
{
    for ACCT in `cat $BACKUPDIR/."$DOMAIN"_accounts.list`
	do
		zmmailbox -z -m $ACCT gru -u https://localhost '/?fmt=tgz&query=after:'"${WEEKAGO}" > $BACKUPDIR/diff/${ACCT}_DIFF_${DATE}.tgz
		SIZE=`stat --printf="%s" $BACKUPDIR/diff/"$ACCT"_DIFF_$DATE.tgz`
		echo "Backup date and time: `date` - Differential backup of $ACCT created at $SIZE bytes." >> $BACKUPDIR/logs/diff_backup_$DATE.log
	done
	# Let's remove all the differentials that were 0 bytes in size (sometimes people have no new email):
	/bin/find $BACKUPDIR/diff/*.tgz -type f -size 0 -exec rm -rf {} \;
}

inc_backup ()
{
    for ACCT in `cat $BACKUPDIR/."$DOMAIN"_accounts.list`
        do
            	zmmailbox -z -m $ACCT gru -u https://localhost '/?fmt=tgz&query=after:'"${YESTERDAY}" > $BACKUPDIR/inc/${ACCT}_INC_${DATE}.tgz
		SIZE=`stat --printf="%s" $BACKUPDIR/inc/"$ACCT"_INC_$DATE.tgz`
		echo "Backup date and time: `date` - Incremental backup of $ACCT created at $SIZE bytes." >> $BACKUPDIR/logs/inc_backup_$DATE.log
        done
	# Let's remove all the incrementals that were 0 bytes in size (sometimes people have no new email):
	/bin/find $BACKUPDIR/inc/*.tgz -type f -size 0 -exec rm -rf {} \;

}

usage ()
{
	echo $"Usage: $0 {full|diff|inc} {domain}" 1>&2
		RETVAL=2
}


case "$1" in
    full) full_backup ;;
    diff) diff_backup ;;
    inc) inc_backup ;;
    *) usage ;;
esac
