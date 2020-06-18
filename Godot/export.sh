DMG_NAME="Dismental"
TEMPORARY_DMG_DIR="./bin/temp_dmg"
APP_FULL_PATH="${TEMPORARY_DMG_DIR}/${DMG_NAME}.app"
MAC_VERSION=$1
DMG_FULL_PATH="./bin/${DMG_NAME}_${MAC_VERSION}.dmg"

if [ "$1" != "10.14" ] && [ "$1" != "10.15" ]; then
  echo "Add the mac os version, choose one of [10.14, 10.15]"
  echo "Example usage: 'sudo sh export.sh 10.14'"
  exit
fi

godot --export "MacOSX (${MAC_VERSION})" $DMG_FULL_PATH

mkdir $TEMPORARY_DMG_DIR

# Copy the .app from the export of Godot
hdiutil mount $DMG_FULL_PATH
cp -R "/Volumes/${DMG_NAME}/${DMG_NAME}.app" $TEMPORARY_DMG_DIR
# Get latest mounted image
MOUNTED_DMG_NAME=$(ls -d /Volumes/Dismental* | tail -n 1 | awk -F "/" '{print $(NF)}')
hdiutil unmount "/Volumes/${MOUNTED_DMG_NAME}"

# Copy XML file to .app/Contents/Resources/
cp "./bin/haarcascade_frontalface_default.xml" "${APP_FULL_PATH}/Contents/Resources/"

# Copy symlinks to .app/Contents/Frameworks/
symlinks=($(ls -ld bin/osx/deps_${MAC_VERSION}/*.dylib | grep ^l | awk '{print $9}'))
for symlink in "${symlinks[@]}"; do
  cp -a "./$symlink" "${APP_FULL_PATH}/Contents/Frameworks/"
done

# If -i flag is passed, then place the .app at INSTALL_LOCATION
# if [ $# == 2 ] && [ "$1" == "-i" ]; then
  # cp -R $APP_FULL_PATH "$2";
# fi

# Repack temp_dmg/ into .dmg
hdiutil create -volname $DMG_NAME -srcfolder $TEMPORARY_DMG_DIR -ov -format UDZO $DMG_FULL_PATH

# Nuke temporary directory
rm -rf $TEMPORARY_DMG_DIR

# For more information regarding mounting & moving the .app out of .dmg
# http://commandlinemac.blogspot.com/2008/12/installing-dmg-application-from-command.html
