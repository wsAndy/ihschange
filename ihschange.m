%% 多光谱 变color
%% ish变化 取消亮度部分用全色替代，反变换
%% 得到 color
%% Multi-spectral 1B 2G 3R 4NIR
function ihschange()
imgMulti = imread('02NOV21044347-M2AS_R1C1-000000185940_01_P001.TIF');
imgPan = imread('02NOV21044347-P2AS_R1C1-000000185940_01_P001.TIF');
% 由于原始的图像过大，需要将原图像裁剪，再进行拼接

imgMulti = uint16touint8(imgMulti);
imgPan = uint16touint8(imgPan);
imgMultiRGB = imgMulti(:,:,[3,2,1]);

[mp,np] = size(imgPan);

% 需要做上采样而不是下采样
imgMultiRGBBASE = imresize(imgMultiRGB,[mp np]);

% change the MultiRGB to IHS
% replace the I with imgPan
% change IHS to RGB
% 由于原始图像直接进行HSI变化造成内存不足，将原图像分成16份依次做hsi与rgb变换与替换
N = 16;
% if() 判断是否可以整除
% end
count = 1;
start_index = 1;
end_index = mp/N;

start_index_out = start_index;
end_index_out = end_index;

while(count <= 16)
    count
hsi = rgb2hsi(imgMultiRGBBASE(start_index:end_index,:,:));%H S I
hsi(:,:,3) = im2douhble(imgPan(start_index:end_index,:,:));
rgb(start_index_out:end_index_out,:,:) = hsi2rgb(hsi);

count = count +1;
start_index = end_index + 1;
end_index = count*mp/N;

start_index_out = end_index_out +1;
end_index_out = end_index_out + mp/N;

if(count==9)
    imwrite(rgb,'output1.png');
    clear rgb;
    start_index_out = 1;
    end_index_out =mp/N;
end
if(count==17)
    imwrite(rgb,'output2.png');
end
end
disp('ok');

end



function out_img = uint16touint8(src)
out_img = im2double(src);
out_img = mat2gray(out_img);
out_img = im2uint8(out_img);
end

function out=graychange(ori,tar)
ori = im2double(ori);
mean_t = im2double(mean(mean(tar)));
var_t = im2double(var(double(tar(:))));

mean_o = (mean(mean(ori)));
var_o = (var(double(ori(:))));

out = (var_t/var_o)*(ori - mean_o) + mean_t;
end
