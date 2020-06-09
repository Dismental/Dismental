import glob, subprocess, sys, os, argparse
from os import path

parser = argparse.ArgumentParser()
parser.add_argument('-glob', help='the files that this script should look into',type=str)
parser.add_argument('-prefix', nargs='+', help='the prefix this script should look for', type=str)
parser.add_argument('-n', help='if the prefix should or should not match, if this flag is turned on, it will not match', action='store_true')
args=parser.parse_args()

"""
This script will check the LC_LOAD_DYLIB of the given glob.
You can match it with a certain prefix. Or match it with the inverse of the prefix.
(So basically, you can say a LC_LOAD_DYLIB has to start with `/usr/local/opt`, or say that it should not start with `/usr/local/opt` for example).

Example:
```
python check_paths.py -prefix "@loader_path/" "/usr/lib" "/System/Library" "@rpath/" -glob "*.dylib" -n 
```
"""

def command_to_list(cmd):
  arr = subprocess.check_output(cmd, shell=True).decode('utf-8').strip().split('\n')
  return list(map(lambda x: x.strip(), arr))

def cleanOtool(output_otool):
  # Remove first 2 lines, first line is filename, second is reference to itself
  removed_headers = output_otool[2:]
  # Remove additional info such as compatibility - & current version
  return list(map(lambda x: x.split(' ')[0], removed_headers))

def startsWithAny(str):
  for prefix in args.prefix:
    if str.startswith(prefix):
      return True
  return False

def getFile(path):
  return path.split('/')[-1]

# Look up all the files that match the glob, symlinks excluded
dylibs = command_to_list("ls -ld " + args.glob + "| grep -v ^l | awk '{print $9}'")

files = []
for lib in dylibs:
  output = cleanOtool(command_to_list(f'otool -L {lib}'))
  filtered = list(filter(lambda x: not startsWithAny(x) if args.n else startsWithAny(x), output))
  
  print()
  print(lib)
  print("---")
  for path in filtered:
    print(path)
    # file = getFile(path)
    if path not in files:
      files.append(path)
  
print("These files are required")
print(files)
  