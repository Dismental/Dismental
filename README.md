# Defuse the bomb
* Game engine: Godot
* Object recognition: OpenCV

# Table of contents
[[_TOC_]]

# Getting up and running
This section will cover cloning this repository, as well as the submodules, and how to get up and running with the project.

## Prerequisites
* Godot 3.2.1
* SCons 3.1.2
* OpenCV 4.3.0
* Windows: Visual Studio

### Godot
You need to have Godot installed, do so [here](https://godotengine.org/download/).
Verify that you can use this through the cli:
```
$ godot --version
3.2.1.stable.mono.official
```
If you do not see above output, there are several things you can do depending on your OS.

#### Windows
Either you fix this by adding the path to your Godot `.exe` to the PATH environment variable correctly so that you can use `godot` anywhere.
Or you take the easy route, which is directly calling it as follows:
```
$ "<path-to-godot-dir>/<godot-exe-name>.exe" --version
```
So for example:
```
$ "D:\Program Files (x86)\Godot\Godot_v3.2.1-stable_mono_win64.exe" --version
3.2.1.stable.mono.official
```
Which is fine to do for now, as we will only need to use this `.exe` through the cli once for the current setup.

#### MacOS
When you install Godot, you can acess the binary file that you can run in the cli with the following path:
```
/Applications/<Godot>.app/Contents/MacOS/Godot
```
The name of the `.app` depends on whether you installed the Mono or the non Mono version.

Just like for Windows, there's an easy route you can take by directly calling the path as follows
```
$ /Applications/<Godot>.app/Contents/MacOS/Godot --version
```
So for example (I have the Mono version):
```
$ /Applications/Godot_mono.app/Contents/MacOS/Godot --version
0: /Applications/Godot_mono.app/Contents/MacOS/Godot
1: --version
Current path: /Users/kevin/Development/contextproject
3.2.1.stable.mono.official
```

Or you make it so that you can use the `godot` command by adding the following:
```
$ ln -s /Applications/<Godot>.app/Contents/MacOS/Godot /usr/local/bin/godot
```
For more information on this, see [here](https://godotengine.org/qa/22104/how-to-run-a-project-in-godot-from-command-on-mac).

### Scons
Go to their [site](https://scons.org/pages/download.html) and download the 3.1.2 version of the "SCons Packages" (so not "scons-local Packages" or "scons-src Packages").
Extract the package and follow the instructions in the `README.md`.

Verify that it's working with the following command
```
$ scons --version
SCons by Steven Knight et al.:
        script: v3.1.2.bee7caf9defd6e108fc2998a2520ddb36a967691, 2019-12-17 02:07:09, by bdeegan on octodog
        engine: v3.1.2.bee7caf9defd6e108fc2998a2520ddb36a967691, 2019-12-17 02:07:09, by bdeegan on octodog
        engine path: ['C:\\Users\\kevin\\Development\\scons-3.1.2\\script\\..\\engine\\SCons']
Copyright (c) 2001 - 2019 The SCons Foundation
```

Do not proceed until this works.

### OpenCV
#### MacOS
Installing OpenCV 4 for MacOS requires Xcode and homebrew.

1. **Install Xcode**  

Install Xcode from the App Store. Open the App Store and search for Xcode and then click the Get button

2. **Install Homebrew**  

Open the terminal and execute the following code:  
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

3. **Install OpenCV**   

Open the terminal and execute the following code:  
```
brew install opencv
```

4. **Set the OPENCV_DIR environment variable**

In `/SConstruct` the environment variable named `OPENCV_DIR` will be looked up to find where OpenCV is located.

If you have installed it through homebrew, most likely you can find the OpenCV dependency under the location `/usr/local/opt/opencv@4`. Double check to be sure, you can `cd` to it for example.

If your path to OpenCV is different, make sure that whatever directory your path points to, it includes the following directories:
1. `<path_to_OpenCV>/bin/`
2. `<path_to_OpenCV>/include/opencv4/`

When you've confirmed the location of your dependency, it needs to be added to your environment variables. This is done in either `~/.bash_profile` or `~/.zshrc`, choose the one that's most appropriate for you. I'm going with `.zshrc` for the example. Replace that with `.bash_profie` if necessary.

To add the environment variable you can either run the following command:
```
$ echo "export OPENCV_DIR=\"/usr/local/opt/opencv@4\"" >> ~/.zshrc
```

Or open the file in an editor of choice, and add the following line:
```
export OPENCV_DIR="/usr/local/opt/opencv@4"
```

After you've added this your current environment still needs to "read" these values in, which can be done in the 2 following ways:
1. Run `$ source ~/.zshrc`.
2. The good ol' way: close and re-open terminal.

You can check if the environment is set correctly by running `$ env` which gives you a list, in that list you should see
```
OPENCV_DIR=/usr/local/opt/opencv@4
```

If these the steps were not sufficient, additional installation steps can be found [here](https://medium.com/@jaskaranvirdi/setting-up-opencv-and-c-development-environment-in-xcode-b6027728003).

### Visual Studio
On Windows, you will need to install Visual Studio so that you have access to `cl.exe`, which you need when building C++.
Check out this [part](https://docs.godotengine.org/en/stable/development/compiling/compiling_for_windows.html#installing-visual-studio-caveats) of Godots documentation on VS.

## Cloning
If you've already cloned the project before, skip this step.

Since this branch includes a submodule, you need to clone recursively so that submodules get cloned as well:
```
$ git clone --recursive git@gitlab.ewi.tudelft.nl:TI2806/2019-2020/cg-01/main-repository.git
```

## Submodules
If you've already cloned the project, but have yet to get the submodules:
```
$ git submodule update --init --recursive
```

## Building bindings
We need to generate the Godot C++ bindings so that we can make use of these when compiling our C++ scripts.
That's why the submodule `godot-cpp` is included, they contain the source files to generate the bindings.

Before that we do need to generate an `api.json` (why you ask? Beats me).

Once you're in the root of the project in your terminal, call the following:
```
$ <godot> --gdnative-generate-json-api api.json
```
With `<godot>` being either the command `godot`, or a path directly to the executable file as described in the prerequisites.
The resulting `api.json` file should be placed in the root directory of the project.

Now we'll actually generate the bindings.

To speed up compilation, add `-j<N>` to the `scons` command, where `<N>` is the number of CPU threads you have on your system. The example below uses 4 threads.

Replace `<platform>` with `windows`, `osx` or `linux` depending on your OS.

Note: Add `bits=64` to the `scons` command if you're building for Windows.
```
$ cd godot-cpp
$ scons platform=<platform> generate_bindings=yes use_custom_api_file=yes custom_api_file=../api.json -j4
```
This step might take a little bit, when this has succeeded, you should have libraries stored in `godot-cpp/bin/`

Previous steps should be a "do once and forget" situation. The step that follows is what you need to do each time you make changes to the plugin so that you can import the output of that into Godot.

## Building the GDNative plugin
This section operates under the assumption that you have set your `OPENCV_DIR` correctly so that `scons` can find the OpenCV libraries on your computer. See the `SConstruct` file for the paths.
Go back to the root of the project in your terminal.
Now run the following, where `<platform>` is `windows`, `osx` or `linux`.
```
scons platform=<platform>
```
This should build some libraries into `Godot/bin/<platform>/`.
These libraries are the result of building the GDNative plugin and you should be able to succefully use them in Godot now.
The current Godot project already ataches the built script to a node, so you can simply start the Godot project to test out if it's working.
If it's not working, you'll get errors. If you have no errors, it's working. :sunglasses:

## More information
* [Godot's tutorial on GDNative C++](https://docs.godotengine.org/en/stable/tutorials/plugins/gdnative/gdnative-cpp-example.html).

# Linting
Weirdly enough Godot does not have official support for a linter.
So we have to rely on third party tools instead, after considering a few options we went with this one: https://pypi.org/project/gdtoolkit/.
It's not perfect by any means, it doesn't include all rules denoted [here](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_styleguide.html).
For example, it's missing the trailing comma & 2 blank lines rules, among others.
But in any case this seems like a good starting point.

## Usage
Install above tool with `pip`
```
pip install gdtoolkit
```

The tool is a cli script that takes one file in at a time, since it's unconvenient to run such a command over and over again for each file there's an additional python script written that you should use instead. This script is named `linter.py` and can be found here: `/Godot/linter.py`.

All below commands should be exectued with `/Godot/` at the root of your cli environment. So `cd Godot/` if you're in the root of the project before executing any commands below.

**To lint all files**
* The linter will look for files ending with `.gd` in the following locations:
  * In `/Godot/`, non-recursively
  * In `/Godot/Script/`, recursively
* Files included in `.gdlintignore` will be ignored.

```
$ python linter.py
```

**To lint a list of specific locations**

When giving a list of locations, you can mix directories and files.
* Directories will be looked through non-recursively, files in `.gdlintignore` will be ignored.
* Files specified here will be looked at in any case, even if they are in `gdlintignore`.

```
$ python linter.py [path-to-location] [path-to-location2] ...
```
Examples:
```
$ python linter.py Script/SceneManagers/ Script/Scoreboard.gd
```

```
$ python linter.py Network.gd
```

```
$ python linter.py Script/SceneManagers/
```

## Ignore
There's a `/Godot/.gdlintignore` file where you can include files that should be ignored by the linter when directories looked through.

# Scripts
There are some scripts included to automate certain workflows.

Run these scripts using `sh ./<script-name>.sh` when at the root of the repository.

**gdnative_compile_run**

This will compile the gdnative source files & directly run the main scene, easy for quick debugging when developing.
# Exporting to MacOS

## Set up export template
The export preset has been included in the repo, but you need to install the export template as well before being able to export.

Open Project > Export..., select the preset "MacOSX (Runnable)". You should see an error on the bottom saying there's no export template found.

Click on the link next to "Export templates for this platform are missing:", a popup will be shown that asks you to download a template, do this.

When that's downloaded, change the extension of the file from `.tpz` to `.zip` and extract it.

The extracted directory contains the file that the export preset was looking for as shown in the error, move the file to the path indicated by the error.

## Exporting the game
The game can now be exported to a .dmg. Accessing the resources (res://) was not yet successful, thus a reference to a .xml file for face tracking is hardcoded for now. This also requires additional steps to get the .xml file at the right location.

Before being able to export the game, you need to unzip the shipped dependencies found in `<root-repo>/Godot/bin/osx/deps_{version}`,
simply extract them, and they should end up in a folder with the same name (such as `deps_10.14`).

A script has been written to automate this process, which is `/export.sh`. It will perform the steps described below.
To run the script go to the root of the repo in your terminal and run `sh ./export.sh` (prepend `sudo` if needed).
You need to add the version for which you want to export the game, choose from `10.14` or `10.15`.

Example usage: `sudo sh export.sh 10.15`.

**double-the-trouble**

We often need to test multiplayer locally, this script will open two instances of the main scene at once. Along with a terminal window for each instance.

# Developer Team
- Kevin van der Werff, Producer & Communication
- Onno Gieling, Lead Playtesting
- Jonas Duifs, Interaction Designer
- Pepijn Klop, Lead Designer
- Gees Brouwers, Lead Artist & SFX Designer
- Jeroen Janssen, Lead Programmer
