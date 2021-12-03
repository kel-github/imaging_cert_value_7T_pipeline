#!/bin/bash
#
#PBS -A UQ-SBS-Psy
#PBS -l select=1:ncpus=4:mpiprocs=1:mem=15GB:vmem=15GB
#PBS -l walltime=10:00:00
#PBS -o /scratch/user/uqkgarn1/log/fmriprep
#PBS -e /scratch/user/uqkgarn1/log/fmriprep

# START
module load singularity/3.5.0
singularity exec -c /scratch/user/uqkgarn1/images/fmriprep-latest-20210805.simg "env"
singularity exec -c /scratch/user/uqkgarn1/images/fmriprep-latest-20210805.simg "env"
export SINGULARITYENV_TEMPLATEFLOW_HOME=/fprephome

singularity run -c -B /scratch/user/uqkgarn1/VALCERT:/bids-root \
	               -B /scratch/user/uqkgarn1/VALCERT/derivatives/fmriprep:/output-folder \
				   -B /scratch/user/uqkgarn1/tmp:/tmp \
                   -B /scratch/user/uqkgarn1/fprephome:/fprephome \
				   -B /home/uqkgarn1/freesurfer:/freesurfer \
				   -B /scratch/user/uqkgarn1/work:/work \
				   -B /scratch/user/uqkgarn1/fprephome:/home/fmriprep \
				/scratch/user/uqkgarn1/images/fmriprep-latest-20210805.simg \
					   /bids-root /output-folder participant \
					   -w /work \
					   --fs-license-file /freesurfer/freesurfer.txt \
					   --participant-label 01 \
					   --nprocs 1 --mem 10000 \
					   -v
# --dummy-scans

module load singularity/3.5.0
singularity exec -c /home/user/fmriprep/20.2.3.simg "env"

singularity run -c -B ~/Desktop/neurodesktop-storage/data:/bids-root \
	               -B ~/Desktop/neurodesktop-storage/data/derivatives/fmriprep:/output-folder \
				   -B ~/Desktop/neurodesktop-storage/scripts/imaging_cert_value_7T_pipeline/dependencies/freesurfer:/freesurfer \ #?
				   -B ~/Desktop/neurodesktop-storage/work:/work \
				/NEED THIS ADDRESS/fmriprep-latest-20210805.simg \
					   /bids-root /output-folder participant \
					   -w /work \
					   --fs-license-file /freesurfer/freesurfer.txt \
					   --participant-label 01 \
					   -v