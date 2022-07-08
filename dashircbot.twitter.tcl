
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
        putlog "dashircbot v$::dashircbot_version ($::dashircbot_twitter_script v$::dashircbot_twitter_subversion) \[I\] [lindex [info level 0] 0] success: $::dashircbot_twitter_lasttweetid"
      }
    }
  }
  return [expr $::dashircbot_twitter_lasttweetid > 0]
}

proc do_save_lasttweetid {} {
  if {$::dashircbot_twitter_lasttweetid != 0} {
    if { [catch {set db [::mysql::connect -user $::dashircbot_twitter_mysqluser -password $::dashircbot_twitter_mysqlpass -db $::dashircbot_mysqldb]} errmsg] } {
      putlog "dashircbot v$::dashircbot_version ($::dashircbot_twitter_script v$::dashircbot_twitter_subversion) \[E\] [lindex [info level 0] 0] $errmsg"
    } else {
      if { [catch {set data [::mysql::exec $db "UPDATE cmd_stats_values SET StatValue = $::dashircbot_twitter_lasttweetid WHERE StatKey = 'tweetlastdrkc'"]} errmsg] } {
        putlog "dashircbot v$::dashircbot_version ($::dashircbot_twitter_script v$::dashircbot_twitter_subversion) \[E\] [lindex [info level 0] 0] $errmsg"
        ::mysql::close $db
      } else {
        putlog "dashircbot v$::dashircbot_version ($::dashircbot_twitter_script v$::dashircbot_twitter_subversion) \[I\] [lindex [info level 0] 0] success: $::dashircbot_twitter_lasttweetid"
        ::mysql::close $db
      }
    }
  }
}

proc do_showtwitter {} {
  global dashircbot_twitter_timer dashircbot_twitter_screenname
  if { [catch {set test [exec $::dashircbot_twitter_updatescript]} errmsg] } {
    putlog "dashircbot v$::dashircbot_version ($::dashircbot_twitter_script v$::dashircbot_twitter_subversion) \[E\] [lindex [info level 0] 0] $errmsg"
  } else {
    if {[do_fetch_lasttweetid]} {
      if { [catch {set db [::mysql::connect -user $::dashircbot_mysqluser -password $::dashircbot_mysqlpass -db $::dashircbot_mysqldb]} errmsg] } {
        putlog "dashircbot v$::dashircbot_version ($::dashircbot_twitter_script v$::dashircbot_twitter_subversion) \[E\] [lindex [info level 0] 0] $errmsg"
      } else {
        if { [catch {set data [::mysql::sel $db "SELECT * FROM cmd_twitter WHERE account = '$dashircbot_twitter_screenname' AND id > $::dashircbot_twitter_lasttweetid ORDER BY id" -list]} errmsg] } {
          putlog "dashircbot v$::dashircbot_version ($::dashircbot_twitter_script v$::dashircbot_twitter_subversion) \[E\] [lindex [info level 0] 0] $errmsg"
          ::mysql::close $db
        } else {
          ::mysql::close $db
          if {[llength $data] > 0} {
            foreach line $data {
              putlog "dashircbot v$::dashircbot_version ($::dashircbot_twitter_script v$::dashircbot_twitter_subversion) \[I\] [lindex [info level 0] 0] New tweet: [lindex $line 0] ([lindex $line 2]): [lindex $line 3]"
              regsub -all {\n} [lindex $line 3] " " tweettext
              puthelp "PRIVMSG #dash-fr :TWITTER FEED [lindex $line 0] ([lindex $line 2]): $tweettext"
              puthelp "PRIVMSG #dashpay :TWITTER FEED [lindex $line 0] ([lindex $line 2]): $tweettext"
              if {[lindex $line 1] > $::dashircbot_twitter_lasttweetid} {
                set ::dashircbot_twitter_lasttweetid [lindex $line 1]
              }
            }
            do_save_lasttweetid
          } else {