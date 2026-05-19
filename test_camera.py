import cv2
import torch
import torch.nn as nn
from torchvision import models, transforms
import json
import os

BASE      = r"C:\PROJECTS\plastic_detection"
MODEL_DIR = os.path.join(BASE, "models")
DEVICE    = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Load class names
with open(os.path.join(MODEL_DIR, "class_names.json")) as f:
    class_names = json.load(f)

# Load model
model = models.mobilenet_v3_small(weights=None)
in_features = model.classifier[3].in_features
model.classifier[3] = nn.Linear(in_features, len(class_names))
model.load_state_dict(torch.load(os.path.join(MODEL_DIR, "best_model.pth"), map_location=DEVICE))
model.eval().to(DEVICE)

transform = transforms.Compose([
    transforms.ToPILImage(),
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406],
                         [0.229, 0.224, 0.225]),
])

cap = cv2.VideoCapture(0)
print("\n🎥 Live Plastic Detection — Press 'q' to quit\n")

while True:
    ret, frame = cap.read()
    if not ret:
        break

    rgb   = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    input_tensor = transform(rgb).unsqueeze(0).to(DEVICE)

    with torch.no_grad():
        outputs = torch.softmax(model(input_tensor), dim=1)
        confidence, predicted = outputs.max(1)
        label = class_names[predicted.item()]
        conf  = confidence.item() * 100

    # Color: green for plastic, red for no_plastic
    color = (0, 255, 0) if label == "plastic" else (0, 0, 255)

    cv2.putText(frame, f"{label.upper()}", (20, 50),
                cv2.FONT_HERSHEY_SIMPLEX, 1.5, color, 3)
    cv2.putText(frame, f"Confidence: {conf:.1f}%", (20, 100),
                cv2.FONT_HERSHEY_SIMPLEX, 0.9, color, 2)

    # Draw border
    h, w = frame.shape[:2]
    cv2.rectangle(frame, (0, 0), (w-1, h-1), color, 8)

    cv2.imshow("Plastic Detector", frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
