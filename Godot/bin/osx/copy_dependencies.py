import glob, subprocess, sys, os, argparse
from os import path
from utils import command_to_list, cleanOtool, getFile

"""
This script will execute the following steps:
1.  For all .dylib files (excluding symlinks), look for any LC_LOAD_DYLIB's that start with the given PREFIX.
2.  For those LC_LOAD_DYLIB's that start with the PREFIX, look whether the file that it points to already exists in the current directory that the script is running from.
    For example, if you have a PREFIX=/usr/local/opt and if you have a LC_LOAD_DYLIB="/usr/local/opt/ffmpeg/processimg.dylib" on a certain .dylib file,
    this script will check if processimg.dylib exists in the current directory.
    2.1.  If it does exist, it won't copy the dylib, skip to step 3.
    2.2.  If it does not exist, it will copy the .dylib over from the location mentioned in LC_LOAD_DYLIB to the current directory.
3.  After this, it will change the LC_LOAD_DYLIB path to @loader_path/processimg.dylib.

Run `python copy_dependencies.py -h` for information on the arguments you can pass.

Examples:
```
# To check what commands this script will execute, on all libs that have a path that starts with the prefix
python copy_dependencies.py -prefix "/usr/local/opt/" -glob "*.dylib"
```

```
# Will run the same as above, but will actually execute the commands
python copy_dependencies.py -prefix "/usr/local/opt/" -glob "*.dylib" -e
```
"""

parser = argparse.ArgumentParser()
parser.add_argument('-glob', help='the files that this script should look into', type=str, default="*.dylib")
parser.add_argument('-prefix', help='the prefix this script should look for', type=str)
parser.add_argument('-e', help='to execute the commands generated by this script, leave this flag out to check beforehand what the script will execute', action='store_true')
args=parser.parse_args()

TO = os.getcwd()
NEW_LOCATION = "@loader_path/"
# Look up all the files that match the glob, symlinks excluded
dylibs = command_to_list("ls -ld " + args.glob + "| grep -v ^l | awk '{print $9}'")

omitted = []
for lib in dylibs:
  output = cleanOtool(command_to_list(f'otool -L {lib}'))
  starts_with_prefix = list(filter(lambda x: x.startswith(args.prefix), output))
  # Construct an array of the new desired paths that LC_LOAD_DYLIB should point to
  new_paths = list(map(lambda x: f"{NEW_LOCATION}{getFile(x)}", starts_with_prefix))
  # Pair each old path with the new one, to iterate over as seen later
  paths = list(zip(starts_with_prefix, new_paths))
  
  # If paths is empty, it means the script won't do anything to this lib.
  # Add it to the omitted array so we can enlist at the end of the session
  # what files have been checked, but no commands were executed for.
  if (not paths):
    omitted.append(lib)

  # If it does contain paths, print out the current lib before printing the commands
  if paths:
    print()
    print(lib)
  
  # For each combination, construct the commands and print them.
  # If the e flag is turned on, the commands will be executed.
  for (file, new_location) in paths:
    target_lib_name = getFile(new_location)
    copy_cmd = f"sudo cp -n {file} {TO}" # -n means no overwrite
    change_LC_LOAD_DYLIB_cmd = f"sudo install_name_tool -change {file} {new_location} {lib}"
    lib_exists = path.exists(f"{TO}/{target_lib_name}")
    print('--')
    print("Targeted lib already exists in our /lib: " + str(lib_exists))
    if not lib_exists:
      print(copy_cmd)
    print(change_LC_LOAD_DYLIB_cmd)

    if (args.e):
      if not lib_exists:
        subprocess.run(copy_cmd, shell=True)
      subprocess.run(change_LC_LOAD_DYLIB_cmd, shell=True)

if omitted:
  print()
  print("Scanned the following files as well, but did not find the given prefix in any of the paths refered to by the file.")
  print(omitted)