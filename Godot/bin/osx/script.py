import glob
import subprocess
import sys

NEW_LOCATION = "@loader_path/"
FILE = sys.argv[1]

# This sript will change all LC_LOAD_DYLIB's that match with /usr/local/opt/*/<libname>.dylib
# into {NEW_LOCATION}/<libname>.dylib

def command_to_list(cmd):
  arr = subprocess.check_output(cmd, shell=True).decode('utf-8').strip().split('\n')
  return list(map(lambda x: x.strip(), arr))

# Remove first 2 lines, first line is filename, second is reference to itself
output_otool = command_to_list(f"otool -L {FILE}")[2:]
clean = list(map(lambda x: x.split(' ')[0], output_otool))
opt_paths = list(filter(lambda x: x.startswith("/usr/local/opt"), clean))
new_paths = list(map(lambda x: f"{NEW_LOCATION}{x.split('/')[-1]}", opt_paths))
paths = list(zip(opt_paths, new_paths))
for (old, new) in paths:
  command = f"sudo install_name_tool -change {old} {new} {FILE}"
  print("--")
  print(command)
  if (sys.argv[2] == '-e'):
    subprocess.run(command, shell=True)
