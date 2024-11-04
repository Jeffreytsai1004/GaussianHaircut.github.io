# 高斯发型：基于链的3D高斯的人类头发重建

[**论文**](https://arxiv.org/abs/2409.14778) | [**项目页面**](https://eth-ait.github.io/GaussianHaircut/)

该存储库包含高斯发型的官方实现，这是一种用于单目视频的基于链的头发重建方法。

## 开始使用

1. **安装 CUDA 11.8**

   请按照 https://developer.nvidia.com/cuda-11-8-0-download-archive 上的说明进行操作。

   确保
   - PATH 包含 <CUDA_DIR>/bin
   - LD_LIBRARY_PATH 包含 <CUDA_DIR>/lib64

   该环境仅在此 CUDA 版本下进行了测试。

2. **安装 Blender 3.6** 以创建链可视化

   请按照 https://www.blender.org/download/lts/3-6 上的说明进行操作。

3. **安装 make** 
   请按照 [在windows系统下安装make编译功能](https://gitcode.csdn.net/66c5892f13e4054e7e7c5b5f.html?dp_token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTU1MTc4LCJleHAiOjE3MzEzMDA3MTAsImlhdCI6MTczMDY5NTkxMCwidXNlcm5hbWUiOiJxcV8yMTQ5NzU5OSJ9.i1QYIwQxn1gK3lj-N5AJvM50jhaxOImkp2QYs_qIwd8&spm=1001.2101.3001.6661.1&utm_medium=distribute.pc_relevant_t0.none-task-blog-2~default~BlogCommendFromBaidu~activity-1-128243761-blog-131262178.235%5Ev43%5Epc_blog_bottom_relevance_base1&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-2~default~BlogCommendFromBaidu~activity-1-128243761-blog-131262178.235%5Ev43%5Epc_blog_bottom_relevance_base1&utm_relevant_index=1) 上的说明进行操作。

4. **安装 CMake** 
   请按照 [Windows下CMake安装教程](https://blog.csdn.net/u011231598/article/details/80338941) 上的说明进行操作。

5. **安装 VisualStudio 2022** 
   请按照 [Visual Studio 2022安装与使用教程](https://blog.csdn.net/InnerPeaceHQ/article/details/121716088?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522644F7F84-8517-4A35-A46E-9BC4FEE1C4DB%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=644F7F84-8517-4A35-A46E-9BC4FEE1C4DB&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~baidu_landing_v2~default-1-121716088-null-null.142^v100^pc_search_result_base9&utm_term=Windows%E5%AE%89%E8%A3%85VisualStudio2022&spm=1018.2226.3001.4187) 上的说明进行操作。

6. **部署项目**

   ```bash
   git clone https://github.com/Jeffreytsai1004/GaussianHaircut.github.io .
   install.bat
   ```

## 重建

1. **录制单目视频**

   使用项目页面上的示例作为参考，并尽量减少运动模糊。

2. **为重建场景设置目录**

   将视频文件放入该目录并重命名为 raw.mp4。

3. **运行脚本**

   ```bash
   export PROJECT_DIR="[/path/to/]GaussianHaircut"
   export BLENDER_DIR="[/path/to/blender/folder/]blender"
   DATA_PATH="[path/to/scene/folder]" ./run.sh
   ```

   该脚本执行数据预处理、重建和使用 Blender 的最终可视化。使用 Tensorboard 查看中间可视化。

## 许可证

此代码基于 3D 高斯点云项目。有关条款和条件，请参阅 LICENSE_3DGS。其余代码根据 CC BY-NC-SA 4.0 进行分发。

如果此代码对您的项目有帮助，请引用以下论文。

## 引用

```
@inproceedings{zakharov2024gh,
   title = {Human Hair Reconstruction with Strand-Aligned 3D Gaussians},
   author = {Zakharov, Egor and Sklyarova, Vanessa and Black, Michael J and Nam, Giljoo and Thies, Justus and Hilliges, Otmar},
   booktitle = {European Conference of Computer Vision (ECCV)},
   year = {2024}
} 
```

## 链接

- [3D 高斯点云](https://github.com/graphdeco-inria/gaussian-splatting)

- [神经发型](https://github.com/SamsungLabs/NeuralHaircut)：FLAME 拟合管道、链先验和发型扩散先验

- [HAAR](https://github.com/Vanessik/HAAR)：头发上采样

- [Matte-Anything](https://github.com/hustvl/Matte-Anything)：头发和身体分割

- [PIXIE](https://github.com/yfeng95/PIXIE)：FLAME 拟合的初始化

- [面部对齐](https://github.com/1adrianb/face-alignment)，[OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose)：FLAME 拟合的关键点检测