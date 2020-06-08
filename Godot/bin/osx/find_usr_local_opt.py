import glob
import subprocess
import sys

# @TODO Change this path to something relative
dylibs = glob.glob(sys.argv[1])
# dylibs = glob.glob('*.dylib')

def command_to_list(cmd):
  arr = subprocess.check_output(cmd, shell=True).decode('utf-8').strip().split('\n')
  return list(map(lambda x: x.strip(), arr))

for dylib in dylibs:
  output = command_to_list(f"otool -L {dylib}")
  output_opt = list(filter(lambda x: x.startswith('/usr/local/opt/'), output))
  print()
  print(dylib)
  for line in output_opt:
    print(line)