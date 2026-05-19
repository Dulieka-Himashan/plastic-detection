# Plastic Detection Project — Full Summary & Continuation Prompt

## Copy everything below this line and paste it into a new chat:

---

I am building a **plastic detection system** that runs on an **ESP32-S3 Sense board**. I need to continue exactly where I left off. Here is everything that has been done and the full plan:

---

## 🎯 Project Goal
Detect presence or absence of **general plastic waste** in real time using the ESP32-S3 Sense onboard camera. Binary classification: `plastic` vs `no_plastic`.

---

## 💻 My System
- **OS:** Windows 10 (Version 10.0.26200.8037)
- **GPU:** NVIDIA GeForce RTX 2050 (4GB VRAM)
- **CUDA:** 11.8 installed (via winget)
- **cuDNN:** 8.9.7 for CUDA 11.x installed (files copied manually to CUDA folder)
- **Python:** 3.11.9 (installed alongside existing Python 3.12.4)
- **Project folder:** `C:\PROJECTS\plastic_detection`
- **Virtual env:** `plastic_env` (Python 3.11)

---

## ✅ What Has Been Done (ALL COMPLETED)

### Environment Setup
- Installed Python 3.11.9, CUDA 11.8, cuDNN 8.9.7
- Created virtual env with PyTorch + CUDA 11.8
- GPU verified: `torch.cuda.is_available()` = True, device = NVIDIA GeForce RTX 2050
- Installed: opencv-python, matplotlib, scikit-learn, tqdm, kaggle

### Dataset
- Downloaded: `alistairking/recyclable-and-household-waste-classification` (964MB) via Kaggle
- Organized into:
  - `C:\PROJECTS\plastic_detection\data\plastic\` → 5,660 images (5,500 dataset + 160 webcam)
  - `C:\PROJECTS\plastic_detection\data\no_plastic\` → 9,621 images (9,500 dataset + 121 webcam)
  - **Total: 15,281 images**
- Raw dataset moved to: `C:\PROJECTS\plastic_detection\images_raw\`

### Model Training (COMPLETED ✅)
- Model: MobileNetV3 Small pretrained on ImageNet
- Two-stage fine-tuning:
  - Stage 1 (10 epochs, frozen base): Best Val Acc = 88.79%
  - Stage 2 (20 epochs, full fine-tune): Best Val Acc = **91.97%**
- Best model saved: `C:\PROJECTS\plastic_detection\models\best_model.pth`
- Class names saved: `C:\PROJECTS\plastic_detection\models\class_names.json`
  - Classes: `['no_plastic', 'plastic']` (index 0 = no_plastic, index 1 = plastic)
- Training curves saved: `C:\PROJECTS\plastic_detection\models\training_curves.png`

### Live Testing on Laptop Camera (COMPLETED ✅)
- Tested with `test_camera.py` — working perfectly:
  - Steel bottle → NO_PLASTIC 90.8% ✅
  - Plastic Sprite bottle (worn label) → PLASTIC 79.7% ✅
  - Plastic bottle from distance → PLASTIC 87.4% ✅
  - Hand → NO_PLASTIC 97.8% ✅

### Scripts (all in C:\PROJECTS\plastic_detection\)
- ✅ `organize_data.py` — done
- ✅ `collect_data.py` — done
- ✅ `train.py` — done
- ✅ `export_onnx.py` — ready to run
- ✅ `test_camera.py` — done, working

---

## 🔴 Current Step — ONNX Export

**Next action:** Export trained PyTorch model to ONNX format:
```bash
cd C:\PROJECTS\plastic_detection
plastic_env\Scripts\activate
python export_onnx.py
```
Output will be: `C:\PROJECTS\plastic_detection\models\plastic_model.onnx`

---

## 📋 Remaining Steps (in order)

1. ✅ ~~Environment setup~~
2. ✅ ~~Download and organize dataset~~
3. ✅ ~~Collect webcam images~~
4. ✅ ~~Train model (91.97% accuracy)~~
5. ✅ ~~Test live on laptop camera~~
6. 🔴 **Export to ONNX** (`python export_onnx.py`) ← CURRENT STEP
7. ⬜ Convert ONNX → TFLite INT8 (`onnx2tf`)
8. ⬜ Deploy to ESP32-S3 Sense via Arduino IDE

---

## 🏗️ Full Pipeline

```
PyTorch + CUDA 11.8 (RTX 2050 GPU)
          ↓
MobileNetV3 Small (pretrained ImageNet, fine-tuned)
          ↓
Binary Classification: plastic / no_plastic
          ↓
Export to ONNX  ← NEXT
          ↓
Convert ONNX → TFLite INT8 (onnx2tf)
          ↓
Deploy to ESP32-S3 Sense via Arduino IDE
```

---

## ⚙️ How To Activate Environment In New Session
```bash
cd C:\PROJECTS\plastic_detection
plastic_env\Scripts\activate
```

## Kaggle Token (set each new CMD session if needed)
```bash
set KAGGLE_API_TOKEN=KGAT_f5212b7e13799a1980d8399fbc4788fe
```

---

## Important Notes
- Do NOT use TensorFlow for training — it doesn't detect GPU on Windows 2.11+
- PyTorch is the training framework, TFLite is only the final export format for ESP32
- The user is a fast learner — give complete production-quality code, not prototypes
- Always give step-by-step CMD/PowerShell instructions
- Class imbalance handled with WeightedRandomSampler in train.py
- num_workers=0 required in DataLoader on Windows
- Dataset images folder moved to images_raw/ to avoid being picked up as a third class
- Classes order: index 0 = no_plastic, index 1 = plastic
