clear; close all; clc;

ims = cell(4); ref = cell(4);

for i = 1 : 4
    ims{i} = im2double(imread(strcat('i', int2str(i+3), '.tif')));
    ref{i} = im2double(imread(strcat('ref', int2str(i+3), '.tif')));
end

[f c] = size(ims{1});

figure(1);
subplot(211); plot(ims{1}(:, round(c/2)), 'm'); title('Perfil objeto');
subplot(212); plot(ref{1}(:, round(c/2)), 'r'); title('Perfil referencia'); hold on;
[pv, pl] = findpeaks(ref{1}(:, round(c/2)), 'MinPeakHeight', 0.5);
plot(pl, pv, 'mo'); hold off; legend('Perfil', 'Pico');

for i = 1 : numel(pl) - 1
    dif(i) = pl(i+1) - pl(i);
end
med = median(dif);
sprintf('\t\t\t\t\t\t\t\tReferencia\nMediana = %f    Media = %f    Desv estandar = %f    Moda = %f', median(dif), mean(dif), std(dif), mode(dif))


%% WRAP
fenvO = WrapTan4Pasos(ims{1}, ims{2}, ims{3}, ims{4});
fenvR = WrapTan4Pasos(ref{1}, ref{2}, ref{3}, ref{4});

figure(2);
subplot(221); imagesc(fenvO); colormap gray; colorbar;
subplot(222); plot(fenvO(:, round(c/2)), 'm'); title('Perfil objeto');
subplot(223); imagesc(fenvR); colormap gray; colorbar;
subplot(224); plot(fenvR(:, round(c/2)), 'r'); title('Perfil referencia');


%% UNWRAP
mex Miguel_2D_unwrapper.cpp
fdesO = Miguel_2D_unwrapper(single(fenvO));
fdesR = Miguel_2D_unwrapper(single(fenvR));
fdesO = double(fdesO);
fdesR = double(fdesR);
z = fdesO - fdesR;

for i = 1 : f
    for j = 1 : c
        if z(i,j) <= -50.25
            z(i,j) = NaN;
        end
    end
end
z = medfilt2(z, [7 7]);
figure(3);
subplot(131); imagesc(fdesO); colormap gray; colorbar; title('Objeto');
subplot(132); imagesc(fdesR); colormap gray; colorbar; title('Referencia');
subplot(133); imagesc(z); colormap gray; colorbar; title('topografia');


%% X, Y, Z
P = 125.0 ; % distancia proyector a camara en mm
tamCuadro = 21.32;  % mm
L = 665.0;
fi = med; % pico a pico en pixeles
px = 125; % cuadro en pixeles
pix2mm = tamCuadro / px;
t = fi * pix2mm;          % periodo de franjas en mm
theta = atan(P / L);
z = (z ./ (2 * pi)) .* (t / (tan(theta)));
y = 0 : pix2mm : (pix2mm * (f - 1));
x = 0 : pix2mm : (pix2mm * (c - 1));
y = y - (max(y) / 2);
x = x - (max(x) / 2);
[x, y] = meshgrid(x, y);

% figure(4); 
% mesh(x, y, z); colormap summer; xlabel('X mm'); ylabel('Y mm'); zlabel('Z mm'); axis equal;


%% PC
np1 = pointCloud([x(:) y(:) z(:)]);
np2 = pointCloud([x(:) y(:) z(:)]);

ang = deg2rad(180);
RotY = [cos(ang) 0 -sin(ang) 0;
    0    1      0    0;
    sin(ang) 0  cos(ang) 0;
    -16.5 0 -202 1];
tform1 = affine3d(RotY);
np2 = pctransform(np2, tform1);

pc = pcmerge(np1, np2, 0.1);

figure(5); pcshow(pc); xlabel('X mm'); ylabel('Y mm'); zlabel('Z mm'); title('Nube de puntos');

sprintf('Numero de puntos = %d', pc.Count)
eX = abs(pc.XLimits(1)) + abs(pc.XLimits(2));
eY = (abs(pc.YLimits(1)) + abs(pc.YLimits(2)));
eZ = (abs(pc.ZLimits(1)) - abs(pc.ZLimits(2)));
sprintf('X = %f mm\nY = %f mm\nZ = %f mm', eX, eY, eZ)