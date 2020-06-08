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

ls -d *.dylib | {                     
while read i; do echo $i; done    
}


otool -L libopencv_dnn.4.3.0.dylib | grep ^/usr/loca/opt {
  while read i; do echo "Ayay   $i"; done
}



# Find references to /usr/local/opt
otool -L libopencv_dnn.4.3.0.dylib |
tail -n +3 |
grep "/usr/local/opt/" |
cut -d' ' -f1 | {
  while read i; do echo "install_name_tool -change $i"; done
}