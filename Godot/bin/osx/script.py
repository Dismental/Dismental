import glob
import subprocess

NEW_LOCATION = "@loader_path/"

def command_to_list(cmd):
  arr = subprocess.check_output(cmd, shell=True).decode('utf-8').strip().split('\n')
  return list(map(lambda x: x.strip(), arr))

# output = subprocess.check_output("ls -d libopencv*4.3.0.dylib", shell=True).decode('utf-8').strip().split('\n')
# print(output)

filename = "libopencv_dnn.4.3.0.dylib"
# Remove first 2 lines, first line is filename, second is reference to itself
output_dnn = command_to_list(f"otool -L {filename}")[2:]
clean = list(map(lambda x: x.split(' ')[0], output_dnn))
opt_paths = list(filter(lambda x: x.startswith("/usr/local/opt"), clean))
print(opt_paths)

# for opt_path in opt_paths:
#   lib 
#   subprocess.run(f"sudo install_name_tool -change {opt_path} {NEW_LOCATION}/libprotobuf.23.dylib {filename}", shell=True)
