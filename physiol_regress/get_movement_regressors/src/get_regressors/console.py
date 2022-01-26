import pandas as pd
import numpy as np
import os, re, json

def convert_motion_to_spm(data_dir, subject_number, session_number, runs, task):
    """Convert fmriprep confounds output to a txt file for use with spm

    Args:
        infile (str):  input filename
        outfile (str): output filename
    """
    fnms = list_files(data_dir, subject_number, session_number, runs, task)
    return [print_motion_regressors_for_spm(x) for x in fnms]


def main():
    convert_motion_to_spm(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])