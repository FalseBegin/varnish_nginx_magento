#!/usr/bin/tclsh
# Poollist command for dashircbot
package require mysqltcl

set dashircbot_poollist_subversion "1.8"
set dashircbot_poollist_script [file tail [ dict get [ info frame [ info frame ] ] file ]]

putlog "++ $::dashircbot_poollist_script v$dashircbot_poollis