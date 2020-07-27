function mon = img2montage(img, mon_size, varargin)
% This function is used to create a montage of images.
% Output:
%       mon - montage created from images
% 
% Inputs:
%       img - multi-slice image matrix, for gray level images, the matrix
%       dimensions can be nx * ny * 1 * nz, or nx * ny * nz. For color
%       images, the matrix dimensions should be nx * ny * 3 * nz.
% 
%       mon_size - a 2-element vector that specifies the number of rows and
%       columns.
% 
% -- Created by Yilong Liu, 2015-12
% -- Modified by Yilong Liu, 2019-03
%       

if nargin>2
   b = varargin{1};
   img_max = prctile(img(:), 100);
   img_size = size(img); img_size(1:2) = img_size(1:2)+b;
   mask = ones(size(img));
   mask = zpad(mask, img_size);
   img_new = zpad(img, img_size);
   img_new(~mask) = img_max;
   img = img_new;
end

size_img = size(img);
if length(size(img)) == 3
    img = reshape(img, [size_img(1:2), 1, size_img(3)]);
end
imgs = cell(1, mon_size(1)*mon_size(2));
DIM = size(img);
for i = 1:(mon_size(1)*mon_size(2))
    if i<=DIM(4)
        imgs{i} = squeeze(img(:, :, :, i));
    else
        imgs{i} = zeros(DIM(1), DIM(2), DIM(3));
    end
end
imgs = reshape(imgs, [mon_size(2) mon_size(1)]);
imgs = permute(imgs, [2 1]);
mon = cell2mat(imgs);

end