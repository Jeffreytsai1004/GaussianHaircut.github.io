@ECHO OFF
@REM SET BASE PATHS
SET "ROOT_DIR=%~dp0"
SET "ROOT_DIR=%ROOT_DIR:~0,-1%"
SET "micromamba=%ROOT_DIR%\micromamba.exe"
SET "MAMBABAT=%ROOT_DIR%\condabin\micromamba.bat"

@REM CREATE BASE ENVIRONMENT
@CALL "%~dp0micromamba.exe" create -n gaussianhaircut_base python==3.10.14 git==2.41.0 git-lfs==3.2.0 -c conda-forge -r "%~dp0\" -y
@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
@CALL "%~dp0condabin\micromamba.bat" activate gaussianhaircut_base
@CALL SET ROOT_DIR=%~dp0
@CALL SET "ROOT_DIR=%ROOT_DIR:~0,-1%"
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
@CALL git clone https://github.com/egorzakharov/NeuralHaircut.git --recursive %PROJECT_DIR%\ext\NeuralHaircut
@CALL git clone https://github.com/facebookresearch/pytorch3d %PROJECT_DIR%\ext\pytorch3d && cd %PROJECT_DIR%\ext\pytorch3d && git checkout 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7 && cd %PROJECT_DIR%
@CALL git clone https://github.com/camenduru/simple-knn %PROJECT_DIR%\ext\simple-knn
@CALL git clone https://github.com/g-truc/glm %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm && cd %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm && git checkout 5c46b9c07008ae65cb81ab79cd677ecc1934b903 && cd %PROJECT_DIR%
@CALL git clone --recursive https://github.com/NVIDIAGameWorks/kaolin %PROJECT_DIR%\ext\kaolin && cd %PROJECT_DIR%\ext\kaolin && git checkout v0.15.0 && cd %PROJECT_DIR%
@CALL git clone https://github.com/SSL92/hyperIQA %PROJECT_DIR%\ext\hyperIQA
@CALL git clone https://github.com/facebookresearch/segment-anything.git %PROJECT_DIR%\ext\segment-anything
@CALL git clone https://github.com/facebookresearch/detectron2.git %PROJECT_DIR%\ext\detectron2
@CALL git clone https://github.com/yfeng95/PIXIE %PROJECT_DIR%\ext\PIXIE
@CALL git clone https://github.com/1adrianb/face-alignment.git %PROJECT_DIR%\ext\face-alignment
@REM @CALL cd %PROJECT_DIR%\ext\face-alignment && git checkout 54623537fd9618ca7c15688fd85aba706ad92b59
@REM @IF %ERRORLEVEL% NEQ 0 (
@REM     @ECHO face-alignment 安装失败
@REM     @PAUSE
@REM     exit /b %ERRORLEVEL%
@REM )
@CALL curl -L "https://drive.usercontent.google.com/download?id=1OBR0Vzb_w5SNc1jmoScA6L8SqVniJGOr" -o %PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\diffusion_prior\dif_ckpt.pth
@CALL curl -L "https://drive.usercontent.google.com/download?id=1DESwUb-nsmi38VCDvnBwpd9kjcWONNT6" -o %PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\strand_prior\strand_ckpt.pth
@CALL curl -L "https://drive.google.com/uc?export=download&id=1mPcGu62YPc4MdkT8FFiOCP629xsENHZf" -o %PROJECT_DIR%\ext\NeuralHaircut\PIXIE\pixie_data.tar.gz && 7z x %PROJECT_DIR%\ext\NeuralHaircut\PIXIE\pixie_data.tar.gz -o%PROJECT_DIR%\ext\NeuralHaircut\PIXIE\ && del %PROJECT_DIR%\ext\NeuralHaircut\PIXIE\pixie_data.tar.gz
@CALL curl -L "https://drive.google.com/uc?export=download&id=1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE" -o %PROJECT_DIR%\ext\hyperIQA\pretrained\koniq_pretrained.pkl
@CALL curl -L "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth" -o %MATTE_ANYTHING_DIR%\pretrained\sam_vit_h_4b8939.pth
@CALL curl -L "https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth" -o %MATTE_ANYTHING_DIR%\pretrained\groundingdino_swint_ogc.pth
@CALL curl -L "https://drive.usercontent.google.com/download?id=1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW" -o %MATTE_ANYTHING_DIR%\pretrained\ViTMatte_B_DIS.pth
@CALL curl -L "https://drive.usercontent.google.com/download?id=1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV" -o %OPENPOSE_DIR%\models.tar.gz && 7z x %OPENPOSE_DIR%\models.tar.gz -o%OPENPOSE_DIR%\ && del %OPENPOSE_DIR%\models.tar.gz
@CALL cd %ROOT_DIR%
@CALL %micromamba% deactivate

@REM GAUSSIAN SPLATTING HAIR
@CALL "%~dp0micromamba.exe" create -n gaussian_splatting_hair python==3.10.14 git==2.41.0 git-lfs==3.2.0 -c pytorch -c conda-forge -c defaults -c anaconda -c fvcore -c iopath -c bottler -c nvidia -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate gaussian_splatting_hair
@CALL SET ROOT_DIR=%~dp0
@CALL SET "ROOT_DIR=%ROOT_DIR:~0,-1%"
@CALL SET PROJECT_DIR=%ROOT_DIR%\GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
@CALL pip install --force-reinstall torch==2.2.0+cu121 torchvision==0.17.0+cu121 torchaudio==2.2.0+cu121 --index-url https://download.pytorch.org/whl/cu121 --no-cache-dir
@CALL pip install torchdiffeq torchsde
@CALL pip install -r %ROOT_DIR%\requirements.txt
@ECHO 开始安装 pytorch3d...
@CALL cd %PROJECT_DIR%\ext\pytorch3d && pip install -e .
@IF %ERRORLEVEL% NEQ 0 (
    @ECHO pytorch3d 安装失败
    @PAUSE
    exit /b %ERRORLEVEL%
)
@ECHO 开始安装 npbgpp...
@CALL cd %PROJECT_DIR%\ext\NeuralHaircut\npbgpp && pip install -e .
@IF %ERRORLEVEL% NEQ 0 (
    @ECHO npbgpp 安装失败
    @PAUSE
    exit /b %ERRORLEVEL%
)
@ECHO 开始安装 simple-knn...
@CALL cd %PROJECT_DIR%\ext\simple-knn && pip install -e .
@IF %ERRORLEVEL% NEQ 0 (
    @ECHO simple-knn 安装失败
    @PAUSE
    exit /b %ERRORLEVEL%
)
@ECHO 开始安装 diff_gaussian_rasterization_hair...
@CALL cd %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair && pip install -e .
@IF %ERRORLEVEL% NEQ 0 (
    @ECHO diff_gaussian_rasterization_hair 安装失败
    @PAUSE
    exit /b %ERRORLEVEL%
)
@ECHO 开始安装 kaolin...
@CALL pip install -e %PROJECT_DIR%\ext\kaolin
@IF %ERRORLEVEL% NEQ 0 (
    @ECHO kaolin 安装失败
    @PAUSE
    exit /b %ERRORLEVEL%
)
@CALL cd %ROOT_DIR%
@CALL %micromamba% deactivate

@REM MATTE ANYTHING
@CALL "%~dp0micromamba.exe" create -n matte_anything python==3.10.14 git==2.41.0 git-lfs==3.2.0 pytorch==2.0.0 pytorch-cuda==11.8 torchvision==0.15.1 tensorboard==2.15.0 timm==0.5.4 opencv==4.5.3 mkl==2024.0 setuptools==58.2.0 easydict wget scikit-image gradio==3.46.1 fairscale supervision==0.22.0 -c pytorch -c nvidia -c conda-forge -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate matte_anything
@CALL SET ROOT_DIR=%~dp0
@CALL SET "ROOT_DIR=%ROOT_DIR:~0,-1%"
@CALL SET PROJECT_DIR=%ROOT_DIR%\GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
@CALL pip install -e %PROJECT_DIR%\ext\segment-anything
@CALL pip install -e %PROJECT_DIR%\ext\detectron2
@CALL pip install -e %PROJECT_DIR%\ext\Matte-Anything\GroundingDINO
@CALL %micromamba% deactivate

@REM OPENPOSE
@CALL "%~dp0micromamba.exe" create -n openpose python==3.10.14 git==2.41.0 git-lfs==3.2.0 cmake=3.20 opencv-python protobuf glog boost h5py numpy make -c conda-forge -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate openpose
@CALL git submodule update --init --recursive --remote
@CALL SET ROOT_DIR=%~dp0
@CALL SET "ROOT_DIR=%ROOT_DIR:~0,-1%"
@CALL SET PROJECT_DIR=%ROOT_DIR%\GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
@IF NOT EXIST %OPENPOSE_DIR%\build 
@CALL mkdir %OPENPOSE_DIR%\build
@CALL cd %OPENPOSE_DIR%\build
@CALL cmake %OPENPOSE_DIR% -DBUILD_PYTHON=true -DUSE_CUDNN=off -DCMAKE_INSTALL_PREFIX="%CD%/install" -DCUDA_TOOLKIT_ROOT_DIR="C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/11.8"
@CALL cmake --build . --config Release
@CALL cd %ROOT_DIR%
@CALL %micromamba% deactivate

@REM PIXIE
@CALL "%~dp0micromamba.exe" create -n pixie-env python=3.8 pytorch==2.0.0 torchvision==0.15.0 torchaudio==2.0.0 pytorch-cuda=11.8 fvcore pytorch3d==0.7.5 kornia matplotlib -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -r "%~dp0\" -y
@CALL "%~dp0condabin\micromamba.bat" activate pixie-env
@CALL SET ROOT_DIR=%~dp0
@CALL SET "ROOT_DIR=%ROOT_DIR:~0,-1%"
@CALL SET PROJECT_DIR=%ROOT_DIR%\GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
@CALL %micromamba% activate pixie-env
@CALL pip install pyyaml==5.4.1
@CALL cd %PROJECT_DIR%\ext\face-alignment && pip install -e .
@CALL cd %ROOT_DIR%
@CALL %micromamba% deactivate

@ECHO All installations completed successfully.

@ECHO PAUSE