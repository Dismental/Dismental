import os, sys
from pathlib import Path

# Files listed in .gdlintignore will always be ignored
# except if the "lint specific file(s)" command is used.

# Parse files to ignore
ignore = open("./.gdlintignore", "r")
ignore_files = []
for line in ignore:
  if not line.startswith("#"):
    ignore_files.append(line)

def gdlint(path):
  print("Linting: " + str(path))
  os.system(f'gdlint {path}')
  print("---")

def validFile(path):
  cond = os.path.isfile(path) and path.endswith(".gd")
  if cond == False:
    print("This path is invalid: " + path)
    print("---")
  return cond

# Recursive lint all .gd files
if len(sys.argv) == 1:
  for path in Path('./Script/').rglob('*.gd'):
    if path.name not in ignore_files:
      gdlint(path)
  exit()

paths = sys.argv[1:]
if len(paths) == 1:
  path = paths[0]
  if validFile(path):
      gdlint(path)
  elif os.path.isdir(path):
    # Non recursive
    for file in Path(path).glob('*.gd'):
      if file.name not in ignore_files:
        gdlint(file)

# If more paths are given to specific files
else:
  for path in paths:
    if validFile(path):
      gdlint(path)
