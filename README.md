♻️ CarbonEye
AI-Powered Smart Plastic Recycling System

Intelligent Edge AI + IoT platform that automates plastic recycling using computer vision, Raspberry Pi, AWS Serverless, and a Flutter mobile application.

🌍 Overview

CarbonEye is a smart reverse-vending recycling system developed to encourage sustainable plastic waste management through Artificial Intelligence, IoT, Cloud Computing, and gamification.

Instead of using traditional recycling bins, CarbonEye automatically detects plastic waste using a deep learning model deployed on a Raspberry Pi. Once plastic is detected, users are rewarded through an integrated cloud platform and mobile application.

The project was developed by the NSBM Circularity & Sustainability Community in collaboration with Sysco LABS.

🚨 The Problem

Traditional recycling bins provide:

No waste verification
No user identification
No incentive to recycle
No recycling analytics

As a result, recycling participation remains low.

CarbonEye transforms ordinary recycling into an interactive smart recycling experience.

💡 Solution

CarbonEye combines:

Edge AI
Embedded Systems
Cloud Computing
Mobile Application Development

to automatically

Detect plastic waste
Identify users using NFC
Calculate reward points
Store recycling transactions
Display environmental impact
Allow voucher redemption
🏗 System Architecture
Student
    │
NFC Authentication
    │
Raspberry Pi Zero 2W
    │
Camera Capture
    │
MobileNetV3 Plastic Detection
    │
Weight Measurement
    │
AWS API Gateway
    │
AWS Lambda
    │
Amazon DynamoDB
    │
Flutter Mobile App
✨ Features
♻️ AI-powered plastic detection
📷 Edge inference using MobileNetV3 Small
🍓 Raspberry Pi Zero 2W deployment
🏷 NFC student identification
☁️ AWS Serverless backend
📱 Flutter mobile application
🏆 Recycling leaderboard
🎁 Voucher redemption
📈 Environmental impact tracking
📊 Real-time recycling history
🧠 Machine Learning

Model:

MobileNetV3 Small

Framework:

PyTorch
ONNX Runtime

Deployment:

Raspberry Pi Zero 2W

Dataset

15,281 training images
180 real-world deployment images

Performance

Metric	Value
Initial Validation Accuracy	91.97%
Deployment Accuracy	100%*

Deployment-specific fine-tuning on real-world data.

☁ Cloud Architecture

AWS Services

API Gateway
Lambda
DynamoDB

Features

Serverless REST API
User management
Transaction history
Leaderboard
Voucher redemption
Point calculation
📱 Mobile Application

Built using Flutter.

Features include

Google Sign-In
Green Points Dashboard
Recycling History
Voucher Redemption
Environmental Impact
User Profile
Leaderboard
🔌 Hardware
Raspberry Pi Zero 2W
Pi Camera
RC522 NFC Reader
PIR Motion Sensor
Motor Driver
Gear Motor
Weight Sensor
OLED Display
Buzzer
🛠 Technology Stack
Programming
Python
Dart
AI
PyTorch
MobileNetV3
ONNX Runtime
Cloud
AWS Lambda
API Gateway
DynamoDB
Mobile
Flutter
Hardware
Raspberry Pi
NFC
IoT
🚀 Future Improvements
Multi-class plastic classification
Multiple smart bins
Carbon footprint analytics
Solar-powered deployment
Multi-campus support
Admin dashboard
👨‍💻 Team

Project Lead & Machine Learning Engineer

Dulieka Himashan

Developed as part of the NSBM Circularity & Sustainability Community in collaboration with Sysco LABS.
