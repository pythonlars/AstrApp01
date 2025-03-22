# Astra - Skateboard Trick Recognition App

Eine iOS-App zur Erkennung von Skateboard-Tricks mit Machine Learning Unterstützung.

## Projektstruktur

```
Astra/
├── Astra.xcodeproj/     # Xcode Projektdateien
├── Views/               # SwiftUI Views
├── Models/              # Swift Datenmodelle
├── Services/            # Dienste und Utilities
└── ML/                  # Python ML-Modelle und Training
```

## Voraussetzungen

### iOS App
- Xcode 14.0+
- iOS 15.0+
- Swift 5.5+

### Machine Learning
- Python 3.8+
- TensorFlow 2.x
- scikit-learn
- pandas
- numpy

## Installation

### iOS App Setup
1. Öffnen Sie `Astra.xcodeproj` in Xcode
2. Wählen Sie Ihr Entwickler-Team in den Projekt-Einstellungen
3. Wählen Sie ein iOS-Gerät oder Simulator
4. Drücken Sie Run (⌘R)

### Python Environment Setup
1. Erstellen Sie eine virtuelle Umgebung:
   ```bash
   python -m venv venv
   source venv/bin/activate  # Unix
   venv\Scripts\activate     # Windows
   ```
2. Installieren Sie die Abhängigkeiten:
   ```bash
   pip install -r requirements.txt
   ```

## Entwicklung

### iOS App
- Die App verwendet SwiftUI für die Benutzeroberfläche
- CoreMotion für Bewegungserkennung
- Core ML für die Integration des ML-Modells

### Machine Learning
- Modelltraining in Python
- Konvertierung zu Core ML Format
- Datensammlung und Vorverarbeitung

## GitHub Workflow
1. Code ändern
2. `git add .`
3. `git commit -m "Beschreibung der Änderungen"`
4. `git push origin main`

## Lizenz
MIT License
