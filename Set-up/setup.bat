@echo off
REM Create Python virtual environment and install dependencies
python -m venv venv
call venv\Scripts\activate
pip install -r requirements.txt

REM Create project directories
mkdir Astra
cd Astra
mkdir Services
mkdir Models
mkdir Views
mkdir ML

REM Train the model
python ML/train_trick_classifier.py

echo Setup complete! Now:
echo 1. Open Xcode and create a new iOS project named "Astra"
echo 2. Copy the generated TrickClassifier.mlmodel into your Xcode project
echo 3. Build and run on a physical iOS device 