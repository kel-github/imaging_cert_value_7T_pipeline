# Get physiological regressors for mri data

**This is a set of functions that gets the physiological data from .dcm files to regressor.txt files. Uses functionality from the [PhysIO](https://github.com/translationalneuromodeling/tapas/blob/master/PhysIO/README.md) toolbox**

1. Use get_physio_regressor_files.m and extractCMRRPhysio.m to get the regressor files from .dcm to LOG.txt format. Note that this is also implemented as part of the cai2bids workflow. <p>

2. **Once data is in bids format** complete the following steps in Neurodesk to generate the physiological regressors for each participant: <p>

The following steps assume that you have [spm](https://en.wikibooks.org/wiki/SPM) on your matlab filepath, with the [physIO toolbox installed](https://github.com/translationalneuromodeling/tapas/tree/master/PhysIO). 

First we need to generate the info structures for each participant. This is a structure saved as a matfile for each participant in the subject data in 'derivatives' which contains the subject specific details that PhysIO needs to know to run. <p>

    * To do this first open the m file 'generate_sub_physio_info_file' - see the comments in the function for input argument details.




From there, use get_regressors.m as a wrapper for the run_tapas_toolbox.m function, which itself calls the spm matlabbatch in run_TAPAS_job.m

Note: bash scripting to run on HPC to follow.