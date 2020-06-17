symlinks=(
  "libopencv_imgcodecs.4.3.dylib"
  "libopencv_imgproc.4.3.dylib"
  "libopencv_core.4.3.dylib"
  "libopencv_calib3d.4.3.dylib"
  "libopencv_features2d.4.3.dylib"
  "libopencv_flann.4.3.dylib"
  "libopencv_plot.4.3.dylib"
  "libopencv_datasets.4.3.dylib"
  "libopencv_video.4.3.dylib"
  "libopencv_text.4.3.dylib"
  "libopencv_ml.4.3.dylib"
  "libopencv_dnn.4.3.dylib"
)

for i in "${symlinks[@]}"; do
  cp "/usr/local/opt/opencv/lib/$i" "."
  # install_name_tool -change "/usr/local/opt/opencv/lib/$i.dylib" "@loader_path/$i.dylib" libgdexample.dylib
done

# install_name_tool -add_rpath @loader_path/ libgdexample.dylib