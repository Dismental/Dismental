symlinks=("libopencv_alphamat.4.3" "libopencv_aruco.4.3" "libopencv_bgsegm.4.3" "libopencv_bioinspired.4.3" "libopencv_calib3d.4.3" "libopencv_ccalib.4.3" "libopencv_core.4.3" "libopencv_datasets.4.3" "libopencv_dnn_objdetect.4.3" "libopencv_dnn_superres.4.3" "libopencv_dnn.4.3" "libopencv_dpm.4.3" "libopencv_face.4.3" "libopencv_features2d.4.3" "libopencv_flann.4.3" "libopencv_freetype.4.3" "libopencv_fuzzy.4.3" "libopencv_gapi.4.3" "libopencv_hfs.4.3" "libopencv_highgui.4.3" "libopencv_img_hash.4.3" "libopencv_imgcodecs.4.3" "libopencv_imgproc.4.3" "libopencv_intensity_transform.4.3" "libopencv_line_descriptor.4.3" "libopencv_ml.4.3" "libopencv_objdetect.4.3" "libopencv_optflow.4.3" "libopencv_phase_unwrapping.4.3" "libopencv_photo.4.3" "libopencv_plot.4.3" "libopencv_quality.4.3" "libopencv_rapid.4.3" "libopencv_reg.4.3" "libopencv_rgbd.4.3" "libopencv_saliency.4.3" "libopencv_sfm.4.3" "libopencv_shape.4.3" "libopencv_stereo.4.3" "libopencv_stitching.4.3" "libopencv_structured_light.4.3" "libopencv_superres.4.3" "libopencv_surface_matching.4.3" "libopencv_text.4.3" "libopencv_tracking.4.3" "libopencv_video.4.3" "libopencv_videoio.4.3" "libopencv_videostab.4.3" "libopencv_xfeatures2d.4.3" "libopencv_ximgproc.4.3" "libopencv_xobjdetect.4.3" "libopencv_xphoto.4.3")
for i in "${symlinks[@]}"; do
  install_name_tool -change "/usr/local/opt/opencv/lib/$i.dylib" "@loader_path/lib/$i.dylib" libgdexample.dylib
done

install_name_tool -add_rpath @loader_path/lib/ libgdexample.dylib

cd lib/

dependencies=($(ls -d libopencv_*.4.3.0.dylib))
for i in "${dependencies[@]}"; do
  echo "$i"
  sudo install_name_tool -change "/usr/local/opt/openblas/lib/libopenblas.0.dylib" "@loader_path/libopenblas.0.dylib" $i
done

# openblas_deps=("libblas.dylib" "liblapack.dylib" "libopenblas.0.dylib" "libopenblas.dylib" "libopenblasp-r0.3.9.dylib")
# for i in "${dependencies[@]}"; do

# Change reference of opencv lib to ceres lib
install_name_tool -change "/usr/local/opt/ceres-solver/lib/libceres.1.dylib" "@loader_path/libceres.1.dylib" libopencv_sfm.4.3.0.dylib

# ceres lib -> openblas
install_name_tool -change "/usr/local/opt/openblas/lib/libopenblas.0.dylib" "@loader_path/libopenblas.0.dylib" libceres.1.14.0.dylib
