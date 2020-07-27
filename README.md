# MS-HTC
## 1. Demo and sample data
- Two matlab demo scripts are provided for MS-HTC reconstruction.
  + demo_MSHTC_spiral: MS-HTC reconstruction for spiral imaging
  + demo_MSHTC_T1w_Cartesian: MS-HTC reconstruction for Cartesian imaging
    with 1D Poisson-disk undersampling
- Two sets of sample data are available.
  + T2w_SE_Spiral.mat: 4-slice 8-channel fully sampled spiral data
  + T1w_SE.mat: 4-slice 8-channel fully sampled T1w data. mask_3x_vd0_1D_N360.mat contains the sampling mask at R = 3.

## 2. Suggested setup
The demo scripts were tested on Matlab 2016b (installed on Windows 10). The demo scripts cannot run correctly on Matlab Online/Matlab for Linux/Matlab for Mac.

## 3. Reference
Liu, Y., et al., Calibrationless Parallel Imaging Reconstruction for Multi-slice MR Data using Low-Rank Tensor Completion. Magn Reson Med. Accepted.
