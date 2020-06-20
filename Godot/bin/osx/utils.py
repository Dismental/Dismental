import subprocess

def command_to_list(cmd):
  arr = subprocess.check_output(cmd, shell=True).decode('utf-8').strip().split('\n')
  return list(map(lambda x: x.strip(), arr))

def cleanOtool(output_otool):
  # Remove first 2 lines, first line is filename, second is reference to itself
  removed_headers = output_otool[2:]
  # Remove additional info such as compatibility - & current version
  return list(map(lambda x: x.split(' ')[0], removed_headers))

def startsWithAny(str, prefixes):
  for prefix in prefixes:
    if str.startswith(prefix):
      return True
  return False

def getFile(path):
  return path.split('/')[-1]