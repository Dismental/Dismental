# Including system library stuff

## Including /usr/lib/
This is the most recent `.zip` of our dependencies.
This `.zip` was made before adding a suffix to every lib, it contains the third party dependencies found in `/usr/local/opt/` and `/usr/local/Cellar`.
It also contains the libraries we use from `/usr/lib/`.
For every library the `LC_LOAD_DYLIB` has been adjusted.
All of the libraries in this file request libraries from one of the following locations:
* `@loader_path/` 
* `@rpath/`
* `/System/Library/Frameworks/`


Since MacOS looks in `/usr/lib/` by default we have to set `DYLD_LIBRARY_PATH` to point to our libraries.
Scripts need to be manipulated in `.app/Contents/MacOS/` for this.

`PATH_TO_EXE="$(pwd)/Applications/Dismental.app/Contents/MacOS/"`

Rename `$PATH_TO_EXE/Dismental` -> `$PATH_TO_EXE/DismentalMain`

Add `$PATH_TO_EXE/Dismental` with the following contents:

```
#!/bin/sh
echo "FROM EXECUTABLE"
echo "$(pwd)"
PATH_TO_APP="$(pwd)/Applications/Dismental.app"
echo "${PATH_TO_APP}"
export DYLD_PRINT_LIBRARIES=y
export DYLD_LIBRARY_PATH="${PATH_TO_APP}/Contents/Frameworks/"
"${PATH_TO_APP}/Contents/MacOS/Dismental-main"
```

Have to rename the following libs in `.app/Contents/Frameworks/` because the name collides with libraries present in `/System/Libraries/`

`/System/Library/Frameworks/ImageIO.framework/Versions/A/Resources/libGIF.dylib`
`/System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib`
`/System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libLAPACK.dylib`

```
libblas.dylib -> libblas_temp.dylib
libgif.dylib -> libgif_temp.dylib
liblapack.dylib -> liblapack_temp.dylib
```

So `/System/Library/` stuff won't stop at these libraries and instead keep looking to find their own in the other `/System/Library/` stuff.


---
I think I'm on the wrong path by also trying to include `/usr/lib/` and `/System/Library/Frameworks`.

Resources:

https://stackoverflow.com/questions/23471978/how-can-i-link-my-c-program-statically-with-libstdc-on-osx-using-clang



---

**dependencies.zip && dependencies_2.zip**

Contains the third party dependencies found in `/usr/local/opt/` and `/usr/local/Cellar`.
For every library the `LC_LOAD_DYLIB` has been adjusted.
All of the libraries in this file request libraries from one of the following locations:
* `@loader_path/` 
* `@rpath/`
* `/System/Library/Frameworks/`
* `/usr/lib/`

---

The problems described below, regarding the RPATH and ligdexample.dylib calling `/usr/local/opt/opencv` have been solved! Relevant links:
https://stackoverflow.com/questions/2092378/macosx-how-to-collect-dependencies-into-a-local-bundle
https://medium.com/@donblas/fun-with-rpath-otool-and-install-name-tool-e3e41ae86172

Basically, if you'd run
```
$ otool -l libgdexample.dylib
```
You'd see a lot of
```
Load command 57
          cmd LC_LOAD_DYLIB
      cmdsize 72
         name /usr/local/opt/lib/libopencv_videoio.4.3.dylib (offset 24)
   time stamp 2 Thu Jan  1 01:00:02 1970
      current version 4.3.0
compatibility version 4.3.0
```
So, what you want to do is change that reference, for each opencv dependency that libgdexample.dylib points to. Below is an example to change the `LC_LOAD_DYLIB` for `libopencv_videoio`.
```
install_name_tool -change "/usr/local/opt/opencv/lib/libopencv_videoio.dylib" "@loader_path/lib/libopencv_videoio.dylib" libgdexample.dylib
```

Setting the right path towards each each opencv dependency is time consuming, so there's a script in `Godot/bin/osx/lib` that will do that for all of them.

Now, we have a new problem, the opencv dependency in turn also uses dependencies installed in `/usr/local/opt`!

So I'm now in the process of copying all of those libraries over and setting the right `LC_LOAD_DYLIB` for each path. But this is very time consuming. There are 2 alternative options to consider:
1. Using an installer so that we can install all those dependencies at the end user in `/usr/local/cellar`, and that should also place the symlinks pointing to `/usr/local/opt`.
2. Use some tool that can automaticcaly recover which dependencies are used, copy them over and set the right `LC_LOAD_DYLIB` (which would make the manual process that I'm doing now automatic).

`otool -L <file>.dylib` gives an overview similar to `-l` but is much more condensed.

Tool to bundle dylibs: https://github.com/auriamg/macdylibbundler/
https://stackoverflow.com/questions/17703510/dyld-library-not-loaded-reason-image-not-found
https://github.com/trojanfoe/xcodedevtools
---

# Libgdexample.dylib -> OpenCV dependency

What's interesting is that when libgdexample is loaded, it seems to look into `/usr/local/opt/opencv`.
We can set a symlink here to point to our dependencies, it would work but it's inconvenient because of the following reasons:
1. If an user decides to install opencv in the future, the symlink has already been set to point to our games dependencies.
2. We'd have to check if the symlink already exists, if it does, overwriting it could be problematic for other programs needing opencv.

So the best is to figure out why this is exactly happening in the first place, if we can override where it should look for opencv that'd be great.
Could **not** find it at the following places:
1. SConstruct
2. Output of compiling with -v flag
3. Output of linking with -v flag

Interesting links:
* https://stackoverflow.com/questions/50273061/dyld-library-not-loaded-usr-local-opt-jpeg-lib-libjpeg-9-dylib-opencv-c-mac

> Usually there's a way to override the hardcoded path like /usr/local/opt at build time using some build script variable somewhere in the OpenCV build scripts.

# OpenCV dependency -> Any other OpenCV dependency

Rpath has been set to solve this issue.
However, it seems as if the rpath setting does not carry over when shipping the game to a new machine, need to investigate whether this is actually the case, and if it is, how to solve it.

`libgdexample.dylib` looks at the following locations to find `libopencv_alphamat.4.3.dylib`.
1. `/usr/local/Cellar/opencv`
2. `/usr/local/opt/lib`

```
if env['export'] in ['y', 'yes']:
    rpath = '~/Applications/DefuseTheBomb.app/Contents/Frameworks/lib'
elif env['export'] in ['n', 'no']:
    rpath = '~/Development/contextproject/Godot/bin/osx/lib'

env.Append(CCFLAGS=['-g', '-O2', '-arch', 'x86_64', '-std=c++17'])
env.Append(LINKFLAGS=['-arch', 'x86_64', '-rpath', rpath])
```

# Error

/Users/kevin/Development/contextproject/Godot/bin/osx/libgdexample.dylib ---(looks into)--> /usr/local/opt/opencv/lib/libopencv_alphamat.4.3.dylib
/usr/local/opt/opencv/lib/libopencv_alphamat.4.3.dylib ---(looks into)--> @rpath/libopencv_imgproc.4.3.dylib

```
contextproject/Godot git/77-export-game-to-macos*  
❯ godot
arguments
0: godot
Current path: /Users/kevin/Development/contextproject/Godot
Godot Engine v3.2.1.stable.mono.official - https://godotengine.org
OpenGL ES 3.0 Renderer: Intel Iris Pro OpenGL Engine
 
Registered camera FaceTime HD Camera with id 1 position 0 at index 0
Mono: Logfile is: /Users/kevin/Library/Application Support/Godot/mono/mono_logs/2020_06_06 15.48.34 (9418).txt
ERROR: open_dynamic_library: Can't open dynamic library: /Users/kevin/Development/contextproject/Godot/bin/osx/libgdexample.dylib, error: dlopen(/Users/kevin/Development/contextproject/Godot/bin/osx/libgdexample.dylib, 2): Library not loaded: /usr/local/opt/opencv/lib/libopencv_alphamat.4.3.dylib
  Referenced from: /Users/kevin/Development/contextproject/Godot/bin/osx/libgdexample.dylib
  Reason: image not found.
   At: platform/osx/os_osx.mm:1804.
ERROR: get_symbol: No valid library handle, can't get symbol from GDNative object
   At: modules/gdnative/gdnative.cpp:483.
ERROR: init_library: No nativescript_init in "res://bin/osx/libgdexample.dylib" found
   At: modules/gdnative/nativescript/nativescript.cpp:1506.
start tracking scene
saved
ERROR: get_symbol: No valid library handle, can't get symbol from GDNative object
   At: modules/gdnative/gdnative.cpp:483.
debugger-agent: Unable to listen on 47
ERROR: terminate: No valid library handle, can't terminate GDNative object
   At: modules/gdnative/gdnative.cpp:388.
                                                                                                                                                                                                                                      
contextproject/Godot git/77-export-game-to-macos*  10s
❯ godot
arguments
0: godot
Current path: /Users/kevin/Development/contextproject/Godot
Godot Engine v3.2.1.stable.mono.official - https://godotengine.org
OpenGL ES 3.0 Renderer: Intel Iris Pro OpenGL Engine
 
Registered camera FaceTime HD Camera with id 1 position 0 at index 0
Mono: Logfile is: /Users/kevin/Library/Application Support/Godot/mono/mono_logs/2020_06_06 15.49.17 (9441).txt
ERROR: open_dynamic_library: Can't open dynamic library: /Users/kevin/Development/contextproject/Godot/bin/osx/libgdexample.dylib, error: dlopen(/Users/kevin/Development/contextproject/Godot/bin/osx/libgdexample.dylib, 2): Library not loaded: @rpath/libopencv_imgproc.4.3.dylib
  Referenced from: /usr/local/opt/opencv/lib/libopencv_alphamat.4.3.dylib
  Reason: image not found.
   At: platform/osx/os_osx.mm:1804.
ERROR: get_symbol: No valid library handle, can't get symbol from GDNative object
   At: modules/gdnative/gdnative.cpp:483.
ERROR: init_library: No nativescript_init in "res://bin/osx/libgdexample.dylib" found
   At: modules/gdnative/nativescript/nativescript.cpp:1506.
start tracking scene
```