%% Prepare workspace
close all
clear all
clc

tmp_dir = '.\tmp\T1w\'; mkdir(tmp_dir);

%% Addpath
MSHTC_set_path;

%% Prepare data
load .\data\T1w_SE.mat
load .\data\mask_3x_vd0_1D_N360.mat
R = 3; slice_list = 1:4;

data = raw(:, :, slice_list, :);
[nx, ny, ns, nc] = size(data);
mask = crop(mask, [nx, ny, ns]);
mask = repmat(mask, [1 1 1 nc]);

data = permute(data, [1 2 4 3]);
mask = permute(mask, [1 2 4 3]);

%% Parameter setting
% Parameters for data
Param.DATA.R = R;
Param.DATA.sx = nx;
Param.DATA.sy = ny;
Param.DATA.nc = nc;
Param.DATA.ns = ns;
Param.DATA.slice_list = slice_list;

% Parameters for MS-HTC reconstruction
Param.MSHTC.ksize = [3 3];     % Kernel size for constructing block-wise Hankel tensor
Param.MSHTC.rank = [87 27 4]; % Ranks for 1-mode/2-mode/3-mode matrix unfolding, respectively
Param.MSHTC.nIter = 1000;      % Maximum iteration number
Param.MSHTC.lambda = 1;        % Initial relaxation coefficient
Param.MSHTC.verbose.flag = 1;  % Output verbose information


%% Retrospective undersampling
data_un = data.*mask;

%% Reconstruction
% Reconstruction for fully sampled data
im_ref = ifft2c(data);
% Reconstruction for undersampled data
im_un = ifft2c(data_un);

% MS-HTC reconstruction
% filename
filename = [tmp_dir ...
    'slice' num2str(slice_list) ...
    '_R' num2str(R) ...
    '_ksize' num2str(Param.MSHTC.ksize(1)) ...
    '_rank' num2str(Param.MSHTC.rank) ...
    '_L' num2str(Param.MSHTC.lambda)];

if exist([filename '.mat'], 'file')
    load([filename '.mat']);
    im_MSHTC = ifft2c(res);
else
    res = data_un; % intialized k-space estimation
    ref = data; % fully sampled data as reference 
    tmark = tic;
    [res, para, updates, errs] = MS_HTC(data_un, Param, res, ref);
    im_MSHTC = ifft2c(res);
    
    % Save results
    % save recon info
    final_recon_time = toc(tmark);
    toc(tmark);
    final_iter_number = sum(updates>0);
    log_txt = {...
        ['Iteration number = ' num2str(final_iter_number) ';  '],...
        ['Reconstruction time = ' num2str(final_recon_time/ns) ' second/slice;'], ...
        };
    txtwrite(string(log_txt), [filename '_log.txt'], '%s\r\n');
    
    % save reconstructed results
    save([filename  '.mat'],...
        'res', 'para', 'updates', 'errs');
end

%% Save reconstructed images
% save reconstructed images for fully sampled reference/NUFFT
% reconstruction/MS-HTC reconstruction
tmp = sos(im_ref, 3);
max_ref = prctile(tmp(:), 97.6);

img = cat(4, im_ref, im_un, im_MSHTC);
img = sos(img, 3);
im = img2montage(img, [3 ns]);
im = im/max_ref;
imwrite(im, [filename '.tiff']);

% Save error maps
img = squeeze(sos(im_MSHTC-im_ref, 3));
err_MSHTC = img2montage(img*5/max_ref, [1 ns]);
imwrite(err_MSHTC, [filename '_errormap.tiff']);
