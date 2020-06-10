# By now this file is kind of a mess of all kinds of commands, but it's still useful to keep as a reference

# Below was a snippet to add a suffix for every .dylib file
# Every LD_LOAD_DYLIB path would be updated to point to the new .dylib file name too
# Symlinks would set to point to the new .dylib names as well

# Update libraries
# for file in $(ls -ld *.dylib | grep -v ^l | awk '{print $9}'); do
#   NEWFILE="${file%.dylib}-ea9974ed.dylib"
#   echo ""
#   echo "${file} -> $NEWFILE"
#   echo "---"
#   otool -L $file | sed 1,2d | grep -e @loader_path -e @rpath | awk '{print $1}' | \
#     while read i
#     do
#       PREFIX=$(echo $i | cut -d"/" -f1)
#       TARGET_LIB_NAME=$(basename -- "$i")
#       NEW_TARGETED_LIB="${TARGET_LIB_NAME%.dylib}-ea9974ed.dylib"
#       NEW_FULL_PATH="$PREFIX/$NEW_TARGETED_LIB"
#       # echo "line: $i -> $NEW_FULL_PATH"
#       install_name_tool -change $i $NEW_FULL_PATH $file
#     done
#   mv $file $NEWFILE
# done

# Update symlinks
# ls -l | grep ^l | awk '{ print $9, $11 }' | \
#   while read symlink
#   do
#     NAME=$(echo $symlink | cut -d ' ' -f1)
#     NEW_NAME="${NAME%.dylib}-ea9974ed.dylib"
#     TO_OLD=$(echo $symlink | cut -d ' ' -f2)
#     TO_NEW="${TO_OLD%.dylib}-ea9974ed.dylib"
#     echo ""
#     echo "$NAME -> $TO_OLD -> $TO_NEW"
#     ln -sfn $TO_NEW $NAME
#     mv $NAME $NEW_NAME
    
#   done

# cd lib/

# dependencies=($(ls -d libopencv_*.4.3.0.dylib))
# for i in "${dependencies[@]}"; do
#   echo "$i"
#   sudo install_name_tool -change "/usr/local/opt/openblas/lib/libopenblas.0.dylib" "@loader_path/libopenblas.0.dylib" $i
# done

# # openblas_deps=("libblas.dylib" "liblapack.dylib" "libopenblas.0.dylib" "libopenblas.dylib" "libopenblasp-r0.3.9.dylib")
# # for i in "${dependencies[@]}"; do

# # Change reference of opencv lib to ceres lib
# install_name_tool -change "/usr/local/opt/ceres-solver/lib/libceres.1.dylib" "@loader_path/libceres.1.dylib" libopencv_sfm.4.3.0.dylib

# # ceres lib -> openblas
# install_name_tool -change "/usr/local/opt/openblas/lib/libopenblas.0.dylib" "@loader_path/libopenblas.0.dylib" libceres.1.14.0.dylib



# Add RPATHS to Opencv dependencies
# opencv_deps=($(ls -d libopencv_*4.3.0.dylib))
# for dep in "${opencv_deps[@]}"; do
#   echo "$dep"
#   install_name_tool -add_rpath @loader_path/ $dep
# done


# ls -l libopencv_dnn.4.3.0.dylib | {
#   while read i; do otool -L $i; done
# } 

# ls -d *.dylib | {                     
# while read i; do echo $i; done    
# }


# otool -L libopencv_dnn.4.3.0.dylib | grep ^/usr/loca/opt {
#   while read i; do echo "Ayay   $i"; done
# }



# Find references to /usr/local/opt
# otool -L libopencv_dnn.4.3.0.dylib |
# tail -n +3 |
# grep "/usr/local/opt/" |
# cut -d' ' -f1 | {
#   while read i; do echo "install_name_tool -change $i"; done
# }



# Run otool -L on all .dylib files
# dylibs=($(ls -d *.dylib))
# for dylib in "${dylibs[@]}"; do
#   echo ""
#   otool -L $dylib
# done

# deps=(
#   "libopencv_highgui.4.3"
#   "libopencv_imgproc.4.3"
#   "libopencv_objdetect.4.3"
#   "libopencv_tracking.4.3"
#   "libopencv_videoio.4.3"
#   "libc++.1"
#   "libSystem.B"
# )

# for dep in "${deps[@]}"; do
#   install_name_tool -change "@loader_path/${dep}-ea9974ed.dylib" "@loader_path/${dep}.dylib" libgdexample.dylib
# done