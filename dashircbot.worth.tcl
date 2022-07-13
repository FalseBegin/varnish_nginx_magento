
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