@ECHO OFF
SETLOCAL EnableDelayedExpansion

@REM 设置当前目录为环境根目录
SET "ROOT_DIR=%~dp0"
SET "MAMBA_ROOT_PREFIX=%ROOT_DIR%mamba"

@REM 创建必要的目录
IF NOT EXIST "%ROOT_DIR%env" mkdir "%ROOT_DIR%env"
IF NOT EXIST "%MAMBA_ROOT_PREFIX%" mkdir "%MAMBA_ROOT_PREFIX%"

@REM 创建环境（移除引号，简化路径）
@CALL %ROOT_DIR%micromamba.exe create -p %ROOT_DIR%env -c pytorch -c nvidia -c conda-forge -y ^
    python=3.9 ^
    pytorch=2.1.1 ^
    torchvision=0.16.1 ^
    pytorch-cuda=11.8 ^
    cmake=3.28.0

@REM 初始化shell（修复路径问题）
@CALL %ROOT_DIR%micromamba.exe shell init --shell cmd.exe --prefix %ROOT_DIR%

@REM 激活环境
@CALL %ROOT_DIR%condabin\micromamba.bat activate %ROOT_DIR%env

@REM 安装基本依赖（移除版本固定）
@CALL pip install -r requirements.txt --no-cache-dir
@CALL pip install gdown --no-cache-dir

@REM 设置项目目录
@CALL SET PROJECT_DIR=%~dp0
@CALL mkdir %PROJECT_DIR%ext 2>NUL

@REM 克隆所有外部库
@CALL cd %PROJECT_DIR%ext
@CALL git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose --depth 1
@CALL cd openpose && git submodule update --init --recursive --remote

@CALL cd %PROJECT_DIR%ext
@CALL git clone https://github.com/hustvl/Matte-Anything
@CALL cd Matte-Anything && git clone https://github.com/IDEA-Research/GroundingDINO.git

@CALL cd %PROJECT_DIR%ext
@CALL git clone https://github.com/egorzakharov/NeuralHaircut.git --recursive

@CALL cd %PROJECT_DIR%ext
@CALL git clone https://github.com/facebookresearch/pytorch3d
@CALL cd pytorch3d && git checkout 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7

@CALL cd %PROJECT_DIR%ext
@CALL git clone https://github.com/camenduru/simple-knn

@CALL cd %PROJECT_DIR%ext\diff_gaussian_rasterization_hair\third_party
@CALL git clone https://github.com/g-truc/glm
@CALL cd glm && git checkout 5c46b9c07008ae65cb81ab79cd677ecc1934b903

@CALL cd %PROJECT_DIR%ext
@CALL git clone --recursive https://github.com/NVIDIAGameWorks/kaolin
@CALL cd kaolin && git checkout v0.15.0

@CALL cd %PROJECT_DIR%ext
@CALL git clone https://github.com/SSL92/hyperIQA

@REM 下载模型文件
@CALL cd %PROJECT_DIR%ext\NeuralHaircut
@CALL gdown --folder https://drive.google.com/drive/folders/1TCdJ0CKR3Q6LviovndOkJaKm8S1T9F_8

@CALL cd %PROJECT_DIR%ext\NeuralHaircut\pretrained_models\diffusion_prior
@CALL gdown 1_9EOUXHayKiGH5nkrayncln3d6m1uV7f

@CALL cd %PROJECT_DIR%ext\NeuralHaircut\PIXIE
@CALL gdown 1mPcGu62YPc4MdkT8FFiOCP629xsENHZf
@CALL tar -xf pixie_data.tar.gz
@CALL del pixie_data.tar.gz

@CALL cd %PROJECT_DIR%ext\hyperIQA 
@CALL mkdir pretrained && cd pretrained
@CALL gdown 1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE

@REM 创建 Matte-Anything 环境
@CALL "%ROOT_DIR%micromamba.exe" create -p %ROOT_DIR%\env python=3.9 pytorch=2.0.0 torchvision tensorboard timm=0.5.4 opencv=4.5.3 mkl=2024.0 setuptools=58.2.0 easydict wget scikit-image gradio=3.46.1 fairscale -c pytorch -c nvidia -c conda-forge -y
@CALL condabin\micromamba.bat activate %ROOT_DIR%\env
@CALL pip install git+https://github.com/facebookresearch/segment-anything.git
@CALL pip install git+https://github.com/facebookresearch/detectron2.git
@CALL cd %PROJECT_DIR%ext\Matte-Anything\GroundingDINO && pip install -e .
@CALL pip install supervision==0.22.0

@REM 下载预训练模型
@CALL cd %PROJECT_DIR%ext\Matte-Anything
@CALL mkdir pretrained
@CALL cd pretrained
@CALL curl -L -o sam_vit_h_4b8939.pth https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth
@CALL curl -L -o groundingdino_swint_ogc.pth https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth
@CALL cd %PROJECT_DIR%ext\Matte-Anything
@CALL gdown 1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW

@REM 创建 OpenPose 环境并编译
@CALL "%ROOT_DIR%micromamba.exe" create -p %ROOT_DIR%\env cmake=3.20 -c conda-forge -y
@CALL condabin\micromamba.bat activate %ROOT_DIR%\env
@CALL cd %PROJECT_DIR%ext\openpose
@CALL gdown 1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV 
@CALL tar -xf models.tar.gz
@CALL del models.tar.gz
@CALL mkdir build
@CALL cd build
@CALL cmake .. -DBUILD_PYTHON=true -DUSE_CUDNN=off
@CALL cmake --build . --config Release

@REM 创建 PIXIE 环境
@CALL "%ROOT_DIR%micromamba.exe" create -p %ROOT_DIR%\env python=3.8 pytorch=2.0.0 torchvision=0.15.0 pytorch-cuda=11.8 fvcore pytorch3d==0.7.5 kornia matplotlib -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -y
@CALL condabin\micromamba.bat activate %ROOT_DIR%\env
@CALL pip install pyyaml==5.4.1
@CALL pip install git+https://github.com/1adrianb/face-alignment.git@54623537fd9618ca7c15688fd85aba706ad92b59

@REM 编译CUDA扩展
@CALL cd %PROJECT_DIR%
@CALL python setup.py build_ext --inplace

@ECHO Installation completed!
@PAUSE


