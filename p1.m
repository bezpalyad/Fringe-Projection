clear; close all; clc;

ims = cell(12); ref = cell(4);

for i = 1 : 12
    ims{i} = im2double(imread(strcat('i', int2str(i-1), '.tif')));
    ims{i} = butterworth(ims{i}, 0.1, 2);
end

for i = 4 : 7
    ref{i-3} = im2double(imread(strcat('ref', int2str(i), '.tif')));
    ref{i-3} = butterworth(ref{i-3}, 0.1, 2);
end

maskL = logical(imread('imaskL.tif'));
maskC = logical(imread('imaskC.tif'));
maskD = logical(imread('imaskD.tif'));

[f c] = size(ims{1});

figure(1);
subplot(211); plot(ims{5}(:, round(c/2)), 'm'); title('Perfil objeto');
subplot(212); plot(ref{1}(:, round(c/2)), 'r'); title('Perfil referencia');


%% WRAPPING PHASE
fenvL = WrapTan4Pasos(ims{1}, ims{2}, ims{3}, ims{4});
fenvC = WrapTan4Pasos(ims{5}, ims{6}, ims{7}, ims{8});
fenvD = WrapTan4Pasos(ims{9}, ims{10}, ims{11}, ims{12});
fenvR = WrapTan4Pasos(ref{1}, ref{2}, ref{3}, ref{4});

[fenvL,  fenvC, fenvD, fenvRL, fenvRC, fenvRD ] = Mask(fenvL, fenvC, fenvD, fenvR, fenvR, fenvR, maskL, maskC, maskD);
[fenvL, fenvC, fenvD, fenvRL, fenvRC, fenvRD] = MaskNaN(fenvL, fenvC, fenvD, fenvRL, fenvRC, fenvRD, maskL, maskC, maskD);

% figure(2);
% subplot(231); imagesc(fenvL); colormap gray; colorbar;
% subplot(232); imagesc(fenvC); colormap gray; colorbar;
% subplot(233); imagesc(fenvD); colormap gray; colorbar;
% subplot(234); imagesc(fenvRL); colormap gray; colorbar;
% subplot(235); imagesc(fenvRC); colormap gray; colorbar;
% subplot(236); imagesc(fenvRD); colormap gray; colorbar;

fenvL = imcrop(fenvL, [170 390 250 730]);
fenvRL = imcrop(fenvRL, [170 390 250 730]);
fenvC = imcrop(fenvC, [135 245 250 730]);
fenvRC = imcrop(fenvRC, [135 245 250 730]);
fenvD = imcrop(fenvD, [170 390 250 730]);
fenvRD = imcrop(fenvRD, [170 390 250 730]);

figure(3);
subplot(231); imagesc(fenvL); colormap gray; colorbar; title('Izquierda');
subplot(232); imagesc(fenvC); colormap gray; colorbar; title('Central');
subplot(233); imagesc(fenvD); colormap gray; colorbar; title('Derecha');
subplot(234); imagesc(fenvRL); colormap gray; colorbar; 
subplot(235); imagesc(fenvRC); colormap gray; colorbar;
subplot(236); imagesc(fenvRD); colormap gray; colorbar;


%% UNWRAPPING PHASE
fdesL = UnwrapMedio(fenvL);
fdesRL = UnwrapMedio(fenvRL);
fdesC = UnwrapMedio(fenvC);
fdesRC = UnwrapMedio(fenvRC);
fdesD = UnwrapMedio(fenvD);
fdesRD = UnwrapMedio(fenvRD);

% figure(4);
% subplot(231); imagesc(fdesL); colormap gray; colorbar;
% subplot(232); imagesc(fdesC); colormap gray; colorbar;
% subplot(233); imagesc(fdesD); colormap gray; colorbar;
% subplot(234); imagesc(fdesRL); colormap gray; colorbar;
% subplot(235); imagesc(fdesRC); colormap gray; colorbar;
% subplot(236); imagesc(fdesRD); colormap gray; colorbar;

zL = fdesL - fdesRL;
zC = fdesC - fdesRC;
zD = fdesD - fdesRD;

fs = FactorEscalamiento(zL, zC, zD);
zL = imresize(zL, fs + 0.003);
zD = imresize(zD, fs - 0.007);
zL = imcrop(zL, [10 1 250 730]);
zD = imcrop(zD, [5 1 250 730]);
fs = FactorEscalamiento(zL, zC, zD);

zD = medfilt2(zD, [9 9]);
zL = medfilt2(zL, [9 9]);

figure(5);
subplot(131); imagesc(zL); colormap gray; colorbar; title('Izquierda');
subplot(132); imagesc(zC); colormap gray; colorbar; title('Central');
subplot(133); imagesc(zD); colormap gray; colorbar; title('Derecha');

[f c] = size(fdesL);
figure(6);
subplot(331); plot(fdesL(:, round(c/2)), 'm'); xlabel('Pixel'); ylabel('Intensidad'); title('Izquierda');
subplot(332); plot(fdesRL(:, round(c/2)), 'm'); xlabel('Pixel'); ylabel('Intensidad'); title('Referencia I.');
subplot(333); mesh(zL); colormap jet; title('Izquierda'); xlabel('x'); ylabel('y'); zlabel('z');
subplot(334); plot(fdesC(:, round(c/2)), 'm'); xlabel('Pixel'); ylabel('Intensidad'); title('Central');
subplot(335); plot(fdesRC(:, round(c/2)), 'm'); xlabel('Pixel'); ylabel('Intensidad'); title('Referencia C.');
subplot(336); mesh(zC); colormap jet; title('Central'); xlabel('x'); ylabel('y'); zlabel('z');
subplot(337); plot(fdesD(:, round(c/2)), 'm'); xlabel('Pixel'); ylabel('Intensidad'); title('Derecha');
subplot(338); plot(fdesRD(:, round(c/2)), 'm'); xlabel('Pixel'); ylabel('Intensidad'); title('Referencia D.');
subplot(339); mesh(zD); colormap jet; title('Derecha'); xlabel('x'); ylabel('y'); zlabel('z');