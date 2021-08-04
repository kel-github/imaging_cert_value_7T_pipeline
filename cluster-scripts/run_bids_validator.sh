#!/bin/bash
#
#PBS -A UQ-SBS-Psy
#PBS -l select=1:ncpus=1:mpiprocs=1:mem=10GB:vmem=10GB
#PBS -l walltime=10:00:00
#PBS -o /scratch/user/uqkgarn1/log/bids-val
#PBS -e /scratch/user/uqkgarn1/log/bids-val

# START
PROJPATH=/scratch/user/uqkgarn1/VALCERT
BVALPATH=/scratch/user/uqkgarn1/images/

module load singularity/3.5.0

singularity run -c -B $PROJPATH:/data:ro \
                      $BVALPATH/bids-validator.simg \
                      /data