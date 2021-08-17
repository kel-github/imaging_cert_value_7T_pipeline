# Get physiological regressors for mri data

**This is a set of functions that gets the physiological data from .dcm files to regressor..txt files. Uses functionality from the PhysIO toolbox**

1. Use get_physio_regressor_files.m and extractCMRRPhysio.m to get the regressor files from .dcm to LOG.txt format. Note that this is also implemented as part of the cai2bids workflow.

2. From there, use get_regressors.m as a wrapper for the run_tapas_toolbox.m function, which itself calls the spm matlabbatch in run_TAPAS_job.m

Note: bash scripting to run on HPC to follow.