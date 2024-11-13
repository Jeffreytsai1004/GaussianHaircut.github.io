@ECHO OFF
@REM SET BASE PATHS
SET "ROOT_DIR=%~dp0"
SET "ROOT_DIR=%ROOT_DIR:~0,-1%"
SET "micromamba=%ROOT_DIR%\micromamba.exe"
SET "MAMBABAT=%ROOT_DIR%\condabin\micromamba.bat"

@REM MATTE ANYTHING
@CALL .\micromamba.exe create -n matte_anything python==3.10.14 git==2.41.0 git-lfs==3.2.0 pytorch==2.0.0 pytorch-cuda==11.8 torchvision==0.15.1 tensorboard==2.15.0 timm==0.5.4 opencv==4.5.3 mkl==2024.0 setuptools==58.2.0 easydict wget scikit-image gradio==3.46.1 fairscale supervision==0.22.0 -c pytorch -c nvidia -c conda-forge -r "%~dp0\" -y
@CALL .\micromamba.exe shell init --shell cmd.exe --prefix "%~dp0\"
@CALL .\condabin\micromamba.bat activate matte_anything
@CALL SET ROOT_DIR=%~dp0
@CALL SET "ROOT_DIR=%ROOT_DIR:~0,-1%"
@CALL SET PROJECT_DIR=%ROOT_DIR%\GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
@CALL python -m pip install --upgrade pip
@CALL pip install -e %PROJECT_DIR%\ext\segment-anything
@CALL pip install -e %PROJECT_DIR%\ext\detectron2
@CALL pip install -e %PROJECT_DIR%\ext\Matte-Anything\GroundingDINO
@CALL .\condabin\micromamba.bat deactivate

@ECHO Installation of matte_anything completed.

@ECHO PAUSE