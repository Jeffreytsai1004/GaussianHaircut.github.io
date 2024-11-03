@ECHO ON
@CALL "%~dp0micromamba.exe" create -n gaussian_splatting_hair_001 python==3.10.14 git==2.41.0 git-lfs==3.2.0 -c pytorch -c conda-forge -c defaults -c anaconda -c fvcore -c iopath -c bottler -c nvidia -r "%~dp0\" -y
@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
@CALL condabin\micromamba.bat activate gaussian_splatting_hair_001
@CALL SET ROOT_DIR=%~dp0
@CALL SET PROJECT_DIR=%ROOT_DIR%GaussianHaircut
@CALL SET BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6\

@REM Upgrade pip
@CALL pip install --upgrade pip

@REM Clone the main repository
@CALL mkdir GaussianHaircut
@CALL git clone https://github.com/eth-ait/GaussianHaircut.git %PROJECT_DIR%
@CALL cd "%PROJECT_DIR%"

@REM Clone the external libraries
@CALL mkdir ext
@CALL cd "%PROJECT_DIR%/ext" && git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose --depth 1
@CALL cd "%PROJECT_DIR%/ext/openpose" && git submodule update --init --recursive --remote
@CALL cd "%PROJECT_DIR%/ext" && git clone https://github.com/hustvl/Matte-Anything
@CALL cd "%PROJECT_DIR%/ext/Matte-Anything" && git clone https://github.com/IDEA-Research/GroundingDINO.git
@CALL cd "%PROJECT_DIR%/ext" && git clone git@github.com:egorzakharov/NeuralHaircut.git --recursive
@CALL cd "%PROJECT_DIR%/ext" && git clone https://github.com/facebookresearch/pytorch3d
@CALL cd "%PROJECT_DIR%/ext/pytorch3d" && git checkout 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7
@CALL cd "%PROJECT_DIR%/ext" && git clone https://github.com/camenduru/simple-knn
@CALL cd "%PROJECT_DIR%/ext/diff_gaussian_rasterization_hair/third_party" && git clone https://github.com/g-truc/glm
@CALL cd "%PROJECT_DIR%/ext/diff_gaussian_rasterization_hair/third_party/glm" && git checkout 5c46b9c07008ae65cb81ab79cd677ecc1934b903
@CALL cd "%PROJECT_DIR%/ext" && git clone --recursive https://github.com/NVIDIAGameWorks/kaolin
@CALL cd "%PROJECT_DIR%/ext/kaolin" && git checkout v0.15.0
@CALL cd "%PROJECT_DIR%/ext" && git clone https://github.com/SSL92/hyperIQA

@REM Install PyTorch and other dependencies
@CALL pip install torch==2.1.1+cu118 torchvision torchaudio torchdiffeq torchsde --index-url https://download.pytorch.org/whl/cu118
@CALL pip install -r requirements.txt

@REM Download the Neural Haircut files
@CALL cd "%PROJECT_DIR%/ext/NeuralHaircut"
@CALL mkdir  "%PROJECT_DIR%/ext/NeuralHaircut/pretrained_models/diffusion_prior"
@CALL mkdir  "%PROJECT_DIR%/ext/NeuralHaircut/pretrained_models/strand_prior"
@CALL curl -L "https://drive.usercontent.google.com/download?id=1OBR0Vzb_w5SNc1jmoScA6L8SqVniJGOr&export=download&confirm=t&uuid=d7b372b3-a2c7-4204-9593-7f8042b63043" -o "%PROJECT_DIR%/ext/NeuralHaircut/pretrained_models/diffusion_prior/dif_ckpt.pth"
@CALL curl -L "https://drive.usercontent.google.com/download?id=1DESwUb-nsmi38VCDvnBwpd9kjcWONNT6&export=download&confirm=t&uuid=0c40d69e-ad77-4417-81a4-b99abf04f284" -o "%PROJECT_DIR%/ext/NeuralHaircut/pretrained_models/strand_prior/strand_ckpt.pth"
@CALL mkdir "%PROJECT_DIR%/ext/NeuralHaircut/pretrained_models/PIXIE"
@CALL curl -L "https://drive.google.com/uc?export=download&id=1mPcGu62YPc4MdkT8FFiOCP629xsENHZf" -o "%PROJECT_DIR%/ext/NeuralHaircut/pretrained_models/PIXIE/pixie_data.tar.gz"
@CALL cd "%PROJECT_DIR%/ext/NeuralHaircut/pretrained_models/PIXIE" && tar -xvzf pixie_data.tar.gz && rm pixie_data.tar.gz
@CALL mkdir "%PROJECT_DIR%/ext/hyperIQA/pretrained"
@CALL curl -L "https://drive.google.com/uc?export=download&id=1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE" -o "%PROJECT_DIR%/ext/hyperIQA/pretrained/koniq_pretrained.pkl"
@CALL cd "%ROOT_DIR%"
@CALL condabin\micromamba.bat deactivate

@REM Matte-Anything
@CALL "%~dp0micromamba.exe" create -n matte_anything_001 pytorch=2.0.0 pytorch-cuda=11.8 torchvision tensorboard timm=0.5.4 opencv=4.5.3 mkl=2024.0 setuptools=58.2.0 easydict wget scikit-image gradio=3.46.1 fairscale -c pytorch -c nvidia -c conda-forge -r "%~dp0\" -y
@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
@CALL condabin\micromamba.bat activate matte_anything_001
@CALL SET ROOT_DIR=%~dp0
@CALL SET PROJECT_DIR=%ROOT_DIR%GaussianHaircut
@CALL SET BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6\
@CALL pip install "git+https://github.com/facebookresearch/segment-anything.git"
@CALL python -m pip install "git+https://github.com/facebookresearch/detectron2.git"
@CALL cd "%PROJECT_DIR%/ext/Matte-Anything/GroundingDINO" && pip install -e .
@CALL pip install supervision==0.22.0
@CALL mkdir "%PROJECT_DIR%/ext/Matte-Anything/pretrained"
@CALL curl -L https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth -o "%PROJECT_DIR%/ext/Matte-Anything/pretrained/sam_vit_h_4b8939.pth"
@CALL curl -L https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth -o "%PROJECT_DIR%/ext/Matte-Anything/pretrained/groundingdino_swint_ogc.pth"
@CALL condabin\micromamba.bat deactivate && condabin\micromamba.bat activate gaussian_splatting_hair_001
@CALL curl -L "https://drive.usercontent.google.com/download?id=1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW" -o "%PROJECT_DIR%/ext/Matte-Anything/pretrained/ViTMatte_B_DIS.pth"
@CALL cd "%ROOT_DIR%"

@REM OpenPose
@CALL cd "%PROJECT_DIR%/ext/openpose"
@CALL curl -L "https://drive.usercontent.google.com/download?id=1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV" -o "%PROJECT_DIR%/ext/openpose/models.tar.gz"
@CALL tar -xvzf "%PROJECT_DIR%/ext/openpose/models.tar.gz" && rm "%PROJECT_DIR%/ext/openpose/models.tar.gz"
@CALL cd "%ROOT_DIR%"
@CALL condabin\micromamba.bat deactivate
@CALL git submodule update --init --recursive --remote
@CALL "%~dp0micromamba.exe" create -n openpose_001 cmake=3.20 -c conda-forge -r "%~dp0\" -y
@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
@CALL condabin\micromamba.bat activate openpose_001
@CALL SET ROOT_DIR=%~dp0
@CALL SET PROJECT_DIR=%ROOT_DIR%GaussianHaircut
@CALL SET BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6\
@CALL mkdir "%PROJECT_DIR%/ext/openpose/build"
@CALL cd "%PROJECT_DIR%/ext/openpose/build"
@CALL cmake .. -G "Visual Studio 16 2019" -A x64 ^
    -DBUILD_PYTHON=true ^
    -DUSE_CUDNN=off ^
    -DCMAKE_INSTALL_PREFIX="%PROJECT_DIR%/ext/openpose/install"
@REM Build the project using MSBuild
@CALL cmake --build . --config Release
@CALL condabin\micromamba.bat deactivate

@REM PIXIE
@CALL cd "%PROJECT_DIR%/ext" && git clone https://github.com/yfeng95/PIXIE
@CALL cd "%PROJECT_DIR%/ext/PIXIE"
@CALL chmod +x fetch_model.sh && ./fetch_model.sh
@CALL "%~dp0micromamba.exe" create -n pixie-env python=3.8 pytorch==2.0.0 torchvision==0.15.0 torchaudio==2.0.0 pytorch-cuda=11.8 fvcore pytorch3d==0.7.5 kornia matplotlib -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -r "%~dp0\" -y
@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
@CALL condabin\micromamba.bat activate pixie-env
@CALL aet ROOT_DIR=%~dp0
@CALL set PROJECT_DIR=%ROOT_DIR%GaussianHaircut
@CALL set BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6\
@CALL pip install pyyaml==5.4.1
@CALL pip install git+https://github.com/1adrianb/face-alignment.git@54623537fd9618ca7c15688fd85aba706ad92b59
@CALL PAUSE
