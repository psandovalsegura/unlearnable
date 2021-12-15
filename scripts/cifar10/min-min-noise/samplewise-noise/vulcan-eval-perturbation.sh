#!/bin/bash
#SBATCH --account=djacobs
#SBATCH --job-name=unlearnable-cifar10-eval
#SBATCH --time=1-00:00:00
#SBATCH --partition=dpart
#SBATCH --qos=high
#SBATCH --ntasks=1
#SBATCH --gres=gpu:p6000:1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=8G
# -- SBATCH --mail-type=end          
# -- SBATCH --mail-type=fail         
# -- SBATCH --mail-user=psando@umd.edu
# -- SBATCH --dependency=afterok:

set -x

export WORK_DIR="/scratch0/slurm_${SLURM_JOBID}"
export SCRIPT_DIR="/cfarhomes/psando/Documents/Unlearnable-Examples"
export CKPT_DIR="/vulcanscratch/psando/cifar_model_ckpts"

# Set environment 
mkdir $WORK_DIR
python3 -m venv ${WORK_DIR}/tmp-env
source ${WORK_DIR}/tmp-env/bin/activate
pip3 install --upgrade pip
pip3 install -r ${SCRIPT_DIR}/requirements.txt

# Load Exp Settings
source exp_setting.sh


# Remove previous files
echo $exp_path


# Search Universal Perturbation and build datasets
cd ../../../../
pwd

python3 -u main.py    --version                 resnet18                       \
                      --exp_name                $exp_path                      \
                      --config_path             $config_path                   \
                      --train_data_type         PoisonCIFAR10                  \
                      --poison_rate             1.0                            \
                      --perturb_type            $perturb_type                  \
                      --perturb_tensor_filepath experiments/cifar10/min-min_samplewise/CIFAR10-eps=8-se=0.01-base_version=resnet18/perturbation.pt \
                      --train
