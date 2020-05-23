import os, sys
from pathlib import Path

# No arguments given
if len(sys.argv) == 1:
  for path in Path('./Script/').rglob('*.gd'):
    print("Linting: " + str(path))
    os.system(f'gdlint {path}')
    print("---")
  exit()

# Either a file or directory is given
path = sys.argv[1]
if path.endswith(".gd"):
  print("Linting: " + str(path))
  os.system(f'gdlint {path}')
elif path.endswith("/"):
  pass
