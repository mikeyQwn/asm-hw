from pathlib import Path
import subprocess

with open("subscript.txt") as sub:
    subscript = sub.read()

Path("hw").mkdir(exist_ok=True)

files = subprocess.run(["find", "./", "-name", "*.asm"], capture_output=True).stdout
for file in str(files, encoding="utf-8").splitlines():
    if "template" in file:
        continue
    if "hw" in file:
        continue
    print(f"FILENAME: {file}")
    filename = Path(file).name
    with open(f"hw/{filename}", "w") as out_file:
        out_file.write(subscript)
        print(filename)
        with open(file) as in_file:
            out_file.write(in_file.read())
