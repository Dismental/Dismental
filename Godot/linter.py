import os
from pathlib import Path

for path in Path('./Script/').rglob('*.gd'):
  print("Linting: " + str(path))
  os.system(f'gdlint {path}')
  print("---")
