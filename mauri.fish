function mauri
    set -l directory $PWD
    mkdir -p ~/aursign
    if [ $argv[1] ]
        if [ $argv[1] = asennappas ]
            if [ $argv[2] ]
                echo "Olkoon sitten, Mauri asentaa kyllä."
                sleep 2
                cd ~/aurshit/
                git clone "https://aur.archlinux.org/$argv[2].git"
                cd $argv[2]
                echo "Mauri käskee sinua tarkastelemaan PKGBUILDia."
                sleep 2
                less ./PKGBUILD
                read -l -n 1 -P "Luotatko PKGBUILDiin y/N: " yn
                if [ $yn = y ]
                    echo "Mauri asentaa..."
                    makepkg -si
                else
                    echo "Mauri ei asenna :("
                end
            else
                echo "'mauri asennappas <paketti>' asentaa paketteja."
            end
        else if [ $argv[1] = päivitäppäs ]
            if [ $argv[2] ]
                if [ $argv[2] = kaikki ]
                    echo "Olkoon sitten, Mauri päivittää kaiken"
                    sleep 2
                    cd ~/aurshit/
                    set -l updated 0
                    for dir in ./*
                        cd $dir
                        if not git status | grep -q "Your branch is up to date"
                            git pull
                            echo "Mauri käskee sinua tarkastelemaan PKGBUILDia."
                            sleep 2
                            less ./PKGBUILD
                            read -l -n 1 -P "Luotatko PKGBUILDiin y/N: " yn
                            if [ $yn = y ]
                                echo "Mauri asentaa..."
                                makepkg -si
                            else
                                echo "Mauri ei asenna :("
                            end
                            set -l updated 1
                        end
                        cd ..
                    end
                    if [ $updated = 0 ]
                        echo "Ei ollut mitään päivitettävää :("
                    end
                else
                    echo "Olkoon sitten, Mauri päivittää kyllä."
                    sleep 2
                    cd ~/aurshit/
                    cd $argv[2]
                    if not git status | grep -q "Your branch is up to date"
                        git pull
                        echo "Mauri käskee sinua tarkastelemaan PKGBUILDia."
                        sleep 2
                        less ./PKGBUILD
                        read -l -n 1 -P "Luotatko PKGBUILDiin y/N: " yn
                        if [ $yn = y ]
                            echo "Mauri asentaa..."
                            makepkg -si
                        else
                            echo "Mauri ei asenna :("
                        end
                    else
                        echo "Paketti '$argv[2]' on jo ajan tasalla."
                    end
                end
            else
                echo "'mauri päivitäppäs <paketti>' päivittää paketteja."
                echo "'mauri päivitäppäs kaikki' päivittää kaikki paketit."
            end
        else if [ $argv[1] = poistappas ]
            if [ $argv[2] ]
                echo "Olkoon sitten, Mauri poistaa kyllä."
                sleep 2
                cd ~/aurshit/
                sudo rm -rf "./$argv[2]"
                sudo pacman -R $argv[2]
            else
                echo "'mauri poistappas <paketti>' poistaa paketteja."
            end
        else if [ $argv[1] = haeppas ]
            if [ $argv[2] ]
                echo "Etkö osaa käyttää duckduckgo:ta? Olkoon sitten. Mauri hakee kyllä."
                sleep 2
                ddgr !aur $argv[2]
            else
                echo "'mauri haeppas <paketti>' etsii paketteja, jos et osaa käyttää duckduckgo:ta"
            end
        end
    else
        echo "Hei olen Mauri v1.3.1, Mahtava AUR helpperI"
        echo "Käytä komentoja 'asennappas', 'poistappas', 'päivitäppäs' ja 'haeppas'"
    end
    cd $directory
end
