@REM Gaussian_Splatting_Hair
@CALL "%~dp0micromamba.exe" create -n gaussian_splatting_hair python==3.10.14 git==2.41.0 git-lfs==3.2.0 -c pytorch -c conda-forge -c defaults -c anaconda -c fvcore -c iopath -c bottler -c nvidia -r "%~dp0\" -y
@CALL "%~dp0micromamba.exe" shell init --shell cmd.exe --prefix "%~dp0\"
@CALL condabin\micromamba.bat activate gaussian_splatting_hair

@REM 设置环境变量
@CALL SET ROOT_DIR=%~dp0
@CALL SET PROJECT_DIR=%ROOT_DIR%GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw

@REM 克隆主仓库
@CALL mkdir %PROJECT_DIR%
@CALL git config --global http.postBuffer 524288000
@CALL git clone https://github.com/eth-ait/GaussianHaircut.git %PROJECT_DIR%
@REM 拉取所有外部库
@CALL mkdir %PROJECT_DIR%\ext
@CALL git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose %PROJECT_DIR%\ext\openpose --depth 1
@CALL cd %PROJECT_DIR%\ext\openpose && git submodule update --init --recursive --remote
@CALL git clone https://github.com/hustvl/Matte-Anything %PROJECT_DIR%\ext\Matte-Anything
@CALL git clone https://github.com/IDEA-Research/GroundingDINO.git %MATTE_ANYTHING_DIR%\GroundingDINO
@CALL git clone git@github.com:egorzakharov/NeuralHaircut.git --recursive %PROJECT_DIR%\ext\NeuralHaircut
@CALL git clone https://github.com/facebookresearch/pytorch3d %PROJECT_DIR%\ext\pytorch3d
@CALL cd %PROJECT_DIR%\ext\pytorch3d && git checkout 2f11ddc5ee7d6bd56f2fb6744a16776fab6536f7
@CALL git clone https://github.com/camenduru/simple-knn %PROJECT_DIR%\ext\simple-knn
@CALL git clone https://github.com/g-truc/glm %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm
@CALL cd %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair\third_party\glm && git checkout 5c46b9c07008ae65cb81ab79cd677ecc1934b903
@CALL git clone --recursive https://github.com/NVIDIAGameWorks/kaolin %PROJECT_DIR%\ext\kaolin
@CALL cd %PROJECT_DIR%\ext\kaolin && git checkout v0.15.0
@CALL git clone https://github.com/SSL92/hyperIQA %PROJECT_DIR%\ext\hyperIQA
@CALL git clone https://github.com/yfeng95/PIXIE %PROJECT_DIR%\ext\PIXIE

@REM 安装 Python 依赖
@CALL cd %ROOT_DIR%
@CALL pip install -r requirements.txt

@REM 下载 Neural Haircut 文件
@CALL curl -L "https://drive.usercontent.google.com/download?id=1OBR0Vzb_w5SNc1jmoScA6L8SqVniJGOr" -o %PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\diffusion_prior\dif_ckpt.pth
@CALL curl -L "https://drive.usercontent.google.com/download?id=1DESwUb-nsmi38VCDvnBwpd9kjcWONNT6" -o %PROJECT_DIR%\ext\NeuralHaircut\pretrained_models\strand_prior\strand_ckpt.pth
@CALL curl -L "https://drive.google.com/uc?export=download&id=1mPcGu62YPc4MdkT8FFiOCP629xsENHZf" -o %PROJECT_DIR%\ext\NeuralHaircut\PIXIE\pixie_data.tar.gz
@CALL 7z x %PROJECT_DIR%\ext\NeuralHaircut\PIXIE\pixie_data.tar.gz -o%PROJECT_DIR%\ext\NeuralHaircut\PIXIE\
@CALL del %PROJECT_DIR%\ext\NeuralHaircut\PIXIE\pixie_data.tar.gz
@CALL curl -L "https://drive.google.com/uc?export=download&id=1OOUmnbvpGea0LIGpIWEbOyxfWx6UCiiE" -o %PROJECT_DIR%\ext\hyperIQA\pretrained\koniq_pretrained.pkl
@CALL cd %PROJECT_DIR%
@CALL condabin\micromamba.bat deactivate

@REM Matte-Anything
@REM 创建 Matte-Anything 环境
@CALL "%~dp0micromamba.exe" create -n matte_anything python==3.10.14 git==2.41.0 git-lfs==3.2.0 pytorch=2.0.0 pytorch-cuda=11.8 torchvision tensorboard timm=0.5.4 opencv=4.5.3 mkl=2024.0 setuptools=58.2.0 easydict wget scikit-image gradio=3.46.1 fairscale -c pytorch -c nvidia -c conda-forge -r "%~dp0\ext\Matte-Anything\" -y
@CALL condabin\micromamba.bat activate matte_anything
@CALL SET ROOT_DIR=%~dp0
@CALL SET PROJECT_DIR=%ROOT_DIR%GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
@CALL pip install git+https://github.com/facebookresearch/segment-anything.git
@CALL pip install 'git+https://github.com/facebookresearch/detectron2.git'
@CALL cd %MATTE_ANYTHING_DIR%\GroundingDINO && pip install -e .
@REM 修复 GroundingDINO 错误
@CALL pip install supervision==0.22.0
@CALL cd %MATTE_ANYTHING_DIR% && mkdir pretrained
@CALL cd %MATTE_ANYTHING_DIR%\pretrained
@CALL curl -L "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth" -o %MATTE_ANYTHING_DIR%\pretrained\sam_vit_h_4b8939.pth
@CALL curl -L "https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth" -o %MATTE_ANYTHING_DIR%\pretrained\groundingdino_swint_ogc.pth
@CALL curl -L "https://drive.usercontent.google.com/download?id=1d97oKuITCeWgai2Tf3iNilt6rMSSYzkW" -o %MATTE_ANYTHING_DIR%\pretrained\ViTMatte_B_DIS.pth
@CALL cd %PROJECT_DIR%
@CALL condabin\micromamba.bat deactivate

@REM OpenPose
@REM 创建 OpenPose 环境
@CALL "%~dp0micromamba.exe" create -n openpose python==3.10.14 git==2.41.0 git-lfs==3.2.0 cmake=3.20 make -c conda-forge -r "%PROJECT_DIR%\ext\openpose" -y
@CALL condabin\micromamba.bat activate openpose
@CALL SET ROOT_DIR=%~dp0
@CALL SET PROJECT_DIR=%ROOT_DIR%GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
@REM 下载 OpenPose 模型
@CALL curl -L "https://drive.usercontent.google.com/download?id=1Yn03cKKfVOq4qXmgBMQD20UMRRRkd_tV" -o %OPENPOSE_DIR%\models.tar.gz
@CALL 7z x %OPENPOSE_DIR%\models.tar.gz -o%OPENPOSE_DIR%\
@CALL del %OPENPOSE_DIR%\models.tar.gz
@CALL git submodule update --init --recursive --remote
@REM 安装 OpenCV 依赖
@CALL pip install opencv-python opencv-contrib-python -i https://pypi.tuna.tsinghua.edu.cn/simple
@CALL mkdir build
@CALL cd build
@CALL cmake .. -G "Unix Makefiles" -DBUILD_PYTHON=ON -DUSE_CUDNN=OFF
@CALL make -j8
@CALL cd %PROJECT_DIR%
@CALL condabin\micromamba.bat deactivate

@REM PIXIE
@CALL "%~dp0micromamba.exe" create -n pixie_env python==3.8 pytorch==2.0.0 torchvision==0.15.0 torchaudio==2.0.0 pytorch-cuda=11.8 fvcore pytorch3d==0.7.5 kornia matplotlib -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -r "%PROJECT_DIR%\ext\PIXIE" -y
@CALL condabin\micromamba.bat activate pixie_env
@CALL SET ROOT_DIR=%~dp0
@CALL SET PROJECT_DIR=%ROOT_DIR%GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
@CALL copy %ROOT_DIR%\fetch_model.bat %PIXIE_DIR%\fetch_model.bat
@CALL %PIXIE_DIR%\fetch_model.bat
@CALL cd %PIXIE_DIR%
@CALL pip install pyyaml==5.4.1
@CALL pip install git+https://github.com/1adrianb/face-alignment.git@54623537fd9618ca7c15688fd85aba706ad92b59
@CALL cd %PROJECT_DIR%
@CALL condabin\micromamba.bat deactivate