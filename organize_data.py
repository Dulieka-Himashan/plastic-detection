import os
import shutil
from tqdm import tqdm

# Paths
BASE           = r"C:\PROJECTS\plastic_detection"
SOURCE         = os.path.join(BASE, "data", "images", "images")
PLASTIC_DIR    = os.path.join(BASE, "data", "plastic")
NO_PLASTIC_DIR = os.path.join(BASE, "data", "no_plastic")

PLASTIC_CLASSES = [
    "disposable_plastic_cutlery",
    "plastic_cup_lids",
    "plastic_detergent_bottles",
    "plastic_food_containers",
    "plastic_shopping_bags",
    "plastic_soda_bottles",
    "plastic_straws",
    "plastic_trash_bags",
    "plastic_water_bottles",
    "styrofoam_cups",
    "styrofoam_food_containers",
]

NO_PLASTIC_CLASSES = [
    "aerosol_cans",
    "aluminum_food_cans",
    "aluminum_soda_cans",
    "cardboard_boxes",
    "cardboard_packaging",
    "clothing",
    "coffee_grounds",
    "eggshells",
    "food_waste",
    "glass_beverage_bottles",
    "glass_cosmetic_containers",
    "glass_food_jars",
    "magazines",
    "newspaper",
    "office_paper",
    "paper_cups",
    "shoes",
    "steel_food_cans",
    "tea_bags",
]

os.makedirs(PLASTIC_DIR, exist_ok=True)
os.makedirs(NO_PLASTIC_DIR, exist_ok=True)

def copy_images(classes, dest_dir, label):
    count = 0
    for cls in classes:
        cls_root = os.path.join(SOURCE, cls)
        if not os.path.exists(cls_root):
            print(f"  WARNING: folder not found: {cls}")
            continue

        # Walk all subfolders (default, real_world, etc.)
        all_files = []
        for root, dirs, files in os.walk(cls_root):
            for f in files:
                if f.lower().endswith(('.jpg', '.jpeg', '.png')):
                    all_files.append(os.path.join(root, f))

        for src_path in tqdm(all_files, desc=f"{label} | {cls}"):
            subfolder = os.path.basename(os.path.dirname(src_path))
            fname     = os.path.basename(src_path)
            dst_name  = f"{cls}_{subfolder}_{fname}"
            dst_path  = os.path.join(dest_dir, dst_name)
            shutil.copy2(src_path, dst_path)
            count += 1

    return count

print("\n=== Organizing Dataset ===\n")
p_count = copy_images(PLASTIC_CLASSES,    PLASTIC_DIR,    "PLASTIC")
n_count = copy_images(NO_PLASTIC_CLASSES, NO_PLASTIC_DIR, "NO_PLASTIC")

print(f"\n✅ Done!")
print(f"   Plastic images:    {p_count}")
print(f"   No-plastic images: {n_count}")
print(f"   Total:             {p_count + n_count}")
