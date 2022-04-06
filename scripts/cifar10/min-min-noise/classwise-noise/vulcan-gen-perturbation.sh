#!/bin/bash
#SBATCH --account=djacobs
#SBATCH --job-name=craft-ens
#SBATCH --time=1-12:00:00
#SBATCH --partition=dpart
#SBATCH --qos=medium
#SBATCH --ntasks=1
#SBATCH --gres=gpu:p6000:1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=8G
#SBATCH --output=s-%j-%x.out
#SBATCH --mail-type=end          
#SBATCH --mail-type=fail         
#SBATCH --mail-user=psando@umd.edu
#--SBATCH --dependency=afterok:

set -x

export WORK_DIR="/scratch0/slurm_${SLURM_JOBID}"
export SCRIPT_DIR="/cfarhomes/psando/Documents/Unlearnable-Examples"
export CKPT_DIR="/vulcanscratch/psando/cifar_model_ckpts"

# Set environment 
mkdir $WORK_DIR
python3 -m venv ${WORK_DIR}/tmp-env
source ${WORK_DIR}/tmp-env/bin/activate
pip3 install --upgrade pip
pip3 install torch==1.8.2+cu111 torchvision==0.9.2+cu111 -f https://download.pytorch.org/whl/lts/1.8/torch_lts.html
pip3 install -r ${SCRIPT_DIR}/requirements.txt

module add cuda/11.1.1
module add cudnn/v8.2.1

# Load Exp Settings
source exp_setting.sh


# Remove previous files
echo $exp_path

# export NUM_MODELS="20"
# export USE="0.01"
# export TRAIN_STEP="10"
# export EXPERIMENT_NAME="num_models=${NUM_MODELS}_userr=${USE}_ts=${TRAIN_STEP}"

# Search Universal Perturbation and build datasets
cd ../../../../
pwd
rm -rf $exp_name

declare -a LIST_NUM_MODELS=('3' '5')
declare -a LIST_USE=('0.1' '0.5')
declare -a LIST_TRAIN_STEP=('10')
for USE in ${LIST_USE[@]}; do
    for TRAIN_STEP in ${LIST_TRAIN_STEP[@]}; do
        for NUM_MODELS in ${LIST_NUM_MODELS[@]}; do
            export EXPERIMENT_NAME="classwise_nm=${NUM_MODELS}_use=${USE}_ts=${TRAIN_STEP}"
            python3 perturbation.py --config_path             $config_path       \
                        --exp_name                /vulcanscratch/psando/untrainable_datasets/paper/unlearnable-tests/${EXPERIMENT_NAME}_id_${SLURM_JOBID} \
                        --version                 $base_version      \
                        --train_data_type         $dataset_type      \
                        --noise_shape             10 3 32 32         \
                        --epsilon                 $epsilon           \
                        --num_steps               $num_steps         \
                        --step_size               $step_size         \
                        --attack_type             $attack_type       \
                        --perturb_type            $perturb_type      \
                        --universal_train_target  $universal_train_target\
                        --universal_stop_error    ${USE}             \
                        --use_subset               \
                        --train_step ${TRAIN_STEP} \
                        --num_models ${NUM_MODELS} \
                        --disable_tqdm
        done
    done
done


