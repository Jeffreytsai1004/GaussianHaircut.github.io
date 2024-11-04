@ECHO OFF
SETLOCAL EnableDelayedExpansion

@REM SET VARIABLES
SET ROOT_DIR=%~dp0
SET ROOT_DIR=%ROOT_DIR:~0,-1%
SET micromamba=%ROOT_DIR%\micromamba.exe

@REM CREATE BASE ENVIRONMENT
@CALL %micromamba% create -n gaussianhaircut_base python==3.10.14 git==2.41.0 git-lfs==3.2.0 -c conda-forge -r "%ROOT_DIR%" -y || (@ECHO Error: Failed to create base environment && EXIT /B 1)
@CALL "%micromamba%" shell init --shell cmd.exe --prefix "%ROOT_DIR%"
@CALL %micromamba% activate gaussianhaircut_base
@CALL SET PROJECT_DIR=%ROOT_DIR%\GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
@CALL git clone https://github.com/eth-ait/GaussianHaircut %PROJECT_DIR%
@CALL git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose %PROJECT_DIR%\ext\openpose --depth 1 && cd %PROJECT_DIR%\ext\openpose && git submodule update --init --recursive --remote && cd %PROJECT_DIR%
@CALL git clone https://github.com/hustvl/Matte-Anything %PROJECT_DIR%\ext\Matte-Anything
@CALL git clone https://github.com/IDEA-Research/GroundingDINO.git %PROJECT_DIR%\ext\Matte-Anything\GroundingDINO
@CALL git clone git@github.com:egorzakharov/NeuralHaircut.git --recursive %PROJECT_DIR%\ext\NeuralHaircut
@CALL git clone https://github.com/facebookresearch/pytorch3d %PROJECT_DIR%\ext\pytorch3d && cd %PROJECT_DIR%\ext\pytorch3d && git checkout 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7 && cd %PROJECT_DIR%
@CALL git clone https://github.com/camenduru/simple-knn %PROJECT_DIR%\ext\simple-knn
@CALL git clone https://github.com/g-truc/glm %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm && cd %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm && git checkout 5c46b9c07008ae65cb81ab79cd677ecc1934b903 && cd %PROJECT_DIR%
@CALL git clone --recursive https://github.com/NVIDIAGameWorks/kaolin %PROJECT_DIR%\ext\kaolin && cd %PROJECT_DIR%\ext\kaolin && git checkout v0.15.0 && cd %PROJECT_DIR%
@CALL git clone https://github.com/SSL92/hyperIQA %PROJECT_DIR%\ext\hyperIQA
@CALL git clone https://github.com/facebookresearch/segment-anything.git %PROJECT_DIR%\ext\segment-anything
@CALL git clone https://github.com/facebookresearch/detectron2.git %PROJECT_DIR%\ext\detectron2
@CALL git clone https://github.com/yfeng95/PIXIE %PROJECT_DIR%\ext\PIXIE
@CALL git clone https://github.com/1adrianb/face-alignment.git@54623537fd9618ca7c15688fd85aba706ad92b59 %PROJECT_DIR%\ext\face-alignment
@CALL curl -L "https://drive.usercontent.google.com/download?id=1OBR0Vzb_w5SNc1jmoScA6L8SqVniJGOr" -o %PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\diffusion_prior\dif_ckpt.pth
@CALL curl -L "https://drive.usercontent.google.com/download?id=1DESwUb-nsmi38VCDvnBwpd9kjcWONNT6" -o %PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\strand_prior\strand_ckpt.pth
@CALL curl -L "https://drive.google.com/uc?export=download&id=1mPcGu62YPc4MdkT8FFiOCP629xsENHZf" -o %PROJECT_DIR%\ext\NeuralHaircut\PIXIE\pixie_data.tar.gz && 7z x %PROJECT_DIR%\ext\NeuralHaircut\PIXIE\pixie_data.tar.gz -o%PROJECT_DIR%\ext\NeuralHaircut\PIXIE\ && del %PROJECT_DIR%\ext\NeuralHaircut\PIXIE\pixie_data.tar.gz
@CALL curl -L "https://drive.google.com/uc?export=download&id=1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE" -o %PROJECT_DIR%\ext\hyperIQA\pretrained\koniq_pretrained.pkl
@CALL curl -L "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth" -o %MATTE_ANYTHING_DIR%\pretrained\sam_vit_h_4b8939.pth
@CALL curl -L "https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth" -o %MATTE_ANYTHING_DIR%\pretrained\groundingdino_swint_ogc.pth
@CALL curl -L "https://drive.usercontent.google.com/download?id=1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW" -o %MATTE_ANYTHING_DIR%\pretrained\ViTMatte_B_DIS.pth
@CALL curl -L "https://drive.usercontent.google.com/download?id=1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV" -o %OPENPOSE_DIR%\models.tar.gz && 7z x %OPENPOSE_DIR%\models.tar.gz -o%OPENPOSE_DIR%\ && del %OPENPOSE_DIR%\models.tar.gz
@CALL %micromamba% deactivate

@REM GAUSSIAN SPLATTING HAIR
@CALL %micromamba% create -n gaussian_splatting_hair python==3.10.14 git==2.41.0 git-lfs==3.2.0 -c pytorch -c conda-forge -c defaults -c anaconda -c fvcore -c iopath -c bottler -c nvidia -r "%ROOT_DIR%" -y || (@ECHO Error: Failed to create gaussian_splatting_hair environment && EXIT /B 1)
@CALL %micromamba% activate gaussian_splatting_hair
@CALL SET PROJECT_DIR=%ROOT_DIR%\GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
@CALL pip install torch==2.2.0+cu118 torchvision torchaudio torchdiffeq torchsde --index-url https://download.pytorch.org/whl/cu118 --no-cache-dir
@CALL pip install -r %ROOT_DIR%\requirements.txt
@CALL pip install -e %PROJECT_DIR%\ext\pytorch3d
@CALL pip install -e %PROJECT_DIR%\ext\NeuralHaircut\npbgpp
@CALL pip install -e %PROJECT_DIR%\ext\simple-knn
@CALL pip install -e %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair
@CALL pip install -e %PROJECT_DIR%\ext\kaolin
@CALL %micromamba% deactivate

@REM MATTE ANYTHING
@CALL %micromamba% create -n matte_anything python==3.10.14 git==2.41.0 git-lfs==3.2.0 pytorch==2.0.0 pytorch-cuda==11.8 torchvision==0.15.1 tensorboard==2.15.0 timm==0.5.4 opencv==4.5.3 mkl==2024.0 setuptools==58.2.0 easydict wget scikit-image gradio==3.46.1 fairscale supervision==0.22.0 -c pytorch -c nvidia -c conda-forge -r "%~dp0\" -y || (@ECHO Error: Failed to create matte_anything environment && EXIT /B 1)
@CALL %micromamba% activate matte_anything
@CALL SET PROJECT_DIR=%ROOT_DIR%\GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
@CALL pip install -e %PROJECT_DIR%\ext\segment-anything
@IF %ERRORLEVEL% NEQ 0 (
    @ECHO Error: Failed to install segment-anything
    @EXIT /B 1
)
@CALL pip install -e %PROJECT_DIR%\ext\detectron2
@IF %ERRORLEVEL% NEQ 0 (
    @ECHO Error: Failed to install detectron2
    @EXIT /B 1
)
@CALL pip install -e %PROJECT_DIR%\ext\Matte-Anything\GroundingDINO
@IF %ERRORLEVEL% NEQ 0 (
    @ECHO Error: Failed to install GroundingDINO
    @EXIT /B 1
)
@CALL %micromamba% deactivate

@REM OPENPOSE
@CALL %micromamba% create -n openpose python==3.10.14 git==2.41.0 git-lfs==3.2.0 cmake=3.20 opencv-python protobuf glog boost h5py numpy make -c conda-forge -r "%ROOT_DIR%" -y || (@ECHO Error: Failed to create openpose environment && EXIT /B 1)
@CALL %micromamba% activate openpose
@CALL git submodule update --init --recursive --remote
@CALL SET PROJECT_DIR=%ROOT_DIR%\GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
@IF NOT EXIST %OPENPOSE_DIR%\build 
@CALL mkdir %OPENPOSE_DIR%\build
@CALL cd %OPENPOSE_DIR%\build
@CALL cmake %OPENPOSE_DIR% -DBUILD_PYTHON=true -DUSE_CUDNN=off -DCMAKE_INSTALL_PREFIX="%CD%/install" -DCUDA_TOOLKIT_ROOT_DIR="C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/11.8" || (@ECHO Error: CMake configuration failed && EXIT /B 1)
@CALL cmake --build . --config Release || (@ECHO Error: Build failed && EXIT /B 1)
@CALL cd %ROOT_DIR%
@CALL %micromamba% deactivate

@REM PIXIE
@CALL %micromamba% create -n pixie-env python=3.8 pytorch==2.0.0 torchvision==0.15.0 torchaudio==2.0.0 pytorch-cuda=11.8 fvcore pytorch3d==0.7.5 kornia matplotlib -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -r "%ROOT_DIR%" -y || (@ECHO Error: Failed to create pixie-env && EXIT /B 1)
@CALL SET PROJECT_DIR=%ROOT_DIR%\GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
@CALL %micromamba% activate pixie-env
@CALL pip install pyyaml==5.4.1
@CALL pip install -e %PROJECT_DIR%\ext\face-alignment || (@ECHO Error: Failed to install face-alignment && EXIT /B 1)
@CALL %micromamba% deactivate

@ECHO All installations completed successfully.
