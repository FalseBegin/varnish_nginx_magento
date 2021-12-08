
# Dash Ninja IRC Bot Script (dashninja-irc)
By Alexandre (aka elbereth) Devilliers

Check the running live website at https://dashninja.pl

This is part of what makes the Dash Ninja monitoring application.
It contains:
- TCP eggdrop scripts for an IRC bot

## Requirement:
* Eggdrop bot (v1.8)
* tcl 8.6 with mysqltcl 3.052 and tcl-tls 1.6
* A Dash Ninja Front-End public API (dashninja-fe).
* A Dash Ninja Database on same machine on localhost (dashninja-db).

## Install:
* Import database structure in your MySQL server
* Go to the root of your eggdrop bot user (ex: cd /home/dashninja2/irc/)
* Get latest code from github:
```shell
git clone https://github.com/elbereth/dashninja-irc.git
```
* Add the following lines to your eggdrop.conf (or whatever main eggdrop conf file you use for your bot):
```
# Dash IRC Bot settings

#  MySQL (dashninja-db)
set dashircbot_mysqluser "dashircbot"
set dashircbot_mysqlpass "somerandompassword"
set dashircbot_mysqldb "dashninja"

#  Path to scripts
set dashircbot_dir "/home/dashninja2/irc/dashninja-irc/"

#  Message length limit
set dashircbot_msglenlimit 442

#  If you want to use the Twitter announces
#   MySQL
set dashircbot_twitter_mysqluser "dashirctwitter"
set dashircbot_twitter_mysqlpass "someotherrandompassword"
#   Twitter nickname
set dashircbot_twitter_screenname "@dashpay"
#   Update script path (needs tweet-php)
set dashircbot_twitter_updatescript "/home/dashninja2/irc/dashircbot/helpers/updatetwitter"

# Dash IRC Bot bootstrap
source /home/dashninja2/irc/dashircbot/dashircbot.tcl
```
* Configure the updatetwitter helper script in ./helpers/ folder by copying updatetwitter.config.inc.php.sample to updatetwitter.config.inc.php and setting up the values as needed.