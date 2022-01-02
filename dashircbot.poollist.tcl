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
      set newentrylen [string length $ne