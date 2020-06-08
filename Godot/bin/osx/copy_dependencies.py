import glob
import subprocess
import sys

# @TODO Change this path to something relative
TO = "/Users/kevin/Development/contextproject/Godot/bin/osx/"
NEW_LOCATION = "@loader_path/"
dylibs = glob.glob(sys.argv[1])

def command_to_list(cmd):
  arr = subprocess.check_output(cmd, shell=True).decode('utf-8').strip().split('\n')
  return list(map(lambda x: x.strip(), arr))

added = []

for lib in dylibs:
  print()
  print(lib)
  # Remove first 2 lines, first line is filename, second is reference to itself
  output = command_to_list(f'otool -L {lib}')[2:]
  starts_with_usr_local_opt = list(filter(lambda x: x.startswith('/usr/local/opt/'), output))
  clean = list(map(lambda x: x.split(' ')[0], starts_with_usr_local_opt))
  new_paths = list(map(lambda x: f"{NEW_LOCATION}{x.split('/')[-1]}", clean))
  paths = list(zip(clean, new_paths))
  for (file, new_location) in paths:
    target_lib_name = new_location.split('/')[-1]
    copy_cmd = f"sudo cp {file} {TO}"
    change_LC_LOAD_DYLIB_cmd = f"sudo install_name_tool -change {file} {new_location} {lib}"
    print(copy_cmd)
    print(change_LC_LOAD_DYLIB_cmd)

    if (len(sys.argv) > 2 and sys.argv[2] == '-e'):
      # Add path that needs to be added ot .gdnlib
      added.append(f"res://bin/osx/{target_lib_name}")
      subprocess.run(copy_cmd, shell=True)
      subprocess.run(change_LC_LOAD_DYLIB_cmd, shell=True)


# Write added files to .txt
# so that we can add them to dylib afterwards
f = open("added_libs.txt", "a")
for add in added:
  f.write(f'{add}\n')
f.close()
