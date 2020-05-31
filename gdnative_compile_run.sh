# Compile gdnative for OSX and run the main scene afterwards,
# easy for quick debugging when developing gdnative
scons platform=osx
cd Godot/
godot
cd ..