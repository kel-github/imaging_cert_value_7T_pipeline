# Get physiological regressors for mri data

**This is a set of functions that gets the physiological data from .dcm files to regressor.txt files. Uses functionality from the [PhysIO](https://github.com/translationalneuromodeling/tapas/blob/master/PhysIO/README.md) toolbox**

1. Use get_physio_regressor_files.m and extractCMRRPhysio.m to get the regressor files from .dcm to LOG.txt format. Note that this is also implemented as part of the cai2bids workflow. <p>

2. **Once data is in bids format** follow [this tutorial](https://neurodesk.github.io/tutorials/functional_imaging/physio_batch_workflow/) for [Neurodesk](https://neurodesk.github.io/) to generate the physiological regressors for each participant: <p>