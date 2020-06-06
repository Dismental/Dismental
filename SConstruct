#!python
import os, subprocess
from pathlib import Path

# Create `/bin` directory if it does not exist
Path("./Godot/test").mkdir(exist_ok=True)

opts = Variables([], ARGUMENTS)

# Gets the standard flags CC, CCX, etc.
env = DefaultEnvironment()

# Define our options
opts.Add(EnumVariable('target', "Compilation target", 'debug', ['d', 'debug', 'r', 'release']))
opts.Add(EnumVariable('platform', "Compilation platform", '', ['', 'windows', 'x11', 'linux', 'osx']))
opts.Add(EnumVariable('p', "Compilation target, alias for 'platform'", '', ['', 'windows', 'x11', 'linux', 'osx']))
opts.Add(EnumVariable('export', "Whether this is meant to be shipped or not'", '', ['', 'y', 'yes', 'n', 'no']))
opts.Add(BoolVariable('use_llvm', "Use the LLVM / Clang compiler", 'no'))
opts.Add(PathVariable('target_path', 'The path where the lib is installed.', 'Godot/bin/'))
opts.Add(PathVariable('target_name', 'The library name.', 'libgdexample', PathVariable.PathAccept))

# Local dependency paths, adapt them to your setup
godot_headers_path = "godot-cpp/godot_headers/"
cpp_bindings_path = "godot-cpp/"
cpp_library = "libgodot-cpp"

# only support 64 at this time..
bits = 64

# Updates the environment with the option variables.
opts.Update(env)

# Process some arguments
if env['use_llvm']:
    env['CC'] = 'clang'
    env['CXX'] = 'clang++'

if env['p'] != '':
    env['platform'] = env['p']

if env['platform'] == '':
    print("No valid target platform selected.")
    quit();

# For the reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

if env['export'] in ['y', 'yes']:
    rpath = '~/Applications/DefuseTheBomb.app/Contents/Frameworks/lib'
elif env['export'] in ['n', 'no']:
    rpath = '~/Development/contextproject/Godot/bin/osx/lib'

# Check our platform specifics
if env['platform'] == "osx":
    env['target_path'] += 'osx/'
    cpp_library += '.osx'
    if env['target'] in ('debug', 'd'):
        env.Append(CCFLAGS=['-g', '-O2', '-arch', 'x86_64', '-std=c++17'])
        env.Append(LINKFLAGS=['-arch', 'x86_64', '-rpath', rpath])
    else:
        env.Append(CCFLAGS=['-g', '-O3', '-arch', 'x86_64', '-std=c++17'])
        env.Append(LINKFLAGS=['-arch', 'x86_64'])

elif env['platform'] in ('x11', 'linux'):
    env['target_path'] += 'x11/'
    cpp_library += '.linux'
    if env['target'] in ('debug', 'd'):
        env.Append(CCFLAGS=['-fPIC', '-g3', '-Og', '-std=c++17'])
        env.Append(CXXFLAGS=['-std=c++17'])
    else:
        env.Append(CCFLAGS=['-fPIC', '-g', '-O3', '-std=c++17'])
        env.Append(CXXFLAGS=['-std=c++17'])

elif env['platform'] == "windows":
    env['target_path'] += 'win64/'
    cpp_library += '.windows'
    # This makes sure to keep the session environment variables on windows,
    # that way you can run scons in a vs 2017 prompt and it will find all the required tools
    env.Append(ENV=os.environ)

    env.Append(CPPDEFINES=['WIN32', '_WIN32', '_WINDOWS', '_CRT_SECURE_NO_WARNINGS'])
    env.Append(CCFLAGS=['-W3', '-GR'])
    if env['target'] in ('debug', 'd'):
        env.Append(CPPDEFINES=['_DEBUG'])
        env.Append(CCFLAGS=['-EHsc', '-MDd', '-ZI'])
        env.Append(LINKFLAGS=['-DEBUG'])
    else:
        env.Append(CPPDEFINES=['NDEBUG'])
        env.Append(CCFLAGS=['-O2', '-EHsc', '-MD'])

if env['target'] in ('debug', 'd'):
    cpp_library += '.debug'
else:
    cpp_library += '.release'

cpp_library += '.' + str(bits)

# make sure our binding library is properly included
env.Append(CPPPATH=['.', godot_headers_path, cpp_bindings_path + 'include/', cpp_bindings_path + 'include/core/', cpp_bindings_path + 'include/gen/'])
env.Append(LIBPATH=[cpp_bindings_path + 'bin/'])
env.Append(LIBS=[cpp_library])

# Add OpenCV configuration
# At LIBS, omit file extensions such as '.lib' and '.dylib', they get appended in runtime depending on the OS
# Configuration for linux has not been tested, but for now I assume it's similar to OSX
# print("RPATH TO BE ADDED YOOOO")
# env.Append(RPATH=[env.Literal(os.path.join('\\$$ORIGIN', os.pardir, 'lib'))])
# env.Append(RPATH=["~/Development/contextproject/src/lib"])

# For OSX these files have been filled in under assumption that you installed opencv using homebrew
if env['platform'] == "osx" or env['platform'] in ('x11', 'linux'):
    env.Append(CPPPATH=[os.environ['OPENCV_DIR'] + "/include/opencv4/"])
    env.Append(LIBPATH=["./src/lib/"])
    env.Append(LIBS=[
        "libopencv_alphamat.4.3.0",
        "libopencv_aruco.4.3.0",
        "libopencv_bgsegm.4.3.0",
        "libopencv_bioinspired.4.3.0",
        "libopencv_calib3d.4.3.0",
        "libopencv_ccalib.4.3.0",
        "libopencv_core.4.3.0",
        "libopencv_datasets.4.3.0",
        "libopencv_dnn_objdetect.4.3.0",
        "libopencv_dnn_superres.4.3.0",
        "libopencv_dnn.4.3.0",
        "libopencv_dpm.4.3.0",
        "libopencv_face.4.3.0",
        "libopencv_features2d.4.3.0",
        "libopencv_flann.4.3.0",
        "libopencv_freetype.4.3.0",
        "libopencv_fuzzy.4.3.0",
        "libopencv_gapi.4.3.0",
        "libopencv_hfs.4.3.0",
        "libopencv_highgui.4.3.0",
        "libopencv_img_hash.4.3.0",
        "libopencv_imgcodecs.4.3.0",
        "libopencv_imgproc.4.3.0",
        "libopencv_intensity_transform.4.3.0",
        "libopencv_line_descriptor.4.3.0",
        "libopencv_ml.4.3.0",
        "libopencv_objdetect.4.3.0",
        "libopencv_optflow.4.3.0",
        "libopencv_phase_unwrapping.4.3.0",
        "libopencv_photo.4.3.0",
        "libopencv_plot.4.3.0",
        "libopencv_quality.4.3.0",
        "libopencv_rapid.4.3.0",
        "libopencv_reg.4.3.0",
        "libopencv_rgbd.4.3.0",
        "libopencv_saliency.4.3.0",
        "libopencv_sfm.4.3.0",
        "libopencv_shape.4.3.0",
        "libopencv_stereo.4.3.0",
        "libopencv_stitching.4.3.0",
        "libopencv_structured_light.4.3.0",
        "libopencv_superres.4.3.0",
        "libopencv_surface_matching.4.3.0",
        "libopencv_text.4.3.0",
        "libopencv_tracking.4.3.0",
        "libopencv_video.4.3.0",
        "libopencv_videoio.4.3.0",
        "libopencv_videostab.4.3.0",
        "libopencv_xfeatures2d.4.3.0",
        "libopencv_ximgproc.4.3.0",
        "libopencv_xobjdetect.4.3.0",
        "libopencv_xphoto.4.3.0",
    ])
# For windows, these files have been filled under assumption that you downloaded the .zip release of 4.3.0 from sourceforge
elif env['platform'] == "windows":
    env.Append(CPPPATH=[os.environ['OPENCV_DIR'] + "/include/"])
    env.Append(LIBPATH=[os.environ['OPENCV_DIR'] + "/lib/"])
    env.Append(LIBS=[
        "opencv_calib3d430d",
        "opencv_core430d",
        "opencv_dnn430d",
        "opencv_features2d430d",
        "opencv_flann430d",
        "opencv_gapi430d",
        "opencv_highgui430d",
        "opencv_imgcodecs430d",
        "opencv_imgproc430d",
        "opencv_ml430d",
        "opencv_objdetect430d",
        "opencv_photo430d",
        "opencv_stitching430d",
        "opencv_video430d",
        "opencv_videoio430d",
    ])

# tweak this if you want to use different folders, or more folders, to store your source code in.
env.Append(CPPPATH=['src/'])
sources = Glob('src/*.cpp')

library = env.SharedLibrary(target=env['target_path'] + env['target_name'] , source=sources)

Default(library)

# Generates help for the -h scons option.
Help(opts.GenerateHelpText(env))
