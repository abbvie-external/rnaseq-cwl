#!/bin/bash
#SBATCH --chdir=XX-slurm_workdir-XX            # Working directory
#SBATCH --cpus-per-task=XX-slurm_cpus-XX       # Number of CPU cores per task
#SBATCH --job-name=XX-slurm_jobname-XX         # Job name
#SBATCH --ntasks=1                             # Run on a single CPU
#SBATCH --mem=XX-slurm_mem-XX                  # Job memory request
#SBATCH --time=XX-slurm_timeout_hours-XX:00:00
#SBATCH --partition XX-slurm_partition-XX

unset DISPLAY

mkdir -p XX-workdir-XX
export BCLCONVTMP=XX-workdir-XX/logbclconvert
mkdir -p ${BCLCONVTMP}
export APPTAINER_BIND="${BCLCONVTMP}:/var/log/bcl-convert"
export APPTAINER_CACHEDIR=/scratch/users/XX-username-XX/singcache
export SINGULARITY_LOCALCACHEDIR=/scratch/users/XX-username-XX/singtemp
export APPTAINER_TMPDIR=/scratch/users/XX-username-XX/singtemp
export APPTAINERENV_TMPDIR=/scratch/users/XX-username-XX/singtemp
export SINGULARITY_PULLFOLDER=XX-singularity_pullfolder-XX
export CWL_SINGULARITY_CACHE=XX-cwl_singularity_cache-XX

XX-cwl_engine-XX \
    --debug \
    XX-container-XX \
    --timestamps \
    --tmpdir-prefix XX-cwl_tmpdir-XX/ \
    --cachedir XX-cwl_cachedir-XX/ \
    --outdir XX-cwl_outdir-XX \
    XX-cwl_workflow-XX \
    XX-cwl_job-XX \
    1> XX-cwl_stdout-XX \
    2> XX-cwl_stderr-XX
