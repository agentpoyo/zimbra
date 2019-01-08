# zimbra
#### Zimbra Scripts

Hopefully these scripts are useful for others who work or deal with Zimbra.

## zimbra_backup.sh

This backup script will perform a Full, Diff and Incremental backups. Designed to run once monthly for an initial FULL, Weekly Diff's and Incrementals will grab just the prior day, intended to run daily.

```
# Basic script usage:
$ ./zimbra_backup.sh full|diff|inc domain.com
```
Where full|diff|inc is backup type and domain.com is the domain you want to grab all accounts from. Domains was added as argument as most if not all Zimbra installs have more than one domain configured. This separates the account backups by domain to keep things tidy.
