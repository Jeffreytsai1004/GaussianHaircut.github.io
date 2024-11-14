@ECHO OFF
@REM PIXIE
@CALL .\micromamba.exe create -n pixie-env python==3.10.14 git==2.41.0 git-lfs==3.2.0 -c pytorch -c nvidia -c fvcore -c conda-forge -c pytorch3d -r "%~dp0\" -y
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
@CALL python -m pip install --upgrade pip
@CALL pip install --force-reinstall torch==2.2.0+cu121 torchvision==0.17.0+cu121 torchaudio==2.2.0+cu121 --index-url https://download.pytorch.org/whl/cu121
@CALL pip install pyyaml fvcore kornia matplotlib
@CALL cd %PROJECT_DIR%\ext\face-alignment && pip install -e .
@CALL cd %ROOT_DIR%
@CALL .\condabin\micromamba.bat deactivate
@ECHO Installation of pixie-env completed.
@ECHO PAUSE