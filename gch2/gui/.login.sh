gch2_pub_git='https://raw.githubusercontent.com/Glatt-Air-Techniques-Inc/public/master/gch2/'

# stylize terminal
curl "${gch2_pub_git}gui/gterminal.preferences" | dconf load /org/gnome/terminal/
rm /home/glatt/.config/autostart/login.desktop
rm -- "$0"
