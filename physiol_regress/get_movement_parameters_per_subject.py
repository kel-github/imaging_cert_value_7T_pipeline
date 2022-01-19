# get motion regressors into a .txt file for use in PhysIO toolbox
### written by K. Garner, 2022

# %%[intro]
#
# all python related activities for this pipeline are done in the environment certval_pline

# %%
import pandas as pd
import numpy as np
import os, re, json

# %%[] 
# First define parameters and collect subject/session iterables

# %%
data_dir = '/clusterdata/uqkgarn1/scratch/data/'
subject_number = '01' 
session_number = pd.Series(str(2)) # this assumes data is in BIDS
runs = pd.Series(str(x) for x in [1, 2, 3])

# %%[]
# Now making a list of the confounds file for that participant

# %% s
