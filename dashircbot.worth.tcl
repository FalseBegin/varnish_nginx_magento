
#!/usr/bin/tclsh
# Worth command for dashircbot
package require http
package require tls
package require json

::http::register https 443 [list ::tls::socket -tls1 1]

set dashircbot_worth_subversion "2.17"
set dashircbot_worth_script [file tail [ dict get [ info frame [ info frame ] ] file ]]

set dashircbot_translation [dict create \
                                    "usage_calc" [dict create \
        "en" "Usage: !calc\[fiat\] <hashrate_in_khs> - \[fiat\] can be eur or usd (default: usd) - Ex: !calc 10000" \
        "fr" "Utilisation: !calc\[fiat\] <hachage_en_khs> - \[fiat\] peux être eur ou usd (par défaut: usd) - Ex: !calc 10000\]"] \
                                    "usage_diff" [dict create \
        "en" "Usage: !diff \[difficulty_value\] - If no difficulty is given as parameter, will use current one." \
        "fr" "Utilisation: !diff \[valeur_difficulté\] - Si la difficulté n'est pas spécifié, utilisera l'actuelle."] \
                                    "usage_mnworth" [dict create \
        "en" "Usage: !mnworth\[fiat\] <number_of_masternodes> - \[fiat\] can be eur or usd (default: usd) - Ex: !mnworth 2 or !mnw" \
        "fr" "Utilisation: !mnvaleur\[fiat\] <nombre_de_masternodes> - \[fiat\] peux être eur ou usd (par défaut: usd) - Ex: !mnvaleur 2 ou !mnv"] \
                                    "usage_worth" [dict create \
        "en" "Usage: !worth\[fiat\] <amount_DASH|Dash_Address> - \[fiat\] can be eur or usd (default: usd) - Ex: !worth 1234.5 or !worth Xr57hNKbEzNHFkTsUmfhPxKRfnnt9nVe7z or !w 76" \
        "fr" "Utilisation: !valeur\[fiat\] <montant_DASH|Addresse_Dash> - \[fiat\] peux être eur ou usd (par défaut: usd) - Ex: !valeur 1234.5 ou !valeur Xr57hNKbEzNHFkTsUmfhPxKRfnnt9nVe7z ou !v 76"] \
                                    "action_unavailable" [dict create \
        "en" "Command is temporarily unavailable." \
        "fr" "Commande temporairement indisponible."] \
                                    "action_unknown" [dict create \
        "en" "Command %s is unknown." \
        "fr" "Commande %s inconnue."] \
                                    "result_calc" [dict create \
        "en" "With last 24h supply of %s DASH (source:%s|%s) and a network hashrate of %s (source:%s|%s) your %s would have generated %.9f DASH @ %s DASH/BTC (source:%s|%s) = %.9f BTC/Day / %.2f %s/Day (source:%s|%s)" \
        "fr" "Avec %s générés ces derniéres 24h (source:%s|%s) et un hachage réseau de %s (source:%s|%s) vos %s aurais généré %.9f DASH @ %s DASH/BTC (source:%s|%s) = %.9f BTC/Day / %.2f %s/Day (source:%s|%s)"] \
                                    "result_diff" [dict create \
        "en" "%s difficulty: %s%s Coin generation: %.2f DASH miner (%s%%) + %.2f DASH masternode (%s%%) + %.2f DASH budgets (%s%%) = %.2f DASH total" \
        "fr" "Difficulté %s: %s%s Génération de piéces: %.2f DASH mineur (%s%%) + %.2f DASH masternode (%s%%) + %.2f DASH budgets (%s%%) = %.2f DASH au total"] \
                                    "result_diff_asked" [dict create \
        "en" "Asked" \
        "fr" "demandée"] \
                                    "result_diff_current" [dict create \
        "en" "Current" \
        "fr" "actuelle"] \
                                    "result_diff_source" [dict create \
        "en" " (source:%s|%s)" \
        "fr" " (source:%s|%s)"] \
                                    "result_marketcap" [dict create \
        "en" "Dash position = %d with %s BTC market cap (%s %s with supply of %s DASH) and a 24h volume of %s BTC (%s %s) %s%% (source:%s|%s)" \
        "fr" "Position Dash = %d avec une capitalisation marche de %s BTC (%s %s avec un total de %s DASH) et un volume journalier de %s BTC (%s %s) %s%% (source:%s|%s)"] \
                                    "result_mnstats" [dict create \
        "en" "%d active masternodes (source:%s|%s) ATH = %d (%s UTC) @ %s DASH/BTC (source:%s|%s) = %.2f BTC / %.2f %s in stake (source:%s|%s)" \
        "fr" "%d active masternodes (source:%s|%s) ATH = %d (%s UTC) @ %s DASH/BTC (source:%s|%s) = %.2f BTC / %.2f %s en épargne (source:%s|%s)"] \
                                    "result_mnworth" [dict create \
        "en" "%s masternodes = %.3f DASH/Day (source:%s|%s) using %s%% blocks paid at %s%% last 24h (source:%s|%s) @ %s DASH/BTC (source:%s|%s) = %.9f BTC/Day / %.2f %s/Day (source:%s|%s)" \
        "fr" "%s masternodes = %.3f DASH/Jour (source:%s|%s) avec %s%% des blocs payés à %s%% ces dernières 24h (source:%s|%s) @ %s DASH/BTC (source:%s|%s) = %.9f BTC/Jour / %.2f %s/Jour (source:%s|%s)"] \
                                    "result_worth" [dict create \
        "en" "%s DASH @ %s DASH/BTC (source:%s|%s) = %.6f BTC / %.2f %s (source:%s|%s)" \
        "fr" "%s DASH @ %s DASH/BTC (source:%s|%s) = %.6f BTC / %.2f %s (source:%s|%s)"] \
 ]

set dashircbot_tablevar_refreshinterval 30

putlog "++ $::dashircbot_worth_script v$dashircbot_worth_subversion loading..."

set dashircbot_tablevar [dict create]
set dashircbot_tablevarlast 0

proc dashircbot_getdeltatime {from to} {

  set res ""
  set delta [expr $to-$from]
  if {$delta < 0} {
    set delta 0
  }
  set deltasec [expr $delta%60]
  set deltamin [expr ($delta/60)%60]