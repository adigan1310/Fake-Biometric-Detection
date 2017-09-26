# Fake-Biometric-Detection


Getting Started:
This application is used to detect whether a biometric is fake or real based on extraction of its local texture descriptors such as Local Directional Pattern,
Discriminative Robust Local Binary Pattern and Rotation Invariant Local Phase Quantization. These extracted features are passed to Probabilistic Neural Network Classifier and it learns to classify between fake and real biometric. This classifier then predicts whether a biometric is fake or real.

Prerequisites:
MatLab Tool is required to run the code. Samples of fake and real biometrics must be obtained for training.

Installation:
1. Place Real Biometric Training Samples in RSamples/C_1 and Fake Biometric Training Samples in RSamples/C_2
2. Place Validation or Testing Biometric Samples in Inputs Folder.
3. Open MatLab tool
4. Run nnlearn.m file to train the pnn classifier with Rsamples folder as training input.
5. Run fake.m file to test the classifier with unseen/real data from Inputs folder.

Authors:
Adithya Ganapathy 
Adithya Narayanan
Vaishnavi Renganathan

License:
[ATVS-FakeFingerprint DATABASE (ATVS-FFp DB)] Licensed real and fake fingerprint samples.


.
