#!/bin/sh
PATH_TO_PROJECT=$(pwd)
osascript -e 'tell app "Terminal"
   do script "
cd '${PATH_TO_PROJECT}/Godot'
godot
  "
end tell'

# godot

cd "${PATH_TO_PROJECT}/Godot"
godot
