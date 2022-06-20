
#!/usr/bin/tclsh
# Twitter feed display for dashircbot
package require mysqltcl

set dashircbot_twitter_subversion "1.10"
set dashircbot_twitter_script [file tail [ dict get [ info frame [ info frame ] ] file ]]

set dashircbot_twitter_timer ""
set dashircbot_twitter_lasttweetid 0

putlog "++ $::dashircbot_twitter_script v$dashircbot_twitter_subversion loading..."

proc do_fetch_lasttweetid {} {