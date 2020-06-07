symlinks=("libopencv_core.4.3" "libopencv_highgui.4.3" "libopencv_imgproc.4.3" "libopencv_objdetect.4.3" "libopencv_tracking.4.3" "libopencv_videoio.4.3")
for i in "${symlinks[@]}"; do
  install_name_tool -change "/usr/local/opt/opencv/lib/$i.dylib" "@loader_path/$i.dylib" libgdexample.dylib
done

install_name_tool -add_rpath @loader_path/ libgdexample.dylib