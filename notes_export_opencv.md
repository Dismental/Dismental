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