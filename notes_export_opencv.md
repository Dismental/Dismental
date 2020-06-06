OpenCV first looks into
1. /usr/local/Cellar/opencv
2. /usr/local/opt/opencv << this is ignored?

/Users/kevin/Development/contextproject/Godot/bin/osx/libgdexample.dylib LOOKS DIRECTLY TO /usr/local/opt/opencv/lib/libopencv_alphamat.4.3.dylib

/usr/local/opt/opencv/lib/libopencv_alphamat.4.3.dylib LOOKS DIRECTLY TO @rpath/libopencv_imgproc.4.3.dylib

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