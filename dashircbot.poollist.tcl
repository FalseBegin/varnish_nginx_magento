#!/usr/bin/tclsh
# Poollist command for dashircbot
package require mysqltcl

set dashircbot_poollist_subversion "1.8"
set dashircbot_poollist_script [file tail [ dict get [ info frame [ info frame ] ] file ]]

putlog "++ $::dashircbot_poollist_script v$dashircbot_poollist_subversion loading..."

proc do_poollist_aux {header data} {
  set ircline ""
  set irclines []
  foreach line $data {
    set irclinelen [string length $ircline]
    if {$line != ""} {
      set info [split $line " "]
      lassign $info username url type miningfee wdmin wdfeeauto wdfeeman
      set newentry "( $url \[$type/$miningfee\] Withdraw >=$wdmin fees auto=$wdfeeauto man=$wdfeeman )"
      set newentrylen [string length $newentry]
      set totallen [expr $newentrylen+$irclinelen]
      if {$irclinelen == 0} {
        set ircline ""
      } elseif {$totallen > $::dashircbot_msglenlimit} {
        lappend irclines "$ircline"
        set ircline ""
      } else {
        set ircline "$ircline|"
      }
      set ircline "$ircline$newentry"
    }
  }
  if {[string length $ircline] > 0} {
    lappend irclines "$ircline"
  }
  set irclinescount [llength $irclines]
  if {$irclinescount > 0} {
    putlog "dashircbot v$::dashircbot_version ($::dashircbot_poollist_script v$::dashircbot_poollist_subversion) \[I\] [lindex [info level 0] 0] output $irclinescount line(s)"
    set idxn 1
    foreach line $irclines {
      if {$irclinescount == 1} {
        puthelp "$header POOLS $line"
      } else {
        puthelp "$header POOLS \[$idxn/$irclinescount\] $line"
      }
      incr idxn
    }
  }
}

proc do_poollist {nick chan} {
  putlog "dashircbot v$::dashircbot_version ($::dashircbot_poollist_script v$::dashircbot_poollist_subversion) \[I\] [lindex [info level 0] 0] from $nick in $chan"
  if {[string tolower $nick] == "alit"} {
    set header "PRIVMSG $nick :"
    puthelp "PRIVMSG $chan :$nick: 8===3 ~� ( O )"
    return
  }
  if {$chan == "PRIVATE"} {
    set header "PRIVMSG $nick :"
  } else {
    set header "PRIVMSG $chan :$nick:"
  }
  if { [catch {set db [::mysql::connect -user $::dashircbot_mysqluser -password $::dashircbot_mysqlpass -db $::dashircbot_mysqldb]} errmsg] } {
    putlog "dashircbot v$::dashircbot_version ($::dashircbot_poollist_script v$::dashircbot_poollist_subversion) \[E\] [lindex [info level 0] 0] $errmsg"
    puthelp "$header Command temporary unavailable."
  } else {
    if { [catch {set data [::mysql::sel $db "SELECT ircnickowner, url, pooltype, fee, wdmin, wdautofee, wdmanfee FROM cmd_pools_list" -list]} errmsg] } {
      putlog "dashircbot v$::dashircbot_version ($::dashircbot_poollist_script v$::dashircbot_poollist_subversion) \[E\] [lindex [info level 0] 0] $errmsg"
      puthelp "$header Command temporary unavailable."
      ::mysql::close $db
    } else {
      ::mysql::close $db
      do_poollist_aux $header $data
    }
  }
}

# Bindings
proc pub:poollist {nick host handle chan {text ""}} {
  do_poollist $nick $chan
}
proc msg:poollist {nick uhost handle text} {
  do_poollist $nick "PRIVATE"
}

bind msg - !pool msg:poollist
bind pub - !pool pub:poollist
bind msg - !pools msg:poollist
bind pub - !pools pub:poollist
bind msg - !poollist msg:poollist
bind pub - !poollist pub:poollist

lappend dashircbot_command_fr { {!pool} {Poles de minage} }
lappend dashircbot_command_en { {!pool} {Mining pools} }

putlog "++ $::dashircbot_poollist_script v$dashircbot_poollist_subve