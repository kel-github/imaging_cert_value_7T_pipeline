#!/bin/bash
#
#PBS -A UQ-SBS-Psy
#PBS -l select=1:ncpus=4:mpiprocs=1:mem=15GB:vmem=15GB
#PBS -l walltime=10:00:00
#PBS -o /scratch/user/uqkgarn1/log/mriqc
#PBS -e /scratch/user/uqkgarn1/log/mriqc

# START
BIDSDIR=/scratch/user/uqkgarn1/VALCERT
OUTPUT=/scratch/user/uqkgarn1/VALCERT/derivatives
# setenv SINGULARITYENV_TEMPLATEFLOW_HOME /home/uqkgarn1/tmplts
export SINGULARITYENV_TEMPLATEFLOW_HOME=/tmplts

module load singularity/3.5.0
singularity exec -c /scratch/user/uqkgarn1/images/mriqc.simg "env"

singularity run -c -B /scratch/user/uqkgarn1/VALCERT:/bids-root \
	               -B /scratch/user/uqkgarn1/VALCERT/derivatives:/output-folder \
				   -B /scratch/user/uqkgarn1/tmp:/tmp \
                   -B /home/uqkgarn1/tmplts:/tmplts \
				   -B /scratch/user/uqkgarn1/work:/work \
				/scratch/user/uqkgarn1/images/mriqc.simg -w /work \
					   --n_procs 1 --mem_gb 10 --n_cpus 4 \
					   /bids-root/ /output-folder/ participant \
					   --participant-label 01