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
