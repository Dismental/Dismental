import glob
import subprocess
import sys
import os
from os import path

###
# This script will do the following three things
# 1.  For all .dylib files (excluding symlinks), look for any LC_LOAD_DYLIB's that start with the given PREFIX.
# 2.  For those LC_LOAD_DYLIB's that start with the PREFIX, look whether the file that it points to already exists in the current directory that the script is running from.
#     For example, if you have a PREFIX=/usr/local/opt and if you have a LC_LOAD_DYLIB="/usr/local/opt/ffmpeg/processimg.dylib" on a certain .dylib file,
#     this script will check if processimg.dylib exists in the current directory.
#     2.1.  If it does exist, it won't copy the dylib, skip to step 3.
#     2.2.  If it does not exist, it will copy the .dylib over from the location mentioned in LC_LOAD_DYLIB to the current directory.
#           It will also append a line "res://bin/osx/lib/processimg.dylib" to added_libs.txt, the lines added there are meant to be copied to .gdnlib. Once that's done, the .txt file should cleared.
# 3.  After this, it will change the LC_LOAD_DYLIB path to @loader_path/processimg.dylib
###

TO = os.getcwd()
NEW_LOCATION = "@loader_path/"
PREFIX = "/usr/local/Cellar/"

def command_to_list(cmd):
  arr = subprocess.check_output(cmd, shell=True).decode('utf-8').strip().split('\n')
  return list(map(lambda x: x.strip(), arr))

# This command excludes symlinks
dylibs = command_to_list("ls -ld " + sys.argv[1] + "| grep -v ^l | awk '{print $9}'")
added = []

for lib in dylibs:
  print()
  print(lib)
  # Remove first 2 lines, first line is filename, second is reference to itself
  output = command_to_list(f'otool -L {lib}')[2:]
  starts_with_usr_local_opt = list(filter(lambda x: x.startswith(PREFIX), output))
  clean = list(map(lambda x: x.split(' ')[0], starts_with_usr_local_opt))
  new_paths = list(map(lambda x: f"{NEW_LOCATION}{x.split('/')[-1]}", clean))
  paths = list(zip(clean, new_paths))
  for (file, new_location) in paths:
    target_lib_name = new_location.split('/')[-1]
    copy_cmd = f"sudo cp -n {file} {TO}" # -n means no overwrite
    change_LC_LOAD_DYLIB_cmd = f"sudo install_name_tool -change {file} {new_location} {lib}"
    lib_exists = path.exists(f"{TO}{target_lib_name}")
    print('--')
    print("Lib already exists in our /lib: " + str(lib_exists))
    if not lib_exists:
      print(copy_cmd)
    print(change_LC_LOAD_DYLIB_cmd)

    if (len(sys.argv) > 2 and sys.argv[2] == '-e'):
      # Add path that needs to be added ot .gdnlib
      if not lib_exists:
        added.append(f"res://bin/osx/{target_lib_name}")
        subprocess.run(copy_cmd, shell=True)
      subprocess.run(change_LC_LOAD_DYLIB_cmd, shell=True)


# Write added files to .txt
# so that we can add them to dylib afterwards
f = open("added_libs.txt", "a")
for add in added:
  f.write(f'{add}\n')
f.close()
