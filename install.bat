CALL "%~dp0micromamba.exe" create -n gaussian_splatting_hair_001 python==3.10.14 git==2.41.0 git-lfs==3.2.0 -c pytorch -c conda-forge -c defaults -c anaconda -c fvcore -c iopath -c bottler -c nvidia -r "%~dp0\" -y
@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
@CALL condabin\micromamba.bat activate gaussian_splatting_hair_001
@CALL set ROOT_DIR=%~dp0
@CALL set PROJECT_DIR=%ROOT_DIR%GaussianHaircut
@CALL set BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6\

@REM Upgrade pip
@CALL pip install --upgrade pip

@REM Clone the main repository
@CALL mkdir GaussianHaircut
@CALL git clone https://github.com/eth-ait/GaussianHaircut.git %PROJECT_DIR%
@CALL cd %PROJECT_DIR%

@REM Clone the external libraries
@CALL mkdir ext
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

@REM Install PyTorch and other dependencies
@CALL pip install torch==2.1.1+cu118 torchvision torchaudio torchdiffeq torchsde --index-url https://download.pytorch.org/whl/cu118 --no-cache-dir
@CALL pip install -r requirements.txt

@REM Download the Neural Haircut files
@CALL cd %PROJECT_DIR%/ext/NeuralHaircut
@CALL gdown --folder https://drive.google.com/drive/folders/1TCdJ0CKR3Q6LviovndOkJaKm8S1T9F_8
@CALL cd %PROJECT_DIR%/ext/NeuralHaircut/pretrained_models/diffusion_prior # downloads updated diffusion prior
@CALL gdown 1_9EOUXHayKiGH5nkrayncln3d6m1uV7f
@CALL cd %PROJECT_DIR%/ext/NeuralHaircut/PIXIE
@CALL gdown 1mPcGu62YPc4MdkT8FFiOCP629xsENHZf && tar -xvzf pixie_data.tar.gz && rm pixie_data.tar.gz
@CALL cd %PROJECT_DIR%/ext/hyperIQA && mkdir pretrained && cd pretrained
@CALL gdown 1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE
@CALL cd %ROOT_DIR%

@REM Matte-Anything
@CALL "%~dp0micromamba.exe" create -n matte_anything_001 pytorch=2.0.0 pytorch-cuda=11.8 torchvision tensorboard timm=0.5.4 opencv=4.5.3 mkl=2024.0 setuptools=58.2.0 easydict wget scikit-image gradio=3.46.1 fairscale -c pytorch -c nvidia -c conda-forge -r "%~dp0\" -y
@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
@CALL condabin\micromamba.bat deactivate && condabin\micromamba.bat activate matte_anything_001
@CALL set ROOT_DIR=%~dp0
@CALL set PROJECT_DIR=%ROOT_DIR%GaussianHaircut
@CALL set BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6\
@CALL pip install git+https://github.com/facebookresearch/segment-anything.git
@CALL python -m pip install 'git+https://github.com/facebookresearch/detectron2.git'
@CALL cd %PROJECT_DIR%/ext/Matte-Anything/GroundingDINO && pip install -e .
@CALL pip install supervision==0.22.0
@CALL cd %PROJECT_DIR%/ext/Matte-Anything && mkdir pretrained
@CALL cd %PROJECT_DIR%/ext/Matte-Anything/pretrained
@CALL curl -L -o sam_vit_h_4b8939.pth https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth
@CALL curl -L -o groundingdino_swint_ogc.pth https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth
@CALL condabin\micromamba.bat deactivate && condabin\micromamba.bat activate gaussian_splatting_hair_001
@CALL gdown 1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW

@REM OpenPose
@CALL cd %PROJECT_DIR%/ext/openpose
@CALL gdown 1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV && tar -xvzf models.tar.gz && rm models.tar.gz
@CALL condabin\micromamba.bat deactivate
@CALL git submodule update --init --recursive --remote
@CALL condabin\micromamba.bat create -y -n openpose cmake=3.20 -c conda-forge
@CALL condabin\micromamba.bat activate openpose
@REM Create build directory and run CMake
@CALL mkdir build
@CALL cd build
@CALL cmake .. -G "Visual Studio 16 2019" -A x64 ^
    -DBUILD_PYTHON=true ^
    -DUSE_CUDNN=off ^
    -DCMAKE_INSTALL_PREFIX="%PROJECT_DIR%/ext/openpose/install"

@REM Build the project using MSBuild
@CALL cmake --build . --config Release
@CALL condabin\micromamba.bat deactivate

@REM PIXIE
@CALL cd %PROJECT_DIR%/ext && git clone https://github.com/yfeng95/PIXIE
@CALL cd %PROJECT_DIR%/ext/PIXIE
@CALL chmod +x fetch_model.sh && ./fetch_model.sh
@CALL "%~dp0micromamba.exe" create -n pixie-env python=3.8 pytorch==2.0.0 torchvision==0.15.0 torchaudio==2.0.0 pytorch-cuda=11.8 fvcore pytorch3d==0.7.5 kornia matplotlib -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -r "%~dp0\" -y
@CALL condabin\micromamba.bat activate pixie-env
@CALL pip install pyyaml==5.4.1
@CALL pip install git+https://github.com/1adrianb/face-alignment.git@54623537fd9618ca7c15688fd85aba706ad92b59
@CALL PAUSE
