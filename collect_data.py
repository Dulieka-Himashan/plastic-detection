import cv2
import os
import time

# Paths
BASE = r"C:\PROJECTS\plastic_detection"
PLASTIC_DIR = os.path.join(BASE, "data", "plastic")
NO_PLASTIC_DIR = os.path.join(BASE, "data", "no_plastic")

os.makedirs(PLASTIC_DIR, exist_ok=True)
os.makedirs(NO_PLASTIC_DIR, exist_ok=True)

cap = cv2.VideoCapture(0)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

print("\n=== Webcam Data Collection ===")
print("  Press 'p' → Save as PLASTIC")
print("  Press 'n' → Save as NO_PLASTIC")
print("  Press 'q' → Quit\n")

p_count = len(os.listdir(PLASTIC_DIR))
n_count = len(os.listdir(NO_PLASTIC_DIR))

while True:
    ret, frame = cap.read()
    if not ret:
        break

    display = frame.copy()

    # Show counts on screen
    cv2.putText(display, f"Plastic: {p_count}  No-Plastic: {n_count}",
                (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)
    cv2.putText(display, "P=Plastic  N=No-Plastic  Q=Quit",
                (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 0), 2)

    cv2.imshow("Data Collection", display)

    key = cv2.waitKey(1) & 0xFF

    if key == ord('p'):
        filename = os.path.join(PLASTIC_DIR, f"cam_plastic_{int(time.time()*1000)}.jpg")
        cv2.imwrite(filename, frame)
        p_count += 1
        print(f"  ✅ Saved PLASTIC [{p_count}]: {os.path.basename(filename)}")

    elif key == ord('n'):
        filename = os.path.join(NO_PLASTIC_DIR, f"cam_noplastic_{int(time.time()*1000)}.jpg")
        cv2.imwrite(filename, frame)
        n_count += 1
        print(f"  ✅ Saved NO_PLASTIC [{n_count}]: {os.path.basename(filename)}")

    elif key == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()

print(f"\n=== Session Summary ===")
print(f"  Plastic images:    {p_count}")
print(f"  No-plastic images: {n_count}")
