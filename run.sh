#!/bin/bash

inputfile1=$(readlink -f $1)
inputfile2=$(readlink -f $2)
cd $(dirname $(readlink -f $0))

set -e
source /opt/anaconda/bin/activate root
condaenv="dagan"
conda env list | grep $condaenv &>/dev/null
if [[ $? -ne 0 ]]; then
    needssetup=1
    conda create --name dagan python=3.8
fi
conda activate $condaenv

if [[ "$needssetup" -eq 1 ]]; then
    mkdir -p checkpoints
    pip3 install torch torchvision torchaudio
    pip install numpy
    pip install imageio-ffmpeg
    pip install -r requirements.txt
    cd face-alignment
    python setup.py install
fi
run()
{
    CUDA_VISIBLE_DEVICES=0 python demo.py --config config/vox-adv-256.yaml \
        --driving_video $2 \
        --source_image $1 \
        --checkpoint ./checkpoints/SPADE_DaGAN_vox_adv_256.pth.tar \
        --relative --adapt_scale --kp_num 15 \
        --generator SPADEDepthAwareGenerator \
        --find_best_frame \
        --result_video $1_dagan_$(date +%s).mp4
}
if [[ -z "$inputfile1" ]]; then
    echo run this script with run.sh image.png video.mp4
fi

if [[ -z "$inputfile2" ]]; then
    echo run this script with run.sh image.png video.mp4
fi

run "$inputfile1" "$inputfile2"
