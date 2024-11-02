# Gaussian Haircut：使用链条对齐的3D高斯分布重建人类头发

[**论文**](https://arxiv.org/abs/2409.14778) | [**项目主页**](https://eth-ait.github.io/GaussianHaircut/)

本仓库包含 Gaussian Haircut 的官方实现，这是一个基于发丝的单目视频头发重建方法。

## 开始使用

1. **安装 CUDA 11.8**

   按照 https://developer.nvidia.com/cuda-11-8-0-download-archive 的说明进行安装。

   确保：
   - PATH 包含 <CUDA_DIR>/bin
   - LD_LIBRARY_PATH 包含 <CUDA_DIR>/lib64

   环境仅在此 CUDA 版本下测试过。

2. **安装 Blender 3.6** 用于创建发丝可视化

   按照 https://www.blender.org/download/lts/3-6 的说明进行安装。

3. **克隆仓库并运行安装脚本**

   ```bash
   git clone git@github.com:eth-ait/GaussianHaircut.git
   cd GaussianHaircut
   chmod +x ./install.sh
   ./install.sh
   ```

## 重建

1. **录制单目视频**

   参考项目页面上的示例，尽量减少运动模糊。

2. **为重建场景设置目录**

   将视频文件放入其中并重命名为 raw.mp4

3. **运行脚本**

   ```bash
   export PROJECT_DIR="[/path/to/]GaussianHaircut"
   export BLENDER_DIR="[/path/to/blender/folder/]blender"
   DATA_PATH="[path/to/scene/folder]" ./run.sh
   ```

   该脚本执行数据预处理、重建和使用 Blender 进行最终可视化。使用 Tensorboard 查看中间可视化结果。

## 许可证

本代码基于 3D Gaussian Splatting 项目。有关条款和条件，请参阅 LICENSE_3DGS。其余代码在 CC BY-NC-SA 4.0 许可下分发。

如果本代码对您的项目有帮助，请引用以下论文。

## 引用

```
@inproceedings{zakharov2024gh,
   title = {Human Hair Reconstruction with Strand-Aligned 3D Gaussians},
   author = {Zakharov, Egor and Sklyarova, Vanessa and Black, Michael J and Nam, Giljoo and Thies, Justus and Hilliges, Otmar},
   booktitle = {European Conference of Computer Vision (ECCV)},
   year = {2024}
} 
```

## 相关链接

- [3D Gaussian Splatting](https://github.com/graphdeco-inria/gaussian-splatting)

- [Neural Haircut](https://github.com/SamsungLabs/NeuralHaircut)：FLAME 拟合流程、发丝先验和发型扩散先验

- [HAAR](https://github.com/Vanessik/HAAR)：头发上采样

- [Matte-Anything](https://github.com/hustvl/Matte-Anything)：头发和身体分割

- [PIXIE](https://github.com/yfeng95/PIXIE)：FLAME 拟合的初始化

- [Face-Alignment](https://github.com/1adrianb/face-alignment), [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose)：用于 FLAME 拟合的关键点检测
