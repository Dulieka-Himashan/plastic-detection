import os
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, WeightedRandomSampler
from torchvision import datasets, transforms, models
from tqdm import tqdm
import matplotlib.pyplot as plt
import json

# ─── Config ───────────────────────────────────────────────────────────────────
BASE        = r"C:\PROJECTS\plastic_detection"
DATA_DIR    = os.path.join(BASE, "data")
MODEL_DIR   = os.path.join(BASE, "models")
os.makedirs(MODEL_DIR, exist_ok=True)

IMG_SIZE    = 224
BATCH_SIZE  = 32
NUM_CLASSES = 2
DEVICE      = torch.device("cuda" if torch.cuda.is_available() else "cpu")

print(f"\n{'='*50}")
print(f"  Device: {DEVICE}")
if torch.cuda.is_available():
    print(f"  GPU:    {torch.cuda.get_device_name(0)}")
print(f"{'='*50}\n")

# ─── Transforms ───────────────────────────────────────────────────────────────
train_transform = transforms.Compose([
    transforms.Resize((IMG_SIZE, IMG_SIZE)),
    transforms.RandomHorizontalFlip(),
    transforms.RandomVerticalFlip(p=0.2),
    transforms.RandomRotation(20),
    transforms.ColorJitter(brightness=0.3, contrast=0.3, saturation=0.3, hue=0.1),
    transforms.RandomAffine(degrees=0, translate=(0.1, 0.1), scale=(0.9, 1.1)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406],
                         [0.229, 0.224, 0.225]),
])

val_transform = transforms.Compose([
    transforms.Resize((IMG_SIZE, IMG_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406],
                         [0.229, 0.224, 0.225]),
])

# ─── Dataset ──────────────────────────────────────────────────────────────────
# Only load plastic/ and no_plastic/ folders
full_dataset = datasets.ImageFolder(DATA_DIR, transform=train_transform,
    is_valid_file=lambda x: x.lower().endswith(('.jpg', '.jpeg', '.png')))

# Verify only 2 classes
class_names = full_dataset.classes
print(f"Classes found: {class_names}")
assert len(class_names) == 2, f"Expected 2 classes, got {len(class_names)}: {class_names}"
print(f"Total images:  {len(full_dataset)}\n")

for cls, idx in full_dataset.class_to_idx.items():
    count = sum(1 for _, l in full_dataset.samples if l == idx)
    print(f"  {cls}: {count} images")

# Train/val split (85/15)
val_size   = int(0.15 * len(full_dataset))
train_size = len(full_dataset) - val_size
train_dataset, val_dataset = torch.utils.data.random_split(
    full_dataset, [train_size, val_size],
    generator=torch.Generator().manual_seed(42)
)

# Weighted sampler to handle class imbalance
train_labels = [full_dataset.samples[i][1] for i in train_dataset.indices]
class_counts = [train_labels.count(i) for i in range(NUM_CLASSES)]
class_weights = [1.0 / c for c in class_counts]
sample_weights = [class_weights[l] for l in train_labels]
sampler = WeightedRandomSampler(sample_weights, len(sample_weights))

# num_workers=0 required on Windows
train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, sampler=sampler,
                          num_workers=0, pin_memory=True)
val_loader   = DataLoader(val_dataset,   batch_size=BATCH_SIZE, shuffle=False,
                          num_workers=0, pin_memory=True)

print(f"\nTrain: {train_size} | Val: {val_size}\n")

# ─── Model ────────────────────────────────────────────────────────────────────
model = models.mobilenet_v3_small(weights=models.MobileNet_V3_Small_Weights.IMAGENET1K_V1)
in_features = model.classifier[3].in_features
model.classifier[3] = nn.Linear(in_features, NUM_CLASSES)
model = model.to(DEVICE)

# ─── Training Functions ───────────────────────────────────────────────────────
def train_epoch(model, loader, optimizer, criterion):
    model.train()
    running_loss, correct, total = 0.0, 0, 0
    for inputs, labels in tqdm(loader, leave=False):
        inputs, labels = inputs.to(DEVICE), labels.to(DEVICE)
        optimizer.zero_grad()
        outputs = model(inputs)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()
        running_loss += loss.item() * inputs.size(0)
        _, predicted = outputs.max(1)
        correct += predicted.eq(labels).sum().item()
        total += labels.size(0)
    return running_loss / total, 100. * correct / total

def val_epoch(model, loader, criterion):
    model.eval()
    running_loss, correct, total = 0.0, 0, 0
    with torch.no_grad():
        for inputs, labels in tqdm(loader, leave=False):
            inputs, labels = inputs.to(DEVICE), labels.to(DEVICE)
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            running_loss += loss.item() * inputs.size(0)
            _, predicted = outputs.max(1)
            correct += predicted.eq(labels).sum().item()
            total += labels.size(0)
    return running_loss / total, 100. * correct / total

criterion = nn.CrossEntropyLoss()
history   = {"train_loss": [], "train_acc": [], "val_loss": [], "val_acc": []}

# ─── Stage 1: Train classifier head only ─────────────────────────────────────
print("="*50)
print("  STAGE 1: Training classifier head (10 epochs)")
print("="*50)

for param in model.features.parameters():
    param.requires_grad = False

optimizer = optim.Adam(model.classifier.parameters(), lr=1e-3)
scheduler = optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=10)

best_val_acc = 0.0
for epoch in range(10):
    tr_loss, tr_acc = train_epoch(model, train_loader, optimizer, criterion)
    vl_loss, vl_acc = val_epoch(model, val_loader, criterion)
    scheduler.step()

    history["train_loss"].append(tr_loss)
    history["train_acc"].append(tr_acc)
    history["val_loss"].append(vl_loss)
    history["val_acc"].append(vl_acc)

    print(f"Epoch {epoch+1:02d}/10 | Train Loss: {tr_loss:.4f} Acc: {tr_acc:.2f}% | Val Loss: {vl_loss:.4f} Acc: {vl_acc:.2f}%")

    if vl_acc > best_val_acc:
        best_val_acc = vl_acc
        torch.save(model.state_dict(), os.path.join(MODEL_DIR, "best_stage1.pth"))

print(f"\n✅ Stage 1 Best Val Acc: {best_val_acc:.2f}%\n")

# ─── Stage 2: Fine-tune full model ───────────────────────────────────────────
print("="*50)
print("  STAGE 2: Fine-tuning full model (20 epochs)")
print("="*50)

for param in model.parameters():
    param.requires_grad = True

optimizer = optim.Adam(model.parameters(), lr=1e-5)
scheduler = optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=20)

best_val_acc = 0.0
for epoch in range(20):
    tr_loss, tr_acc = train_epoch(model, train_loader, optimizer, criterion)
    vl_loss, vl_acc = val_epoch(model, val_loader, criterion)
    scheduler.step()

    history["train_loss"].append(tr_loss)
    history["train_acc"].append(tr_acc)
    history["val_loss"].append(vl_loss)
    history["val_acc"].append(vl_acc)

    print(f"Epoch {epoch+1:02d}/20 | Train Loss: {tr_loss:.4f} Acc: {tr_acc:.2f}% | Val Loss: {vl_loss:.4f} Acc: {vl_acc:.2f}%")

    if vl_acc > best_val_acc:
        best_val_acc = vl_acc
        torch.save(model.state_dict(), os.path.join(MODEL_DIR, "best_model.pth"))
        print(f"  ✅ Saved best model (Val Acc: {vl_acc:.2f}%)")

print(f"\n🎉 Training Complete! Best Val Acc: {best_val_acc:.2f}%")

# Save class names
with open(os.path.join(MODEL_DIR, "class_names.json"), "w") as f:
    json.dump(class_names, f)
print(f"   Classes: {class_names}")

# ─── Plot Training Curves ─────────────────────────────────────────────────────
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
ax1.plot(history["train_loss"], label="Train Loss")
ax1.plot(history["val_loss"],   label="Val Loss")
ax1.set_title("Loss"); ax1.legend(); ax1.set_xlabel("Epoch")
ax2.plot(history["train_acc"], label="Train Acc")
ax2.plot(history["val_acc"],   label="Val Acc")
ax2.set_title("Accuracy (%)"); ax2.legend(); ax2.set_xlabel("Epoch")
plt.tight_layout()
plt.savefig(os.path.join(MODEL_DIR, "training_curves.png"))
plt.show()
print(f"\n📊 Training curves saved to {MODEL_DIR}\\training_curves.png")

if __name__ == '__main__':
    pass
