#!/bin/sh
# Get the path to the root of the project
PATH_TO_PROJECT=$(pwd)

# Open a new window and supply the correct commands to launch a godot instance there
osascript -e 'tell app "Terminal"
   do script "
cd '${PATH_TO_PROJECT}/Godot'
godot
  "
end tell'

# Launch godot in the current window
cd "${PATH_TO_PROJECT}/Godot"
godot
