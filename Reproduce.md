# Reproducing GDNative issue
This file will describe the steps to reproduce the issue that's currently present, more information can be found [here](https://github.com/GodotNativeTools/godot-cpp/issues/403).

We will start a fresh project, so that we can ensure potential existing issues are not carried over. If you have any questions or something is not clear, contact @ksavanderwerff.

## Setting up GDNative
First, follow the example described [here](https://docs.godotengine.org/en/stable/tutorials/plugins/gdnative/gdnative-cpp-example.html).
* It includes the prerequisites you need.
* Go with the Godot and NativeScript 1.1 tabs/examples.

If you're on Windows and you encounter the `module machine type 'x64' conflicts with target machine type 'x86'` error while running `scons platform=windows`, you need to set your environment to `x64`. In this repo you can find a `set64.cmd` that executes the `.bat` file on your pc with the argument `x64` that will do this.
For more information on this error, see the second approach of the accepted answer [here](https://stackoverflow.com/questions/31595869/how-to-resolve-the-module-machine-type-x86-conflicts-with-target-machine-type).

## Setting up OpenCV
Eventually, previous step should be completed and working, do not proceed it it's not working.
For our next step, we'll install OpenCV, follow the instructions found in their [documentation](https://docs.opencv.org/master/df/d65/tutorial_table_of_content_introduction.html), choose the correct introduction depending on your OS.
* [Here](https://medium.com/@subwaymatch/opencv-410-with-vs-2019-3d0bc0c81d96)'s an alternative tutorial. While setting it up is mostly relevant for Windows, it also includes some minimal code to test if it's indeed working correctly, that part is also relevant for other OS.

Note; include the `lib/` version that contains the `.lib` file, do not include `.dll`. The difference is that if you include `.lib`, the library will get inlined with the compiled code, as opposed to including a `.dll`, where it won't inline the library code and you would need to also ship the opencv `.dll`.
Each option has its pros and cons but for now we go with the `.lib` variant for ease.

## Include OpenCV in GDNative
If everything is working correctly so far, the goal is now to include the opencv libraries in the GDNative script so that we have access to those in Godot.
In the previous step you should have some lines that include OpenCV libraries, for instance `#include <opencv2/core/core.hpp>` or `#include <opencv2/core.hpp>`.
Copy _only_ those lines over to `gdexample.cpp`, do not actually use any of the functions included in those libraries. For an example you can check `gdexample.cpp` of this repository.

The next step is to tell `SCons` where it can find those libraries. If previous steps went well, you should have a `OPENCV_DIR` environment variable.
You should see the following lines in `SConstruct`:

```python
# make sure our binding library is properly includes
env.Append(CPPPATH=['.', godot_headers_path, cpp_bindings_path + 'include/', cpp_bindings_path + 'include/core/', cpp_bindings_path + 'include/gen/'])
env.Append(LIBPATH=[cpp_bindings_path + 'bin/'])
env.Append(LIBS=[cpp_library])
```

This is where we need to include the paths to the where SConstruct can find our files:
```py
env.Append(CPPPATH=[
    # cpp bindings
    '.', godot_headers_path, cpp_bindings_path + 'include/', cpp_bindings_path + 'include/core/', cpp_bindings_path + 'include/gen/',
    # opencv library
    os.environ['OPENCV_DIR'] + "/../../include/"
])
env.Append(LIBPATH=[
    # cpp bindings
    cpp_bindings_path + 'bin/',
    # opencv library
    os.environ['OPENCV_DIR'] + "/lib/"
])
env.Append(LIBS=[cpp_library, "opencv_world430d"]) # Have to omit ".lib", it gets appended in runtime
```

Now, you should be able to compile, if it gets compiled it means that if found the library succesfully. You should still be able to use the generated `libgdexample.dll` just fine in Godot.

## The issue (or hopefully, not an issue for you)
This is where we get to the weird stuff. When we can succesfully include these libraries we'd think that we're all good to use them, right? Think again.
In `void GDExample::_init()` in `gdexample.cpp`, add a line that uses a function out of the opencv libraries that you included. For instance, I added `Mat image = Mat::zeros(300, 600, CV_8UC3);`. That's all.
Now, compile again and try to run the project. This is where I run into the error that you can find on Github. I sincerely hope that you do not have this issue but I'm afraid you will, report back on what your results were here.

Feel free to debug and experimentate with what you think might be solutions to this problem. I've tried a lot of minor things but it was honestly a lot of guesswork.
I realise now that I did not try other opencv library functions, but I can't imagine that'd make a difference.

## What I think might be the issue
- Perhaaaaps we should not use OpenCV code in the `_init` portion of this app, but still, I can't imagine setting a `image` there would be an issue, and in any case, moving that line to `_process` did not make a difference.
- I'm not sure if I've missed something with SConstruct, the fact that it compiles makes me think I did not, and I'd imagine that an other kind of error would be thrown if it could not find the used functions regardless.
