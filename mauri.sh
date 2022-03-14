#!/bin/sh

maurin_jatokset="$HOME/.maurishit" # "$HOME/aurshit" on alkuperäisen maurin jätöskansio.
mkdir -p "$maurin_jatokset" 

directory="$PWD"

cd_and_exit() {
    if ! cd "$directory"; then
        echo "Hupsis, Mauri ei päässyt takaisin :("
    fi
    exit 1
}

show_help() {
    echo "Hei olen Mauri v1.3.2, Mahtava AUR helpperI"
    echo "Käytä komentoja 'asennappas', 'uudelleenasennappas', 'poistappas', 'päivitäppäs', 'listaappas' ja 'haeppas'"
    echo "!!! DISCLAIMER: Mauri voi tappaa !!!"
}

install_package() {

    if ! cd "$maurin_jatokset"; then
        echo "Hupsis, Mauri ei päässyt jätöspaikkaansa."
        cd_and_exit
    fi
    
    gitclone=$(git clone "https://aur.archlinux.org/$1.git")
    gitclone_exitcode=$?

    if echo "$gitclone" | grep -q "You appear to have cloned an empty repository."
    then
        echo "Mauri ei löytänyt ton nimistä pakettia." >/dev/stderr
        rm -rf "${maurin_jatokset:?}/$1"
        cd_and_exit
    elif [ $gitclone_exitcode != 0 ]; then
        echo "Mauri ei onnistunut asentamaan tota pakettia." > /dev/stderr
        rm -rf "${maurin_jatokset:?}/$1" 
        cd_and_exit
    fi
    
    if ! cd "$1"; then
        echo "Hupsis nyt kävi hassusti, eikä Mauri päässyt paketin kansioon"
        cd_and_exit
    fi

    echo "Mauri käskee sinua tarkastelemaan PKGBUILDia."
    less ./PKGBUILD || cd_and_exit

    printf "Luotatko PKGBUILDiin? y/N: "
    read -r yn
    if [ "$yn" = "y" ]; then
        echo "Mauri asentaa..."
        makepkg -si
    else
        echo "Mauri ei asenna :("
    fi
}

if [ "$1" ]; then
    if [ "$1" = "asennappas" ]; then
        if [ "$2" ]; then
            echo "Olkoon sitten, Mauri asentaa kyllä."
            sleep 2
            install_package "$2"
        else
            echo "'mauri asennappas <paketti>' asentaa paketteja."
        fi
    elif [ "$1" = "uudelleenasennappas" ]; then
        echo "Olkoon sitten, Mauri uudelleenasentaa."

        if [ "$2" ]; then
            if cd "$maurin_jatokset"; then 
                /bin/rm -rf "$2"
                install_package "$2"
            else
                echo "Mauri ei löytänyt pakettia." >/dev/stderr
            fi
        else
            echo "'mauri uudelleenasennappas <paketti>' uudelleenasentaa paketteja."
        fi
    elif [ "$1" = "päivitäppäs" ]; then
        if [ "$2" ]; then
            if [ "$2" = "kaikki" ]; then
                echo "Olkoon sitten, Mauri päivittää kaiken."
                if ! cd "$maurin_jatokset"; then
                    echo "Mauri ei päässyt jätöspaikkaansa :(" > /dev/stderr
                    cd_and_exit
                fi
                updated=0

                for dir in ./*; do
                    cd "$dir" || echo "hupsis nyt ei onnistunut"
                    git fetch
                    if ! git status | grep -q "Your branch is up to date"; then
                        git pull
                        echo "Mauri käskee sinua tarkastelemaan PKGBUILDia."
                        sleep 2
                        less ./PKGBUILD
                        printf "Luotatko PKGBUILDiin? y/N: "
                        read -r yn
                        if [ "$yn" = "y" ]; then
                            echo "Mauri asentaa..."
                            makepkg -si
                        else
                            echo "Mauri ei asenna :("
                        fi
                        updated=1
                    fi
                    cd .. || exit 1
                done

                if [ $updated -eq 0 ]; then
                    echo "Ei ollut mitään päivitettävää"
                fi
            else
                echo "Olkoon sitten, Mauri päivittää kyllä."
                sleep 2
                if ! cd "$maurin_jatokset/$2"; then
                    echo "hupsis" 
                    exit 1
                fi

                if ! git fetch; then
                    echo "Ei voitu hakea päivityksiä, ootko netissä?"
                    cd_and_exit
                fi
                if git status | grep -q "Your branch is up to date"; then
                    echo "Paketti on jo ajan tasalla"
                else
                    git pull
                    echo "Mauri käskee sinua tarkastelemaan PKGBUILDia."
                    sleep 2
                    less ./PKGBUILD
                    printf "Luotatko PKGBUILDiin? y/N: " 
                    read -r yn
                    if [ "$yn" = "y" ]; then
                        echo "Mauri asentaa..."
                        makepkg -si
                    else
                        echo "Mauri ei asenna :("
                    fi
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

            if cd "$maurin_jatokset"; then 
                /usr/bin/pacman -R "$2" 
                /bin/rm -rf "$2" 
            else
                echo "Mauri ei löytänyt pakettia." >/dev/stderr
            fi
        else
            echo "'mauri poistappas <paketti>' poistaa paketteja."
        fi
    elif [ "$1" = "haeppas" ]; then
        if [ "$2" ]; then
            echo "Etkö osaa käyttää duckduckgo:ta? Olkoon sitten. Mauri hakee kyllä."
            ddgr --np "\!aur $2"
        else
            echo "'mauri haeppas <paketti>' etsii paketteja, jos et osaa käyttää duckduckgo:ta"
        fi
    elif [ "$1" = "listaappas" ]; then
        echo "Olkoon sitten, Mauri listaa kyllä."
        if ! exa -l "$maurin_jatokset"; then
            ls -l --color "$maurin_jatokset"
        fi
    else
        show_help
    fi
else
    show_help
fi

cd "$directory" || echo "Mauri ei onnistunut menemään takaisin." >/dev/stderr && exit

