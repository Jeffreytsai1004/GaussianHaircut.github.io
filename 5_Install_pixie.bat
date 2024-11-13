@ECHO OFF
@REM SET BASE PATHS
SET "ROOT_DIR=%~dp0"
SET "ROOT_DIR=%ROOT_DIR:~0,-1%"
SET "micromamba=%ROOT_DIR%\micromamba.exe"
SET "MAMBABAT=%ROOT_DIR%\condabin\micromamba.bat"

@REM PIXIE
@CALL .\micromamba.exe create -n pixie-env python=3.8 pytorch==2.0.0 torchvision==0.15.0 torchaudio==2.0.0 pytorch-cuda=11.8 fvcore pytorch3d==0.7.5 kornia matplotlib -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -r "%~dp0\" -y
@CALL .\micromamba.exe shell init --shell cmd.exe --prefix "%~dp0\"
@CALL .\condabin\micromamba.bat activate pixie-env
@CALL SET ROOT_DIR=%~dp0
@CALL SET "ROOT_DIR=%ROOT_DIR:~0,-1%"
@CALL SET PROJECT_DIR=%ROOT_DIR%\GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
@CALL .\condabin\micromamba.bat activate pixie-env
@CALL pip install pyyaml==5.4.1
@CALL cd %PROJECT_DIR%\ext\face-alignment && pip install -e .
@CALL cd %ROOT_DIR%
@CALL .\condabin\micromamba.bat deactivate

@ECHO Installation of pixie-env completed.

@ECHO PAUSE