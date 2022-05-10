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
  source $sub