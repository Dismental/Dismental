import glob, subprocess, sys, os, argparse
from os import path
from utils import command_to_list, cleanOtool, startsWithAny, getFile

parser = argparse.ArgumentParser()
parser.add_argument('-glob', help='the files that this script should look into (defaults to checking all .dylib files)', type=str, default="*.dylib")
parser.add_argument('-prefix', nargs='+', help='the prefix(es) this script should look for', type=str)
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

# Look up all the files that match the glob, symlinks excluded
dylibs = command_to_list("ls -ld " + args.glob + "| grep -v ^l | awk '{print $9}'")

files = []
for lib in dylibs:
  output = cleanOtool(command_to_list(f'otool -L {lib}'))
  filtered = list(filter(lambda x: not startsWithAny(x, args.prefix) if args.n else startsWithAny(x, args.prefix), output))
  
  print()
  print(lib)
  print("---")
  for path in filtered:
    print(path)
    # file = getFile(path)
    if path not in files:
      files.append(path)
  
print()
print("These files are required")
print("---")
for file in files:
  print(file)
