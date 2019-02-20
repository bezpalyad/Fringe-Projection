clear; close all; clc;

im = double(imread('C:\Users\files\ic0.tif'));
[M N] = size(im);
F = fftshift(fft2(im));
S2 = abs(F);
S3 = log(1 + abs(F));

% figure(1);
% subplot(221); imagesc(im); title('Original');
% subplot(222); imagesc(S3); title('FFT'); colormap gray;
% subplot(2,2,[3, 4]); plot(S2, 'm');


H = fftshift(lpfilter('gaussian', M, N, 27));
F = H .* F;
imi = ifft2(ifftshift(F));

figure(2);
subplot(222); imagesc(imi); title('Inversa'); colormap gray;
subplot(221); imagesc(im); title('Original');
subplot(2, 2, 3); plot(abs(S2), 'r');
subplot(224); plot(abs(F), 'b');
