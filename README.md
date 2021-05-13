# MS-HTC
## Suggested setup
- The demo scripts were tested on Matlab 2016b (installed on Windows 10). The demo scripts cannot run correctly on Matlab Online/Matlab for Linux/Matlab for Mac.
- Functions in ESPIRiT toolbox are required, please download ESPIRiT toolbox from https://people.eecs.berkeley.edu/~mlustig/software/SPIRiT_v0.3.tar.gz, and unzip it under .\tools\

## Demo and sample data
- Two matlab demo scripts are provided for MS-HTC reconstruction.
  + demo_MSHTC_spiral: MS-HTC reconstruction for spiral imaging
  + demo_MSHTC_T1w_Cartesian: MS-HTC reconstruction for Cartesian imaging
    with 1D Poisson-disk undersampling
- Two sets of sample data are available.
  + T2w_SE_Spiral.mat: 4-slice 8-channel fully sampled spiral data
  + T1w_SE.mat: 4-slice 8-channel fully sampled T1w data. mask_3x_vd0_1D_N360.mat contains the sampling mask at R = 3.
- The reconstruction results will be saved under .\tmp\

## Reference
Liu, Yilong, et al. "Calibrationless parallel imaging reconstruction for multislice MR data using low‐rank tensor completion." Magnetic Resonance in Medicine 85.2 (2021): 897-911.
