%% Prepare workspace
close all
clear all
clc

tmp_dir = '.\tmp\spiral\'; mkdir(tmp_dir);

%% Addpath
MSHTC_set_path;

%% Prepare data
load .\data\T2w_SE_Spiral.mat
R = 2; slice_list = 1:4;
data = double(data); % acq window * nshot * ncoil * nslice

k = k/max(abs(k(:)))/2;
w(~w) = nan; w(isnan(w)) = min(w(:))/2;

%% Parameter setting
ns = length(slice_list); nc = size(data, 3);

% Parameters for data
Param.DATA.R = R;
Param.DATA.sx = N;
Param.DATA.sy = N;
Param.DATA.nc = nc;
Param.DATA.ns = ns;
Param.DATA.slice_list = slice_list;

% Parameters for MS-HTC reconstruction
Param.MSHTC.ksize = [6 6];     % Kernel size for constructing block-wise Hankel tensor
Param.MSHTC.rank = [180 65 4]; % Ranks for 1-mode/2-mode/3-mode matrix unfolding, respectively
Param.MSHTC.nIter = 1000;      % Maximum iteration number
Param.MSHTC.lambda = 2;     % Initial relaxation coefficient
Param.MSHTC.verbose.flag = 1;  % Output verbose information

%% Define NUFFT Operator
Ns = [N, N];                   % size of the target image

GFFT1 = NUFFT(k, w, [0,0] , Ns);  % NUFFT operator
p = calc_w_NUFFT(GFFT1, data, w); close all;
w = w/p;
GFFT1 = NUFFT(k,w, [0,0] , Ns);  % NUFFT operator

Param.NUFFT.GFFT1 = GFFT1;
Param.NUFFT.w = w;

%% Retrospective undersampling
switch R
    case 2
        ind_shot_start = [1 2 1 2];
    case 3
        ind_shot_start = [1 2 3 1];
    case 4
        ind_shot_start = [4 2 3 1];
end

data_un = zeros(size(data));
for ind_slice = 1:ns
    data_un(:, ind_shot_start(ind_slice):R:end, :, ind_slice)...
        = data(:, ind_shot_start(ind_slice):R:end, :, ind_slice);
end

%% Reconstruction
% Reconstruction for fully sampled data
im_ref = GFFT1'*(data.*repmat(sqrt(w),[1,1,nc]));
% Reconstruction for undersampled data
im_un = GFFT1'*(data_un.*repmat(sqrt(w),[1,1,nc]))*R;
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
    res = fft2c(im_un);     % initialized Cartesian k-space
    ref = fft2c(im_ref);    % reference Cartesian k-space for error calculation
    tmark = tic;
    [res, para, updates, errs] = MS_HTC(data_un, Param, res, ref); 
    % In case reconstruction error for each iteration is not needed, the
    % function for MS-HTC can be called as below:
    %  [res, para, updates] = MS_HTC(data_un, Param, res);   
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

%% Save reconstructed images and error maps
% Define a mask that excludes the corns of FOV
[nx, ny, ~, ns] = size(im_ref);
[~, mask] = gen_lambda_map([nx, ny, ns]);

% Save reconstructed images for fully sampled reference/NUFFT
% reconstruction/MS-HTC reconstruction
tmp = sos(im_ref, 3).*mask;
max_ref = prctile(tmp(:), 99.9);

img = cat(4, im_ref, im_un, im_MSHTC);
img = sos(img, 3);
img_mask = reshape(mask, [nx, ny, 1, ns]);
img_mask = repmat(img_mask, [1 1 1 3]);
img = img.*img_mask;

img = rot90(img, -1);
im = img2montage(img, [3 ns]);
im = im/max_ref;
imwrite(im, [filename '.tiff']);

% Save error maps
img = squeeze(sos(im_MSHTC-im_ref, 3));
img = img.*mask;
img = rot90(img, -1);
err_MSHTC = img2montage(img*5/max_ref, [1 ns]);
imwrite(err_MSHTC, [filename '_errormap.tiff']);
