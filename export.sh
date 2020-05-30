# This script should be run from the root of the repository
# cp wouldn't work for me unless using sudo ~ @ksavanderwerff
cd Godot/
godot --export "MacOSX" ./bin/DefuseTheBomb.dmg
cd - # Return to your last position
hdiutil mount ./Godot/bin/DefuseTheBomb.dmg
sudo cp -R /Volumes/DefuseTheBomb/DefuseTheBomb.app ~/Applications/
sudo cp ./src/opencv_data/haarcascades/haarcascade_frontalface_default.xml ~/Applications/DefuseTheBomb.app/Contents/Resources/
hdiutil unmount /Volumes/DefuseTheBomb

# For more information regarding mounting & moving the .app out of .dmg
# http://commandlinemac.blogspot.com/2008/12/installing-dmg-application-from-command.html