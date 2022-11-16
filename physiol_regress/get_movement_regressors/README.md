# Get Regressors

This is a simple package that will take fmriprep confounds files, and will
extract the motion regressors into a .txt file, suitable for use with SPM. <p>

Assumes data is in BIDS v1.0 format <p>

Only extracts motion and first derivative of x,y,z of roll and yaw

## Installation

From the root folder of this project:
```
conda create -n regressorpack python=3.10 numpy pandas matplotlib seaborn
conda activate regressorpack
pip install -e .
```

