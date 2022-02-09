#!/bin/sh

mauri() {

    maurin_jatokset="$HOME/.maurishit" # "$HOME/aurshit" on alkuperäisen maurin jätöskansio.
    mkdir -p "$maurin_jatokset" 

    directory="$PWD"

    if [ "$1" ]; then
        if [ "$1" = "asennappas" ]; then
            if [ "$2" ]; then
                echo "Olkoon sitten, Mauri asentaa kyllä."
                sleep 2

                if ! \cd "$maurin_jatokset"; then
                    echo "Hupsis, Mauri ei päässyt jätöspaikkaansa."
                    return 1
                fi

                gitclone=$(git clone "https://aur.archlinux.org/$2.git")
                gitclone_returncode=$?

                if echo "$gitclone" | grep -q "You appear to have cloned an empty repository."
                then
                    echo "Mauri ei löytänyt ton nimistä pakettia." >/dev/stderr
                    rm -rf "${maurin_jatokset:?}/$2"
                    \cd "$directory" || return 1
                    return 1

                elif [ $gitclone_returncode != 0 ]; then
                    echo "Mauri ei onnistunut asentamaan tota pakettia." > /dev/stderr
                    \cd "$directory" || return 1
                    return 1
                fi
                
                if ! \cd "$2"; then
                    echo "Hupsis nyt kävi hassusti, eikä Mauri päässyt paketin kansioon"
                    \cd "$directory" || return 1
                    return 1
                fi

                ls
                if [ -e "PKGBUILD" ]; then
                    echo "Mauri käskee sinua tarkastelemaan PKGBUILDia."
                    less ./PKGBUILD 
                else
                    echo "Hupsis, Mauri ei löytänyt PKGBUILDia." >/dev/stderr 
                    \cd "$directory" || return 1
                    return 1
                fi

                read -r "?Luotatko PKGBUILDiin? y/N: " yn
                if [ "$yn" = "y" ]; then
                    echo "Mauri asentaa..."
                    makepkg -si
                else
                    echo "Mauri ei asenna :("
                fi
            else
                echo "'mauri asennappas <paketti>' asentaa paketteja."
            fi
        elif [ "$1" = "päivitäppäs" ]; then
            if [ "$2" ]; then
                if [ "$2" = "kaikki" ]; then
                    echo "Olkoon sitten, Mauri päivittää kaiken."
                    sleep 2 
                    \cd "$maurin_jatokset"  || return 1
                    updated=0

                    for dir in ./*; do

                       \cd "$dir" || echo "hupsis nyt ei onnistunut"; continue
                        git fetch
                        if ! git status | grep -q "Your branch is up to date"; then
                            git pull
                            echo "Mauri käskee sinua tarkastelemaan PKGBUILDia."
                            sleep 2
                            less ./PKGBUILD
                            read -r "?Luotatko PKGBUILDiin? y/N: " yn
                            if [ "$yn" = "y" ]; then
                                echo "Mauri asentaa..."
                                makepkg -si
                            else
                                echo "Mauri ei asenna :("
                            fi
                            updated=1
                        fi
                       \cd .. || return 1
                    done
                    if [ $updated -eq 0 ]; then
                        echo "Ei ollut mitään päivitettävää :("
                    fi
                else
                    echo "Olkoon sitten, Mauri päivittää kyllä."
                    sleep 2
                   \cd "$maurin_jatokset/$2" || echo "hupsis"; return
                    
                    if git status | grep -q "Your branch is up to date"; then
                        git pull
                        echo "Mauri käskee sinua tarkastelemaan PKGBUILDia."
                        sleep 2
                        less ./PKGBUILD
                        read -r "?Luotatko PKGBUILDiin? y/N: " yn
                        if [ "$yn" = "y" ]; then
                            echo "Mauri asentaa..."
                            makepkg -si
                        else
                            echo "Mauri ei asenna :("
                        fi
                    else
                        echo "Paketti '$2' on jo ajan tasalla."
                    fi
                fi
            else
                echo "'mauri päivitäppäs <paketti>' päivittää paketteja."
                echo "'mauri päivitäppäs kaikki' päivittää kaikki paketit."
            fi
        elif [ "$1" = "poistappas" ]; then
            if [ "$2" ]; then
                echo "Olkoon sitten, Mauri poistaa kyllä."
                sleep 2

                if \cd "$maurin_jatokset"; then 
                    echo "Mauri poistaa nyt pacman pakettia..."
                    sudo /usr/bin/pacman -R "$2" \
                        || doas /usr/bin/pacman -R "$2" \
                        || su -c "pacman -R $2" root

                    echo "Mauri poistaa nyt paketin jätöksiä jätöskansiosta..."
                    sudo /bin/rm -rf "$2" \
                        || doas /bin/rm -rf "$2" \
                        || /bin/su -c "/bin/rm -rf $2" root
                else
                    echo "Mauri ei löytänyt kansiota paketille." >/dev/stderr
                fi
            else
                echo "'mauri poistappas <paketti>' poistaa paketteja."
            fi
        elif [ "$1" = "haeppas" ]; then
            if [ "$2" ]; then
                echo "Etkö osaa käyttää duckduckgo:ta? Olkoon sitten. Mauri hakee kyllä."
                sleep 2
                ddgr --np "\!aur $2"
            else
                echo "'mauri haeppas <paketti>' etsii paketteja, jos et osaa käyttää duckduckgo:ta"
            fi
        elif [ "$1" = "listaappas" ]; then
            if ! exa -l "$maurin_jatokset"; then
               \ls -l --color "$maurin_jatokset"
            fi
        fi
    else
        echo "Hei olen Mauri v1.3.2, Mahtava AUR helpperI"
        echo "Käytä komentoja 'asennappas', 'poistappas', 'päivitäppäs', 'listaappas' ja 'haeppas'"
        echo "!!! DISCLAIMER: Mauri voi tappaa !!!"
    fi

   \cd "$directory" || echo "Mauri ei onnistunut menemään takaisin." >/dev/stderr && return
}

