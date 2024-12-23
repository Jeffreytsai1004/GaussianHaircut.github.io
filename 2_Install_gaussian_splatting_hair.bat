@ECHO OFF

@REM GAUSSIAN SPLATTING HAIR
@CALL .\micromamba.exe create -n gaussian_splatting_hair python==3.10.14 git==2.41.0 git-lfs==3.2.0 -c pytorch -c conda-forge -c defaults -c anaconda -c fvcore -c iopath -c bottler -c nvidia -r "%~dp0\" -y
@CALL .\micromamba.exe shell init --shell cmd.exe --prefix "%~dp0\"
@CALL .\condabin\micromamba.bat activate gaussian_splatting_hair
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
@CALL pip install -r .\requirements.txt
@ECHO Starting installation pytorch3d...
@CALL cd %PROJECT_DIR%\ext\pytorch3d && pip install -e .
@IF %ERRORLEVEL% NEQ 0 (
    @ECHO pytorch3d installation failed
    @PAUSE
    exit /b %ERRORLEVEL%
)
@ECHO Starting installation of npbgpp...
@CALL cd %PROJECT_DIR%\ext\NeuralHaircut\npbgpp && pip install -e .
@IF %ERRORLEVEL% NEQ 0 (
    @ECHO npbgpp installation failed
    @PAUSE
    exit /b %ERRORLEVEL%
)
@ECHO Starting installation simple-knn...
@CALL cd %PROJECT_DIR%\ext\simple-knn && pip install -e .
@IF %ERRORLEVEL% NEQ 0 (
    @ECHO simple-knn installation failed
    @PAUSE
    exit /b %ERRORLEVEL%
)
@ECHO Starting installation diff_gaussian_rasterization_hair...
@CALL cd %PROJECT_DIR%\ext\diff_gaussian_rasterization_hair && pip install -e .
@IF %ERRORLEVEL% NEQ 0 (
    @ECHO diff_gaussian_rasterization_hair installation failed
    @PAUSE
    exit /b %ERRORLEVEL%
)
@ECHO Starting installation kaolin...
@CALL pip install -e %PROJECT_DIR%\ext\kaolin
@IF %ERRORLEVEL% NEQ 0 (
    @ECHO kaolin installation failed
    @PAUSE
    exit /b %ERRORLEVEL%
)
@CALL cd %ROOT_DIR%
@CALL .\condabin\micromamba.bat deactivate

@ECHO Installation of gaussian_splatting_hair completed.

@ECHO PAUSE