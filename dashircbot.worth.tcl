
#!/usr/bin/tclsh
# Worth command for dashircbot
package require http
package require tls
package require json

::http::register https 443 [list ::tls::socket -tls1 1]

set dashircbot_worth_subversion "2.17"
set dashircbot_worth_script [file tail [ dict get [ info frame [ info frame ] ] file ]]
