import os
import re

input_file = r"c:\Users\sanam\Desktop\metaCart\metacart\specs\requirements\detailed_screen_specs"
output_dir = r"c:\Users\sanam\Desktop\metaCart\metacart\specs\screens"
os.makedirs(output_dir, exist_ok=True)

with open(input_file, 'r', encoding='utf-8') as f:
    lines = f.readlines()

current_phase = None
current_content = []

def save_phase():
    if current_phase and current_content:
        # Sanitize filename
        filename = current_phase.replace(":", "").replace(" ", "_").replace("/", "_") + ".md"
        with open(os.path.join(output_dir, filename), 'w', encoding='utf-8') as out:
            out.writelines(current_content)

for line in lines:
    match = re.match(r'^(PHASE \d+.*)', line.strip())
    if match:
        save_phase()
        current_phase = match.group(1)
        current_content = [line]
    else:
        if current_phase is not None:
            current_content.append(line)

save_phase()
print("Split complete.")
