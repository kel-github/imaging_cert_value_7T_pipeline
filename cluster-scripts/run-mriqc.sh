#!/bin/bash
#
#PBS -A UQ-SBS-Psy
#PBS -l select=1:ncpus=1:mpiprocs=1:mem=10GB:vmem=10GB
#PBS -l walltime=10:00:00
#PBS -o /scratch/user/uqkgarn1/log/mriqc
#PBS -e /scratch/user/uqkgarn1/log/mriqc

# START
BIDSDIR=/scratch/user/uqkgarn1/VALCERT
OUTPUT=/scratch/user/uqkgarn1/VALCERT/derivatives
setenv SINGULARITYENV_TEMPLATEFLOW_HOME /home/uqkgarn1/tmplts

module load singularity/3.5.0

singularity run -c -B /scratch/user/uqkgarn1/VALCERT:/bids-root -B /scratch/user/uqkgarn1/VALCERT/derivatives:/output-folder -B /scratch/user/uqkgarn1/tmp:/tmp /scratch/user/uqkgarn1/images/mriqc.simg /bids-root/ /output-folder/ participant