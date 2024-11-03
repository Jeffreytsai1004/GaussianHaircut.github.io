@ECHO ON
@CALL "%~dp0micromamba.exe" create -n gaussian_splatting_hair_001 python==3.10.14 git==2.41.0 git-lfs==3.2.0 -c pytorch -c conda-forge -c defaults -c anaconda -c fvcore -c iopath -c bottler -c nvidia -r "%~dp0\" -y
@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
@CALL condabin\micromamba.bat activate gaussian_splatting_hair_001
@CALL SET ROOT_DIR=%~dp0
@CALL SET PROJECT_DIR=%ROOT_DIR%GaussianHaircut
@CALL SET BLENDER_DIR=C:\Program Files\Blender Foundation\Blender 3.6\

@REM Clone the main repository
@CALL mkdir GaussianHaircut
@CALL git clone https://github.com/eth-ait/GaussianHaircut.git %PROJECT_DIR%

@REM Set up external libraries
@CALL mkdir %PROJECT_DIR%\ext
@CALL git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose --depth 1 %PROJECT_DIR%\ext\openpose
@CALL git -C %PROJECT_DIR%\ext\openpose submodule update --init --recursive --remote
@CALL git clone https://github.com/hustvl/Matte-Anything %PROJECT_DIR%\ext\Matte-Anything
@CALL git clone https://github.com/IDEA-Research/GroundingDINO.git %PROJECT_DIR%\ext\Matte-Anything\GroundingDINO
@CALL git clone https://github.com/egorzakharov/NeuralHaircut.git --recursive %PROJECT_DIR%\ext\NeuralHaircut
@CALL git -C %PROJECT_DIR%\ext\NeuralHaircut submodule update --init --recursive --remote
@CALL git clone https://github.com/facebookresearch/pytorch3d %PROJECT_DIR%\ext\pytorch3d
@CALL git -C %PROJECT_DIR%\ext\pytorch3d checkout 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7
@CALL git clone https://github.com/camenduru/simple-knn %PROJECT_DIR%\ext\simple-knn
@CALL mkdir %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party
@CALL git clone https://github.com/g-truc/glm %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm
@CALL git -C %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm checkout 5c46b9c07008ae65cb81ab79cd677ecc1934b903
@CALL git clone --recursive https://github.com/NVIDIAGameWorks/kaolin %PROJECT_DIR%\ext\kaolin
@CALL git -C %PROJECT_DIR%\ext\kaolin checkout v0.15.0
@CALL git clone https://github.com/SSL92/hyperIQA %PROJECT_DIR%\ext\hyperIQA


@REM Install PyTorch and other dependencies
@CALL pip install --upgrade pip
@CALL pip install torch==2.1.1+cu118 torchvision torchaudio torchdiffeq torchsde --index-url https://download.pytorch.org/whl/cu118
@CALL pip install -r requirements.txt

@REM Download the Neural Haircut files
@CALL mkdir %PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\diffusion_prior %PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\strand_prior %PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\PIXIE %PROJECT_DIR%\ext\hyperIQA\pretrained
@CALL curl -L "https://drive.usercontent.google.com/download?id=1OBR0Vzb_w5SNc1jmoScA6L8SqVniJGOr" -o %PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\diffusion_prior\dif_ckpt.pth
@CALL curl -L "https://drive.usercontent.google.com/download?id=1DESwUb-nsmi38VCDvnBwpd9kjcWONNT6" -o %PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\strand_prior\strand_ckpt.pth
@CALL curl -L "https://drive.google.com/uc?export=download&id=1mPcGu62YPc4MdkT8FFiOCP629xsENHZf" -o %PROJECT_DIR%\ext\NeuralHaircut\PIXIE\pixie_data.tar.gz
@CALL cd %PROJECT_DIR%\ext\NeuralHaircut\PIXIE && tar -xvzf pixie_data.tar.gz && del pixie_data.tar.gz
@CALL curl -L "https://drive.google.com/uc?export=download&id=1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE" -o %PROJECT_DIR%\ext\hyperIQA\pretrained\koniq_pretrained.pkl
@CALL cd %PROJECT_DIR%

@REM Matte-Anything
@CALL cd %PROJECT_DIR%\ext\Matte-Anything\GroundingDINO && pip install -e .
@CALL cd %PROJECT_DIR%
@CALL mkdir %PROJECT_DIR%\ext\Matte-Anything\pretrained
@CALL curl -L "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth" -o %PROJECT_DIR%\ext\Matte-Anything\pretrained\sam_vit_h_4b8939.pth
@CALL curl -L "https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth" -o %PROJECT_DIR%\ext\Matte-Anything\pretrained\groundingdino_swint_ogc.pth
@CALL curl -L "https://drive.usercontent.google.com/download?id=1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW" -o %PROJECT_DIR%\ext\Matte-Anything\pretrained\ViTMatte_B_DIS.pth

@REM OpenPose
@CALL curl -L "https://drive.usercontent.google.com/download?id=1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV" -o %PROJECT_DIR%\ext\openpose\models.tar.gz
@CALL cd %PROJECT_DIR%\ext\openpose && tar -xvzf models.tar.gz && del models.tar.gz
@CALL mkdir build
@CALL cd build
@CALL cmake .. -DBUILD_PYTHON=true -DUSE_CUDNN=off
@CALL make -j8
@CALL cd %ROOT_DIR%

@REM PIXIE
@CALL cd %PROJECT_DIR%/ext && git clone https://github.com/yfeng95/PIXIE
@CALL cd %PROJECT_DIR%/ext/PIXIE
@CALL chmod +x fetch_model.sh && ./fetch_model.sh
@CALL pip install git+https://github.com/1adrianb/face-alignment.git@54623537fd9618ca7c15688fd85aba706ad92b59
@CALL PAUSE
