import os

dir_path = 'c:/Users/Lenovo/OneDrive/Desktop/techon_26/lib'

for root, _, files in os.walk(dir_path):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            new_lines = []
            for line in lines:
                stripped = line.strip()
                if stripped.startswith('//'):
                    continue
                new_lines.append(line)
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)

print("Comments removed.")
