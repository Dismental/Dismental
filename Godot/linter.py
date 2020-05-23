import os, sys
from pathlib import Path

def gdlint(path):
  print("Linting: " + str(path))
  os.system(f'gdlint {path}')
  print("---")

# Recursive lint all .gd files
if len(sys.argv) == 1:
  for path in Path('./Script/').rglob('*.gd'):
    gdlint(path)
  exit()

path = sys.argv[1]
if os.path.isfile(path) and path.endswith(".gd"):
    gdlint(path)
elif os.path.isdir(path):
  # Non recursive
  for file in Path(path).glob('*.gd'):
    gdlint(file)
else:
  print("I could not find what you're looking for :(")