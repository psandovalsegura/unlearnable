#!/bin/bash
#SBATCH --account=djacobs
#SBATCH --job-name=craft-eps-2
#SBATCH --time=1-12:00:00
#SBATCH --partition=dpart
#SBATCH --qos=high
#SBATCH --ntasks=1
#SBATCH --gres=gpu:p6000:1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=8G
#SBATCH --output=slurm-%j-%x.out
#SBATCH --mail-type=end          
#SBATCH --mail-type=fail         
#SBATCH --mail-user=psando@umd.edu
# -- SBATCH --dependency=afterok:

set -x

export WORK_DIR="/scratch0/slurm_${SLURM_JOBID}"
export SCRIPT_DIR="/cfarhomes/psando/Documents/Unlearnable-Examples"
export CKPT_DIR="/vulcanscratch/psando/cifar_model_ckpts"

# Set environment 
# mkdir $WORK_DIR
# python3 -m venv ${WORK_DIR}/tmp-env
# source ${WORK_DIR}/tmp-env/bin/activate
# pip3 install --upgrade pip
# pip3 install -r ${SCRIPT_DIR}/requirements.txt

# Load Exp Settings
source exp_setting.sh


# Remove previous files
echo $exp_path


# Search Universal Perturbation and build datasets
cd ../../../../
pwd
rm -rf $exp_name
python3 perturbation.py --config_path             $config_path       \
                        --exp_name                $exp_path          \
                        --version                 $base_version      \
                        --train_data_type         $dataset_type      \
                        --noise_shape             50000 3 32 32      \
                        --epsilon                 $epsilon           \
                        --p_norm                  $p_norm            \
                        --num_steps               $num_steps         \
                        --step_size               $step_size         \
                        --attack_type             $attack_type       \
                        --perturb_type            $perturb_type      \
                        --universal_train_target  $universal_train_target\
                        --universal_stop_error    $universal_stop_error\
                        --num_of_workers          8
