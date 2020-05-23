import os, sys
from pathlib import Path

# Files listed in .gdlintignore will always be ignored
# except if the "lint specific file(s)" command is used.

# Parse files to ignore
ignore = open("./.gdlintignore", "r")
ignore_files = []
for line in ignore:
  if not line.startswith("#"):
    ignore_files.append(line.rstrip())

def gdlint(path):
  print(f"Linting: {path}")
  os.system(f'gdlint {path}')
  print("---")

def validFile(path):
  return os.path.isfile(path) and path.endswith(".gd")

# If no additional arguments are given
# Recursive lint all .gd files in ./Script/
# and non-recursively lint all .gd files in ./
if len(sys.argv) == 1:
  files_to_lint = []

  for path in Path('./').glob('*.gd'):
    files_to_lint.append(path)
  
  for path in Path('./Script/').rglob('*.gd'):
    files_to_lint.append(path)

  for path in files_to_lint:
    if path.name not in ignore_files:
      gdlint(path)
  exit()

# If it's a list of paths
paths = sys.argv[1:]
files_to_lint = []
for path in paths:
  if os.path.isdir(path):
    for file in Path(path).glob('*.gd'):
      files_to_lint.append(file)    

  if validFile(path):
    files_to_lint.append(path)

for file in files_to_lint:
  gdlint(file)
