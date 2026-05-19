import os
import torch
import torch.nn as nn
from torchvision import models
import json

BASE      = r"C:\PROJECTS\plastic_detection"
MODEL_DIR = os.path.join(BASE, "models")

# Load class names
with open(os.path.join(MODEL_DIR, "class_names.json")) as f:
    class_names = json.load(f)

NUM_CLASSES = len(class_names)
DEVICE      = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Rebuild model
model = models.mobilenet_v3_small(weights=None)
in_features = model.classifier[3].in_features
model.classifier[3] = nn.Linear(in_features, NUM_CLASSES)
model.load_state_dict(torch.load(os.path.join(MODEL_DIR, "best_model.pth"), map_location=DEVICE))
model.eval().to(DEVICE)

# Export to ONNX
dummy_input = torch.randn(1, 3, 224, 224).to(DEVICE)
onnx_path   = os.path.join(MODEL_DIR, "plastic_model.onnx")

torch.onnx.export(
    model,
    dummy_input,
    onnx_path,
    export_params=True,
    opset_version=12,
    do_constant_folding=True,
    input_names=["input"],
    output_names=["output"],
    dynamic_axes={"input": {0: "batch_size"}, "output": {0: "batch_size"}},
)

print(f"✅ ONNX model saved to: {onnx_path}")
print(f"   Classes: {class_names}")
