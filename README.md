# zimbra
#### Zimbra Scripts

Hopefully these scripts are useful for others who work or deal with Zimbra.

## zimbra_backup.sh

This backup script will perform a Full, Diff and Incremental backups. Designed to run once monthly for an initial FULL, Weekly Diff's and Incrementals will grab just the prior day, intended to run daily.

As is, it's designed to run as a cron job just after midnight each day as the script grabs the prior day.

Here is example cron entries for multiple domains (adjust accordingly on how long these typically run):

```
# Incremental Backups Mon - Saturday at 00:01:
10 0 * * 1,2,3,4,5,6 su - zimbra -c '/home/zimbra/bin/zimbra_backup.sh inc domain1.com' 2>&1
30 0 * * 1,2,3,4,5,6 su - zimbra -c '/home/zimbra/bin/zimbra_backup.sh inc domain2.com' 2>&1

# Full Backups on First Saturday of each month startin at 2:00 AM:
0 2 1-7 * * [ "$(date '+\%a')" = "Sat" ] && su - zimbra -c '/home/zimbra/bin/zimbra_backup.sh full domain1.com' 2>&1
0 6 1-7 * * [ "$(date '+\%a')" = "Sat" ] && su - zimbra -c '/home/zimbra/bin/zimbra_backup.sh full domain2.com' 2>&1

# Differential Backups every Saturday excluding the first one at 2:00AM:
0 2 8-31 * * [ "$(date '+\%a')" = "Sat" ] && su - zimbra -c '/home/zimbra/bin/zimbra_backup.sh diff domain1.com' 2>&1
30 2 8-31 * * [ "$(date '+\%a')" = "Sat" ] && su - zimbra -c '/home/zimbra/bin/zimbra_backup.sh diff domain2.com' 2>&1
```

```
# Basic script usage:
$ ./zimbra_backup.sh full|diff|inc domain.com
```
Where full|diff|inc is backup type and domain.com is the domain you want to grab all accounts from. Domains was added as argument as most if not all Zimbra installs have more than one domain configured. This separates the account backups by domain to keep things tidy.
