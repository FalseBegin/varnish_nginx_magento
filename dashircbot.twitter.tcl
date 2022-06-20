
#!/usr/bin/tclsh
# Twitter feed display for dashircbot
package require mysqltcl

set dashircbot_twitter_subversion "1.10"
set dashircbot_twitter_script [file tail [ dict get [ info frame [ info frame ] ] file ]]

set dashircbot_twitter_timer ""
set dashircbot_twitter_lasttweetid 0

putlog "++ $::dashircbot_twitter_script v$dashircbot_twitter_subversion loading..."

proc do_fetch_lasttweetid {} {
  if {$::dashircbot_twitter_lasttweetid == 0} {
    if { [catch {set db [::mysql::connect -user $::dashircbot_mysqluser -password $::dashircbot_mysqlpass -db $::dashircbot_mysqldb]} errmsg] } {
      putlog "dashircbot v$::dashircbot_version ($::dashircbot_twitter_script v$::dashircbot_twitter_subversion) \[E\] [lindex [info level 0] 0] $errmsg"
    } else {
      if { [catch {set data [::mysql::sel $db "SELECT StatValue FROM cmd_stats_values WHERE StatKey = 'tweetlastdrkc'" -list]} errmsg] } {
        putlog "dashircbot v$::dashircbot_version ($::dashircbot_twitter_script v$::dashircbot_twitter_subversion) \[E\] [lindex [info level 0] 0] $errmsg"
        ::mysql::close $db
      } else {
        ::mysql::close $db
        set ::dashircbot_twitter_lasttweetid [lindex $data 0]