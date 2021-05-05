# Imaging pipeline for STRIAVISE WP1

### Assessing the influence of the striatum on visual selection

K. Garner (2021) CC BY-NC

This repo contains the code used for the analysis pipeline for the 7T MRI project that assesses information in striatal functional data when spatial expectations and incentive values influence visual priorities.

Dependencies are detailed beneath each subfolder below.

The Singularity recipes used to build a) fmriprep, and b) the computing environment used for the fitting of the GLMs is found [here]() and [here](https://github.com/kel-github/code-4-seq-comp-test-7T/blob/master/Singularity) respectively.

.
+-- _convert_data_to_BIDS
|   +-- cai2bids **dependencies: dcm2niix: https://github.com/rordenlab/dcm2niix** 

