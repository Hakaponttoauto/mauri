#!/bin/sh

mauri() {
    # HUOM: Alkuperäinen Mauri nukkui kaksi sekunttia ennen, kun alotti toiminnan. 
    # Kommentoin sleep-lausekkeet pois. Ei huolta, Mauri saa nukuttua kyllä!
    #
    # Jos olet silti huolissasi Maurin unensaannista, saat otettua kommentit helposti pois.
    # Esim. vimillä voit käyttää makroa ' :%s/#s/s/g', joka muuttaa "#s" -> "s".

    maurin_jatokset="$HOME/aurshit" # ~/aurshit on alkuperäisen maurin jätöskansio.
    mkdir -p $maurin_jatokset

    arg_1=$argv[1]
    arg_2=$argv[2]

    directory="$PWD"

    if [ $arg_1 ]; then
        if [ "$arg_1" = "asennappas" ]; then
            if [ $arg_2 ]; then
                echo "Olkoon sitten, Mauri asentaa kyllä."
                #sleep 2
                cd $maurin_jatokset
                git clone "https://aur.archlinux.org/$arg_2.git"
                cd $arg_2
                echo "Mauri käskee sinua tarkastelemaan PKGBUILDia."
                less ./PKGBUILD
                read "?Luotatko PKGBUILDiin? y/N: " yn
                if [ "$yn" = "y" ]; then
                    echo "Mauri asentaa..."
                    makepkg -si
                else
                    echo "Mauri ei asenna :("
                fi
            else
                echo "'mauri asennappas <paketti>' asentaa paketteja."
            fi
        elif [ "$arg_1" = "päivitäppäs" ]; then
            if [ $arg_2 ]; then
                if [ "$arg_2" = "kaikki" ]; then
                    echo "Olkoon sitten, Mauri päivittää kaiken."
                    #sleep 2 
                    cd $maurin_jatokset
                    updated=0
                    for dir in ./*; do
                        cd $dir
                        git fetch
                        git status | grep -q "Your branch is up to date"
                        if [ $? -eq 1 ]; then
                            git pull
                            echo "Mauri käskee sinua tarkastelemaan PKGBUILDia."
                            sleep 2
                            less ./PKGBUILD
                            read "?Luotatko PKGBUILDiin? y/N: " yn
                            if [ "$yn" = "y" ]; then
                                echo "Mauri asentaa..."
                                makepkg -si
                            else
                                echo "Mauri ei asenna :("
                            fi
                            updated=1
                        fi
                        cd ..
                    done
                    if [ $updated -eq 0 ]; then
                        echo "Ei ollut mitään päivitettävää :("
                    fi
                else
                    echo "Olkoon sitten, Mauri päivittää kyllä."
                    #sleep 2
                    cd $maurin_jatokset/$arg_2
                    git status | grep -q "Your branch is up to date"
                    if [ $? -eq 1 ]; then
                        git pull
                        echo "Mauri käskee sinua tarkastelemaan PKGBUILDia."
                        #sleep 2
                        less ./PKGBUILD
                        read -l -n 1 -P "?Luotatko PKGBUILDiin? y/N: " yn
                        if [ "$yn" = "y" ]; then
                            echo "Mauri asentaa..."
                            makepkg -si
                        else
                            echo "Mauri ei asenna :("
                        fi
                    else
                        echo "Paketti '$arg_2' on jo ajan tasalla."
                    fi
                fi
            else
                echo "'mauri päivitäppäs <paketti>' päivittää paketteja."
                echo "'mauri päivitäppäs kaikki' päivittää kaikki paketit."
            fi
        elif [ "$arg_1" = "poistappas" ]; then
            if [ $arg_2 ]; then
                echo "Olkoon sitten, Mauri poistaa kyllä."
                #sleep 2
                cd $maurin_jatokset
                if [ $? -eq 0 ]; then 
                    sudo pacman -R $arg_2
                    sudo rm -rf $arg_2
                else
                    echo "Pakettia '$arg_2' ei voitu poistaa."
                fi
            else
                echo "'mauri poistappas <paketti>' poistaa paketteja."
            fi
        elif [ "$arg_1" = "haeppas" ]; then
            if [ $arg_2 ]; then
                echo "Etkö osaa käyttää duckduckgo:ta? Olkoon sitten. Mauri hakee kyllä."
                #sleep 2
                ddgr !aur $arg_2
            else
                echo "'mauri haeppas <paketti>' etsii paketteja, jos et osaa käyttää duckduckgo:ta"
            fi
        fi
    else
        echo "Hei olen Mauri v1.3.2, Mahtava AUR helpperI"
        echo "Käytä komentoja 'asennappas', 'poistappas', 'päivitäppäs' ja 'haeppas'"
        echo "!!! DISCLAIMER: Mauri voi tappaa !!!"
    fi

    cd $directory
}

