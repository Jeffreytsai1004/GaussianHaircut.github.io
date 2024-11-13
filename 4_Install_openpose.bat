@ECHO OFF
@REM OPENPOSE
@CALL .\micromamba.exe create -n openpose python==3.10.14 git==2.41.0 git-lfs==3.2.0 -c pytorch -c conda-forge -r "%~dp0\" -y
@CALL .\micromamba.exe shell init --shell cmd.exe --prefix "%~dp0\"
@CALL .\condabin\micromamba.bat activate openpose
@CALL git submodule update --init --recursive --remote
@CALL SET ROOT_DIR=%~dp0
@CALL SET "ROOT_DIR=%ROOT_DIR:~0,-1%"
@CALL SET PROJECT_DIR=%ROOT_DIR%\GaussianHaircut
@CALL SET BLENDER_DIR="C:\Program Files\Blender Foundation\Blender 3.6\"
@CALL SET OPENPOSE_DIR=%PROJECT_DIR%\ext\openpose
@CALL SET MATTE_ANYTHING_DIR=%PROJECT_DIR%\ext\Matte-Anything
@CALL SET PIXIE_DIR=%PROJECT_DIR%\ext\PIXIE
@CALL SET DATA_PATH=%PROJECT_DIR%\data\raw
@CALL python -m pip install --upgrade pip
@CALL install cmake opencv-python protobuf glog boost h5py numpy make
@IF NOT EXIST %OPENPOSE_DIR%\build 
@CALL mkdir %OPENPOSE_DIR%\build
@CALL cd %OPENPOSE_DIR%\build
@CALL cmake %OPENPOSE_DIR% -DBUILD_PYTHON=true -DUSE_CUDNN=off -DCMAKE_INSTALL_PREFIX="%CD%/install" -DCUDA_TOOLKIT_ROOT_DIR="C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/11.8"
@CALL cmake --build . --config Release
@CALL cd %ROOT_DIR%
@CALL .\condabin\micromamba.bat deactivate
@ECHO Installation of openpose completed.
@ECHO PAUSE