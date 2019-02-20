clear all, close all, clc

cR = cell(4); iR = cell(4); dR = cell(4); rcR = cell(4); riR{4} = cell(4); rdR{4} = cell(4);
ruta = 'C:\Users\files\a90_f110_t20\';

for i = 1 : 4
    iR{i} = imcrop(im2double(imread(strcat(ruta, 'ii', int2str(i-1), '.tif'))), [1 400 344 799]);
    riR{i} = imcrop(im2double(imread(strcat(ruta, 'ri', int2str(i-1), '.tif'))), [1 400 344 799]);
    
    cR{i} = imcrop(im2double(imread(strcat(ruta, 'ic', int2str(i-1), '.tif'))), [345 400 344 799]);
    rcR{i} = imcrop(im2double(imread(strcat(ruta, 'rc', int2str(i-1), '.tif'))), [345 300 344 799]);
    
    dR{i} = imcrop(im2double(imread(strcat(ruta, 'id', int2str(i-1), '.tif'))), [1040-345 400 344 799]);
    rdR{i} = imcrop(im2double(imread(strcat(ruta, 'rd', int2str(i-1), '.tif'))), [1040-345 400 344 799]);
end
maskC = imread(strcat(ruta, 'mascara.tif'));
maskI = imread(strcat(ruta, 'mascaraIzquierda.tif'));
maskD = imread(strcat(ruta, 'mascaraDerecha.tif'));
[f c] = size(cR{1});

% Grafica perfil
%  figure(1);
%  subplot(321); plot(iR{1}(:, round(c/2) - 70), 'm'); xlabel('Pixel'); ylabel('Intensidad'); title('Izquierda');
%  subplot(322); plot(riR{1}(:, round(c/2) - 70), 'm'); xlabel('Pixel'); ylabel('Intensidad'); title('Referencia I.');
%  subplot(323); plot(cR{1}(:, round(c/2)), 'r'); xlabel('Pixel'); ylabel('Intensidad'); title('Frontal');
%  subplot(324); plot(rcR{1}(:, round(c/2)), 'r'); xlabel('Pixel'); ylabel('Intensidad'); title('Referencia F.');
%  subplot(325); plot(dR{1}(:, round(c/2) + 70), 'b'); xlabel('Pixel'); ylabel('Intensidad'); title('Derecha');
%  subplot(326); plot(rdR{1}(:, round(c/2) + 70), 'b'); xlabel('Pixel'); ylabel('Intensidad'); title('Referencia D.');
 
 
%% ENVUELVE FASE
fEnvI = h4(iR{1}, iR{2}, iR{3}, iR{4});
fEnvC = h4(cR{1}, cR{2}, cR{3}, cR{4});
fEnvD = h4(dR{1}, dR{2}, dR{3}, dR{4});
fEnvRI = h4(rcR{1}, rcR{2}, rcR{3}, rcR{4});
fEnvRC = h4(rcR{1}, rcR{2}, rcR{3}, rcR{4});
fEnvRD = h4(rcR{1}, rcR{2}, rcR{3}, rcR{4});

[ fEnvI,  fEnvC, fEnvD, fEnvRI, fEnvRC, fEnvRD ] = Mask(fEnvI,  fEnvC, fEnvD, fEnvRI, fEnvRC, fEnvRD, maskI, maskC, maskD);
[ fEnvI,  fEnvC, fEnvD, fEnvRI, fEnvRC, fEnvRD ] = MaskNaN( fEnvI,  fEnvC, fEnvD, fEnvRI, fEnvRC, fEnvRD, maskI, maskC, maskD); 

% % Grafica fase envuelta
% figure(2);
% subplot(321); plot(fEnvI(:, round(c/2) - 70), 'm'); xlabel('Pixel'); ylabel('Intensidad'); title('Izquierda');
% subplot(322); plot(fEnvRI(:, round(c/2) - 70), 'm'); xlabel('Pixel'); ylabel('Intensidad'); title('Referencia I.');
% subplot(323); plot(fEnvC(:, round(c/2)), 'r'); xlabel('Pixel'); ylabel('Intensidad'); title('Frontal');
% subplot(324); plot(fEnvRC(:, round(c/2)), 'r'); xlabel('Pixel'); ylabel('Intensidad'); title('Referencia F.');
% subplot(325); plot(fEnvD(:, round(c/2) + 70), 'b'); xlabel('Pixel'); ylabel('Intensidad'); title('Derecha');
% subplot(326); plot(fEnvRD(:, round(c/2) + 70), 'b'); xlabel('Pixel'); ylabel('Intensidad'); title('Referencia D.');

figure;
imagesc(fEnvI)
axis off
colorbar
colormap gray
h = colorbar;
set(get(h,'ylabel'),'String', '\Psi (rad)');
set(get(h,'ylabel'),'FontSize', 15);
figure;
imagesc(fEnvC)
axis off
colorbar
colormap gray
h = colorbar;
set(get(h,'ylabel'),'String', '\Psi (rad)');
set(get(h,'ylabel'),'FontSize', 15);
figure;
imagesc(fEnvD)
axis off
colorbar
colormap gray
h = colorbar;
set(get(h,'ylabel'),'String', '\Psi (rad)');
set(get(h,'ylabel'),'FontSize', 15);

%% DESENVULVE FASE
unwI = UnwrapMedio(fEnvI);
unwRI = UnwrapMedio(fEnvRI);
unwC = UnwrapMedio(fEnvC);
unwRC = UnwrapMedio(fEnvRC);
unwD = UnwrapMedio(fEnvD);
unwRD = UnwrapMedio(fEnvRD);

% Diferencias de fase
zI = unwI - unwRI;
zC = unwC - unwRC;
zD = unwD - unwRD;

% Aplica filtro
zI = medfilt2(zI, [20 20]);
zC = medfilt2(zC, [20 20]);
zD = medfilt2(zD, [20 20]);

% Grafica fase desenvuelta
% figure(3);
% subplot(331); plot(unwI(:, round(c/2) - 70), 'm'); xlabel('Pixel'); ylabel('Intensidad'); title('Izquierda');
% subplot(332); plot(unwRI(:, round(c/2) - 70), 'm'); xlabel('Pixel'); ylabel('Intensidad'); title('Referencia I.');
% subplot(333); mesh(zI); xlabel('Pixeles'); ylabel('Pixeles'); zlabel('Fase (Rad)'); colormap jet; 
% subplot(334); plot(unwC(:, round(c/2)), 'r'); xlabel('Pixel'); ylabel('Intensidad'); title('Frontal');
% subplot(335); plot(unwRC(:, round(c/2)), 'r'); xlabel('Pixel'); ylabel('Intensidad'); title('Referencia F.');
% subplot(336); mesh(zC); xlabel('Pixeles'); ylabel('Pixeles'); zlabel('Fase (Rad)');
% subplot(337); plot(unwD(:, round(c/2) + 70), 'b'); xlabel('Pixel'); ylabel('Intensidad'); title('Derecha');
% subplot(338); plot(unwRD(:, round(c/2) + 70), 'b'); xlabel('Pixel'); ylabel('Intensidad'); title('Referencia D.');
% subplot(339); mesh(zD); xlabel('Pixeles'); ylabel('Pixeles'); zlabel('Fase (Rad)');

%% FACTOR DE ESCALAMIENTO
fs = FactorEscalamiento(zI, zC, zD);
topiEsc = imresize(zI, fs + .0062);
topdEsc = imresize(zD, fs - 0.0062);
zI = imcrop(topiEsc, [1 50 344 799]);
zD = imcrop(topdEsc, [441-345 50 344 799 ]);
fs = FactorEscalamiento(zI, zC, zD);


%% CONVERSION DE FASE A X, Y, Z
% figure(4); 
% subplot(131); imshow(imread('cuadroIz.tif'));
% subplot(132); imshow(imread('cuadroFro.tif'));
% subplot(133); imshow(imread('cuadroDer.tif'));

P = 125.56 ; % distancia proyector a camara en mm
tamCuadro = 21.32;  % mm

% Izquierda
Li = 681; % 708 ref
fi = 20;    % numero de pixeles de pico a pico, referencia
pxi = 69;  % 55 pixeles mide el cuadro 55 ref
pix2mmi = tamCuadro / pxi;  % tamaño pixel en mm
ti = fi * pix2mmi;          % periodo de franjas en mm
thetaI = atan(P / Li);
zI = (zI ./ (2 * pi)) .* (ti / (tan(thetaI)));
yI = 0 : pix2mmi : (pix2mmi * (f - 1));
xI = 0 : pix2mmi : (pix2mmi * (c - 1));
yI = yI - (max(yI) / 2);
xI = xI - (max(xI) / 2);
[xI, yI] = meshgrid(xI, yI);

% Frontal
Lc = 681; % distancia  plano referencia centro a camara
fc = 20;
pxc = 69;
pix2mmc = tamCuadro / pxc;
tc = fc * pix2mmc;
thetaC = atan(P / Lc);
zC = (zC ./ (2 * pi)) .* (tc / (tan(thetaC)));
yC = 0 : pix2mmc : (pix2mmc * (f - 1));
xC = 0 : pix2mmc : (pix2mmc * (c - 1));
yC = yC - (max(yC) / 2);
xC = xC - (max(xC) / 2);
[xC, yC] = meshgrid(xC, yC);

% Derecha
Ld = 681;
fd = 20;
pxd = 69;
pix2mmd = tamCuadro / pxd;
td = fd * pix2mmd;
thetaD = atan(P / Ld);
zD = (zD ./ (2 * pi)) .* (td / (tan(thetaD)));
yD = 0 : pix2mmd : (pix2mmd * (f - 1));
xD = 0 : pix2mmd : (pix2mmd * (c - 1));
yD = yD - (max(yD) / 2);
xD = xD - (max(xD) / 2);
[xD, yD] = meshgrid(xD, yD);

figure(5); 
subplot(2,2,1); mesh(xI, yI, zI); colormap jet; xlabel('X mm'); ylabel('Y mm'); zlabel('Z mm'); title('Izquierda');
subplot(2,2,2); mesh(xC, yC, zC); colormap jet; xlabel('X mm'); ylabel('Y mm'); zlabel('Z mm'); title('Central');
subplot(2,2,3); mesh(xD, yD, zD); colormap jet; xlabel('X mm'); ylabel('Y mm'); zlabel('Z mm'); title('Derecha');

alturaC = max(max(zC)) + abs(min(min(zC)));
alturaI = max(max(zI)) + abs(min(min(zI)));
alturaD = max(max(zD)) + abs(min(min(zD)));
fprintf('\n\tI = %f mm --   C = %f mm --   D = %f mm', alturaI, alturaC, alturaD);

% y z x
[Xri, Yri, Zri] = AngulosEuler(deg2rad(120), deg2rad(0), deg2rad(0), 25, 0, -46.8, xI, yI, zI);
[Xrd, Yrd, Zrd] = AngulosEuler(deg2rad(-120), deg2rad(0), deg2rad(0), -28, 0, -45, xD, yD, zD);
npC = [xC(:) yC(:) zC(:)];
npI = [Xri(:) Yri(:) Zri(:)];
npD = [Xrd(:) Yrd(:) Zrd(:)];

npC = pointCloud(npC);
npI = pointCloud(npI);
npD = pointCloud(npD);

ptcOut = pcmerge(npC, npI, 0.01);
ptcOut = pcmerge(ptcOut, npD, 0.01);
figure(3); pcshow(ptcOut);
xlabel('X')
ylabel('Y')
zlabel('Z')
pcwrite(ptcOut, 'bote.ply');

pc = ptcOut;
eX = abs(pc.XLimits(1)) + abs(pc.XLimits(2)-5.1);
rX = 72.9;
eY = (abs(pc.YLimits(1)) + abs(pc.YLimits(2))-2.75);
rY = 195;
eZ = (abs(pc.ZLimits(1)) + abs(pc.ZLimits(2))-5.1);
rZ = 72.9;
eaX = eX - rX;
eaY = eY - rY;
eaZ = eZ - rZ;
erX = (eaX / rX) * 100;
erY = (eaY / rY) * 100;
erZ = (eaZ / rZ) * 100;
sprintf('X = %f mm\nY = %f mm\nZ = %f mm\n', eX, eY, eZ)
sprintf('----------------------------------------------\n\t\t\t\t\tERRORES\n----------------------------------------------\nError absoluto\t\t\t\t\tError relativo\nX = %f mm\t\t\t\t\t%f %%\nY = %f mm\t\t\t\t\t%f %%\nZ = %f mm\t\t\t\t\t%f %%', eaX, erX, eaY, erY, eaZ, erZ)

% % 
% % 
% % % ICP
% % npI = pointCloud([xI(:), yI(:), zI(:)]);
% % npC = pointCloud([xC(:), yC(:), zC(:)]);
% % npD = pointCloud([xD(:), yD(:), zD(:)]);
% % % 
% % % npI = pcdenoise(npI);
% % % npC = pcdenoise(npC);
% % % npD = pcdenoise(npD);
% % % 
% % % npI = pcdownsample(npI, 'gridAverage', 0.3);
% % % npC = pcdownsample(npC, 'gridAverage', 0.3);
% % % npD = pcdownsample(npD, 'gridAverage', 0.3);
% % % 
% % % [tform, movingReg, rmse] = pcregrigid( npI, npC, 'Extrapolate',true);
% % % figure;subplot(121); pcshowpair(npC, npC);
% % % subplot(122); pcshowpair(npC, movingReg);
% % % 
% % % ang = deg2rad(120);
% % % R120 = [cos(ang) 0 -sin(ang) 0;
% % %             0    1      0    0;
% % %         sin(ang) 0  cos(ang) 0;
% % %           0 0 0 1];
% % % tform1 = affine3d(R120);
% % % npI = pctransform(movingReg, tform1);
% % % figure; pcshowpair(npC, npI);
