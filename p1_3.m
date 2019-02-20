clear; close all; clc;

ims = cell(4); ref = cell(4);

for i = 1 : 4
    ims{i} = im2double(imread(strcat('i', int2str(i+3), '.tif')));
    ref{i} = im2double(imread(strcat('ref', int2str(i+3), '.tif')));
end


% figure(2);
% imshow(ims{1});
% h = imrect;
% position = wait(h);
% position = round(position);
position = [201.88783269962 112.957224334601 134.039923954373 779.249049429658];
for i = 1 : 4
    ims{i} = imcrop(ims{i}, position);
    ref{i} = imcrop(ref{i}, position);
end

ref_f = fftshift(fft2(ref{1}));
ref_f = rot90(ref_f);
[h, w] = size(ref_f);
fils = h;
cols = w;
mask = zeros(h, w);

c = 446;
r = 20;
H = fspecial('gaussian', r * 2 + 1, 10);
mask(fils/2 - r : fils/2 + r, c - r : c + r) = H;
ref_ff = ref_f .* mask;
ref_ff(:, cols/2 - r : cols/2 + r) = ref_ff(:, c - r : c + r);
ref_ff(:, c - r : c + r) = 0;

ref_e = ifft2(ifftshift(ref_ff));
ref_e = angle(ref_e);
mex Miguel_2D_unwrapper.cpp
ref_d = Miguel_2D_unwrapper(single(ref_e));
ref_d = double(ref_d);

figure(1);
subplot(221); imshow(log(ref_f), []); title('Ref. FFT');
subplot(222); imshow(log(ref_ff), []); title('Centrado');
subplot(223); imshow(ref_e, []); title('Ref. envuelta');
subplot(224); imshow(ref_d, []); title('Ref. Desenvuelta');

img_f = fftshift(fft2(ims{1}));
img_f = rot90(img_f);
img_ff = img_f .* mask;
img_ff(:, cols/2 - r : cols/2 + r) = img_ff(:, c - r : c + r);
img_ff(:, c - r : c + r) = 0;

img_e = ifft2(ifftshift(img_ff));
img_e = angle(img_e);
img_d = Miguel_2D_unwrapper(single(img_e));
img_d = double(img_d);

obj = ref_d - img_d;

figure(2);
subplot(221); imshow(log(img_f), []); title('Obj. FFT');
subplot(222); imshow(log(img_ff), []); title('Centrado');
subplot(223); imshow(img_e, []); title('Obj. Env');
subplot(224); imshow(img_d, []); title('Obj. Desenvuelto');

figure(3); 
mesh(obj); colormap bone;

z = obj;
% [x, y] = meshgrid(1:cols, 1:fils);

% n = fils*cols;
% x = reshape(x,1,[]);
% y = reshape(y,1,[]);
% z = reshape(z,1,[]);
% z = [x; y; z];
% z1 = TR(z, n, 0, 0, 0, 0, deg2rad(120), 0);
% z2 = TR(z, n, 0, 0, 0, 0, deg2rad(-120), 0);
% figure(4);
% plot3(z(1,:), z(2,:), z(3,:), 'r.');
% hold on;
% plot3(z1(1,:), z1(2,:), z1(3,:), 'g.');
% plot3(z2(1,:), z2(2,:), z2(3,:), 'b.');
% hold off;
% % 
% % for y = i : f
% %     for x = 1 : c
% %         if (y >= round(position(2)) && y <= round(position(2)) + round(position(4))) && (x >= round(position(1))&& x <= round(position(1)) + round(position(3)))
% %             mask(y,x) = 1;
% %         else
% %             mask(y,x) = 0;
% %         end
% %     end
% % end
% % 
% % for i = 1 : 4
% %     ims{i} = ims{i} .* mask;
% %     ref{i} = ref{i} .* mask;
% % end
% 
% %% WRAP
% fenvO = WrapTan4Pasos(ims{1}, ims{2}, ims{3}, ims{4});
% fenvR = WrapTan4Pasos(ref{1}, ref{2}, ref{3}, ref{4});
% 
% % figure(2);
% % subplot(221); imagesc(fenvO); colormap gray; colorbar;
% % subplot(222); plot(fenvO(:, round(c/2)), 'm'); title('Perfil objeto');
% % subplot(223); imagesc(fenvR); colormap gray; colorbar;
% % subplot(224); plot(fenvR(:, round(c/2)), 'r'); title('Perfil referencia');
% 
% 
% %% UNWRAP
% mex Miguel_2D_unwrapper.cpp
% fdesO = Miguel_2D_unwrapper(single(fenvO));
% fdesR = Miguel_2D_unwrapper(single(fenvR));
% 
% fdesO = double(fdesO);
% fdesR = double(fdesR);
% z = fdesO - fdesR;
% 
% figure(3);
% subplot(131); imagesc(fdesO); colormap gray; colorbar; title('Objeto');
% subplot(132); imagesc(fdesR); colormap gray; colorbar; title('Referencia');
% subplot(133); imagesc(z); colormap gray; colorbar; title('topografia');
% 
% [x, y] = meshgrid(1:c, 1:f);
% 
% n = f*c;
% x = reshape(x,1,[]);
% y = reshape(y,1,[]);
% z = reshape(z,1,[]);
% z = [x; y; z];
% z1 = TR(z, n, 0, 0, 0, deg2rad(120), deg2rad(120), deg2rad(120));
% figure(4);
% plot3(z(1,:), z(2,:), z(3,:), 'r.');
% hold on;
% plot3(z1(1,:), z1(2,:), z1(3,:), 'b.');
