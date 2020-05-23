## Context Project CG-1

### Name:  Defuse the bomb

##### Game Engine: Godot
##### Object recognition: OpenCV

Developer Team:
- Kevin van der Werff, Producer & Communication 
- Onno Gieling, Lead Playtesting
- Jonas Duifs, Interaction Designer 
- Pepijn Klop, Lead Designer
- Gees Brouwers, Lead Artist & SFX Designer 
- Jeroen Janssen, Lead Programmer 

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

**To lint all files ending with `.gd` found in `Script/`, recursively**
```
$ python linter.py
```

**To lint a specific file**
```
$ python linter.py [path-to-file]
```
Example:
```
$ python linter.py Script/SceneManagers/CreateGameRoomManager.gd 
```

**To lint a single directory, non-recursively**
```
$ python linter.py [path-to-dir]
```
Example:
```
$ python linter.py Script/SceneManagers/
```