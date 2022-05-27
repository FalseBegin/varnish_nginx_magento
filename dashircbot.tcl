set dashircbot_version "1.1.0"

set dashircbot_script [file tail [ dict get [ info frame [ info frame ] ] file ]]

set dashircbot_command_en ""
set dashircbot_command_fr ""

putlog "$::dashircbot_script v$::dashircbot_version (by elberethzone) loading..."
set putlogloaded "$::dashircbot_script v$::dashircbot_version (by elberethzone) loaded!"

set dashircbot_commandlist_en ""
set dashircbot_commandlist_fr ""

proc dashircbot_command_cmp {a b} {
  return [string compare [lindex $a 0] [lindex $b 0]]
}

# Load sub-scripts
set subfiles [glob -dir "$::dashircbot_dir" dashircbot.*.tcl]
putlog "== Found [llength $subfiles] sub-scripts to load:"
foreach subfile $subfiles {
  source $subfile
}

# Sort commands
set dashircbot_command_en [lsort -command dashircbot_command_cmp $dashircbot_command_en]
set dashircbot_command_fr [lsort -command dashircbot_command_cmp $dashircbot_command_fr]

# Prepare the command list for !help display
set idxn 0
set totnen [llength $dashircbot_command_en]
set totn [expr $totnen-1]
foreach line $dashircbot_command_en {
  set command [lindex $line 0]
  set desc [lindex $line 1]
  if { $desc == "" } {
    set dashircbot_commandlist_en "$dashircbot_commandlist_en\( $command )"
  } else {
    set dashircbot_commandlist_en "$dashircbot_comma