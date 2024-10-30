@REM # 安装环境
@CALL "%~dp0micromamba.exe" create -f "%~dp0environment.yml" -y
@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
@CALL condabin\micromamba.bat activate venv_gaussianhaircut

@REM # 设置项目目录
@CALL set PROJECT_DIR=%~dp0
@CALL mkdir %PROJECT_DIR%ext

@REM # 拉取所有外部库
@CALL cd %PROJECT_DIR%/ext && git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose --depth 1
@CALL cd %PROJECT_DIR%/ext/openpose && git submodule update --init --recursive --remote
@CALL cd %PROJECT_DIR%/ext && git clone https://github.com/hustvl/Matte-Anything
@CALL cd %PROJECT_DIR%/ext/Matte-Anything && git clone https://github.com/IDEA-Research/GroundingDINO.git
@CALL cd %PROJECT_DIR%/ext && git clone git@github.com:egorzakharov/NeuralHaircut.git --recursive
@CALL cd %PROJECT_DIR%/ext && git clone https://github.com/facebookresearch/pytorch3d
@CALL cd %PROJECT_DIR%/ext/pytorch3d && git checkout 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7
@CALL cd %PROJECT_DIR%/ext && git clone https://github.com/camenduru/simple-knn
@CALL cd %PROJECT_DIR%/ext/diff_gaussian_rasterization_hair/third_party && git clone https://github.com/g-truc/glm
@CALL cd %PROJECT_DIR%/ext/diff_gaussian_rasterization_hair/third_party/glm && git checkout 5c46b9c07008ae65cb81ab79cd677ecc1934b903
@CALL cd %PROJECT_DIR%/ext && git clone --recursive https://github.com/NVIDIAGameWorks/kaolin
@CALL cd %PROJECT_DIR%/ext/kaolin && git checkout v0.15.0
@CALL cd %PROJECT_DIR%/ext && git clone https://github.com/SSL92/hyperIQA

@REM # 下载 Neural Haircut 文件
@CALL cd %PROJECT_DIR%\ext\NeuralHaircut
@CALL gdown --folder https://drive.google.com/drive/folders/1TCdJ0CKR3Q6LviovndOkJaKm8S1T9F_8
@CALL cd %PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\diffusion_prior
@CALL gdown 1_9EOUXHayKiGH5nkrayncln3d6m1uV7f
@CALL cd %PROJECT_DIR%\ext\NeuralHaircut\PIXIE
@CALL gdown 1mPcGu62YPc4MdkT8FFiOCP629xsENHZf && tar -xvzf pixie_data.tar.gz && del pixie_data.tar.gz
@CALL cd %PROJECT_DIR%\ext\hyperIQA && mkdir pretrained && cd pretrained
@CALL gdown 1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE
@CALL cd %PROJECT_DIR%

@REM # Matte-Anything
@CALL conda create -y -n matte_anything pytorch=2.0.0 pytorch-cuda=11.8 torchvision tensorboard timm=0.5.4 opencv=4.5.3 mkl=2024.0 setuptools=58.2.0 easydict wget scikit-image gradio=3.46.1 fairscale -c pytorch -c nvidia -c conda-forge 
@CALL conda activate matte_anything
@CALL pip install git+https://github.com/facebookresearch/segment-anything.git
@CALL python -m pip install 'git+https://github.com/facebookresearch/detectron2.git'
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\GroundingDINO && pip install -e .
@CALL pip install supervision==0.22.0
@CALL cd %PROJECT_DIR%\ext\Matte-Anything && mkdir pretrained
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\pretrained
@CALL curl -L -o sam_vit_h_4b8939.pth https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth
@CALL curl -L -o groundingdino_swint_ogc.pth https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth
@CALL conda deactivate && conda activate gaussian_splatting_hair
@CALL curl 1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW

@REM # OpenPose
@CALL cd %PROJECT_DIR%/ext/openpose
@CALL git clone --recursive https://github.com/CMU-Perceptual-Computing-Lab/openpose.git
@CALL cd openpose
@CALL git submodule update --init --recursive
@CALL curl 1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV
@CALL tar -xvzf models.tar.gz
@CALL rm models.tar.gz
@CALL conda create -y -n openpose python=3.8
@CALL conda activate openpose
@CALL conda install -c conda-forge opencv
@CALL conda install -c conda-forge numpy

@REM # PIXIE
@CALL cd %PROJECT_DIR%/ext && git clone https://github.com/yfeng95/PIXIE
@CALL cd %PROJECT_DIR%/ext/PIXIE
@CALL chmod +x fetch_model.sh && ./fetch_model.sh
@CALL conda create -y -n pixie-env python=3.8 pytorch==2.0.0 torchvision==0.15.0 torchaudio==2.0.0 \
    pytorch-cuda=11.8 fvcore pytorch3d==0.7.5 kornia matplotlib \
    -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d 
@CALL pip install pyyaml==5.4.1
@CALL conda activate pixie-env
@CALL pip install git+https://github.com/1adrianb/face-alignment.git@54623537fd9618ca7c15688fd85aba706ad92b59 
@REM # 安装此提交以避免错误


