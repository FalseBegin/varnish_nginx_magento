set dashircbot_version "1.1.0"

set dashircbot_script [file tail [ dict get [ info frame [ info frame ] ] file ]]

set dashircbot_command_en ""
set dashircbot_command_fr ""

putlog "$::dashircbot_script v$::dashircbot_version (by elberethzone) loading..."
set putlogloaded "$::dashircbot_script v$::dashircbot_version (by elberethzone) loaded!"