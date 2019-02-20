clear all, close all, clc

cR = cell(4); iR = cell(4); dR = cell(4); rcR = cell(4); riR = cell(4); rdR = cell(4);

for i = 1 : 4
    cR{i} = imcrop(im2double(imread(strcat('ic', int2str(i-1), '.tif'))), [1100 100 799 1799]);
    iR{i} = imcrop(im2double(imread(strcat('ii', int2str(i-1), '.tif'))), [275 100 799 1799]);
    dR{i} = imcrop(im2double(imread(strcat('id', int2str(i-1), '.tif'))), [3000-1000 100 799 1799]);
    rcR{i} = imcrop(im2double(imread(strcat('irc', int2str(i-1), '.tif'))), [1100 100 799 1799]);
    riR{i} = imcrop(im2double(imread(strcat('iri', int2str(i-1), '.tif'))), [275 100 799 1799]);
    rdR{i} = imcrop(im2double(imread(strcat('ird', int2str(i-1), '.tif'))), [3000-1000 100 799 1799]);
end
maskC = imread('mascara.tif');
maskI = imread('mascaraIzquierda.tif');
maskD = imread('mascaraDerecha.tif');
[filas, columnas] = size(cR{1});

% figure(1); set(gcf, 'Name', 'Imagenes recortadas');
% subplot(231); imagesc(iR{1});
% subplot(232); imagesc(cR{1});
% subplot(233); imagesc(dR{1});
% subplot(234); imagesc(riR{1});
% subplot(235); imagesc(rcR{1});
% subplot(236); imagesc(rdR{1}); colormap gray;
% 
% figure(2); set(gcf, 'Name', 'Mascaras');
% subplot(131); imagesc(maskI);
% subplot(132); imagesc(maskC);
% subplot(133); imagesc(maskD); colormap gray;


%% ENVUELVE FASE
% objetos
fEnvI = WrapTan4Pasos(iR{1}, iR{2}, iR{3}, iR{4});
fEnvC = WrapTan4Pasos(cR{1}, cR{2}, cR{3}, cR{4});
fEnvD = WrapTan4Pasos(dR{1}, dR{2}, dR{3}, dR{4});
% referencias
fEnvRI = WrapTan4Pasos(riR{1}, riR{2}, riR{3}, riR{4});
fEnvRC = WrapTan4Pasos(rcR{1}, rcR{2}, rcR{3}, rcR{4});
fEnvRD = WrapTan4Pasos(rdR{1}, rdR{2}, rdR{3}, rdR{4});

% figure(3); set(gcf, 'Name', 'Fase envuelta'); 
% subplot(231); imagesc(fEnvI); colormap gray; colorbar;
% subplot(232); imagesc(fEnvC); colormap gray; colorbar;
% subplot(233); imagesc(fEnvD); colormap gray; colorbar;
% subplot(234); imagesc(fEnvRI); colormap gray; colorbar;
% subplot(235); imagesc(fEnvRC); colormap gray; colorbar;
% subplot(236); imagesc(fEnvRD); colormap gray; colorbar;


%% APLICA MASCARA
fEnvI = fEnvI .* maskI;
fEnvC = fEnvC .* maskC;
fEnvD = fEnvD .* maskD;
fEnvRI = fEnvRI .* maskI;
fEnvRC = fEnvRC .* maskC;
fEnvRD = fEnvRD .* maskD;

for i = 1 : filas
    for j = 1: columnas
        if maskI(i, j) == 0
            fEnvI(i, j) = NaN;
            fEnvRI(i, j) = NaN;
        else
            fEnvI(i, j) = fEnvI(i, j);
            fEnvRI(i, j) = fEnvRI(i, j);
        end
        
        if maskC(i, j) == 0
            fEnvC(i, j) = NaN;
            fEnvRC(i, j) = NaN;
        else
            fEnvC(i, j) = fEnvC(i, j);
            fEnvRC(i, j) = fEnvRC(i, j);
        end
        
        if maskD(i, j) == 0
            fEnvD(i, j) = NaN;
            fEnvRD(i, j) = NaN;
        else
            fEnvD(i, j) = fEnvD(i, j);
            fEnvRD(i, j) = fEnvRD(i, j);
        end
    end
end
% figure(4); set(gcf, 'Name', 'Aplica mascara');
% subplot(231); imagesc(fEnvI); colormap gray; colorbar;
% subplot(232); imagesc(fEnvC); colormap gray; colorbar; 
% subplot(233); imagesc(fEnvD); colormap gray; colorbar;
% subplot(234); imagesc(fEnvRI); colormap gray; colorbar;
% subplot(235); imagesc(fEnvRC); colormap gray; colorbar;
% subplot(236); imagesc(fEnvRD); colormap gray; colorbar;


%% DESENVUELVE MAPA DE FASE
unwI = UnwrapMedio(fEnvI);
unwRI = UnwrapMedio(fEnvRI);
unwC = UnwrapMedio(fEnvC);
unwRC = UnwrapMedio(fEnvRC);
unwD = UnwrapMedio(fEnvD);
unwRD = UnwrapMedio(fEnvRD);


%% DIFERENICIAS DE FASE PARA ASOCIAR LA TOPOGRAFIA
zI = unwI - unwRI;
zC = unwC - unwRC;
zD = unwD - unwRD;

h1 = fspecial('average', [7 7]);
zI = imfilter(zI, h1);
zC = imfilter(zC, h1);
zD = imfilter(zD, h1);
figure;
surf(fliplr(zC)), shading interp, view(155,60), colormap gray
axis off, axis tight, lightangle(0,100)


%% CONVERSION DE FASE A X, Y, Z
P = 154; % distancia proyector a camara 154 mm
tamCuadro = 21.46;  % mm

% Izquierda
Li = 750;
fi = 20;    % numero de pixeles de pico a pico, referencia
pxi = 134;  % 134 pixeles mide el cuadro
pix2mmi = tamCuadro / pxi;  % tamaño pixel en mm
ti = fi * pix2mmi;          % periodo de franjas en mm
thetaI = atan(P / Li);
zI = (zI ./ (2 * pi)) .* (ti / (tan(thetaI)));
yI = 0 : pix2mmi : (pix2mmi * (filas - 1));
xI = 0 : pix2mmi : (pix2mmi * (columnas - 1));
yI = yI - (max(yI) / 2);
xI = xI - (max(xI) / 2);
[xI, yI] = meshgrid(xI, yI);

% Frontal
Lc = 730; % distancia  plano referencia centro a camara
fc = 20;
pxc = 156;
pix2mmc = tamCuadro / pxc;
tc = fc * pix2mmc;
thetaC = atan(P / Lc);
zC = (zC ./ (2 * pi)) .* (tc / (tan(thetaC)));
yC = 0 : pix2mmc : (pix2mmc * (filas - 1));
xC = 0 : pix2mmc : (pix2mmc * (columnas - 1));
yC = yC - (max(yC) / 2);
xC = xC - (max(xC) / 2);
[xC, yC] = meshgrid(xC, yC);

% Derecha
Ld = 750;
fd = 20;
pxd = 134;
pix2mmd = tamCuadro / pxd;
td = fd * pix2mmd;
thetaD = atan(P / Ld);
zD = (zD ./ (2 * pi)) .* (td / (tan(thetaD)));
yD = 0 : pix2mmd : (pix2mmd * (filas - 1));
xD = 0 : pix2mmd : (pix2mmd * (columnas - 1));
yD = yD - (max(yD) / 2);
xD = xD - (max(xD) / 2);
[xD, yD] = meshgrid(xD, yD);


%% fs
largoC = 98.98+104.6;
largoI = 90.56 + 94.09;
largoD = 87.04 + 75.95;
fsI = largoC / largoI;
fsD = largoC / largoD;

yI = yI .* (fsI + 0.01);
yD = yD .* (fsD - 0.15);

% figure(5); 
% subplot(2,2,1); mesh(xI, yI, zI); colormap summer; xlabel('X mm'); ylabel('Y mm'); zlabel('Z mm'); title('Izquierda');
% subplot(2,2,2); mesh(xC, yC, zC); colormap summer; xlabel('X mm'); ylabel('Y mm'); zlabel('Z mm'); title('Central');
% subplot(2,2,3); mesh(xD, yD, zD); colormap summer; xlabel('X mm'); ylabel('Y mm'); zlabel('Z mm'); title('Derecha');

% n = 1440000;
% npI = [xI(:)'; yI(:)'; zI(:)'];
% npC = [xC(:)'; yC(:)'; zC(:)'];
% npD = [xD(:)'; yD(:)'; zD(:)'];
% 
% % Translation values (a.u.):
% Tx = -40;
% Ty = 0;
% Tz = 60;
% 
% % Translation vector
% T = [Tx; Ty; Tz];
% 
% % Rotation values (rad.):
% ry = deg2rad(120);
% Ry = [cos(ry) 0 sin(ry);
%       0 1 0;
%       -sin(ry) 0 cos(ry)];
%   
% Mp = Ry * npI + repmat(T, 1, n);

% Partial model point cloud
% X = reshape(xI, 1, []);
% Y = reshape(yI, 1, []);
% % Mp = M(:,Y>=0);
% 
% % Boundary of partial model point cloud
% b = (abs(X(Y>=0)) == 2) | (Y(Y>=0) == min(Y(Y>=0))) | (Y(Y>=0) == max(Y(Y>=0)));
% bound = find(b);
% 
% % Partial data point cloud
% % Dp = npC(:,X>=0);
% Dp = npC;
% 
% [Ricp Ticp ER t] = icp(Mp, Dp, 15, 'EdgeRejection', true, 'Boundary', bound, 'Matching', 'kDtree');
% 
% % Transform data-matrix using ICP result
% Dicp = Ricp * Dp + repmat(Ticp, 1, size(Dp,2));
% 
% % Plot model points blue and transformed points red
% figure;
% subplot(2,2,1);
% plot3(Mp(1,:),Mp(2,:),Mp(3,:),'bo',...
%       Dp(1,:),Dp(2,:),Dp(3,:),'r.')
% axis equal;
% xlabel('x'); ylabel('y'); zlabel('z');
% title('Red: Frontal, blue: Izquierda');
% 
% % Plot the results
% subplot(2,2,2);
% plot3(Mp(1,:),Mp(2,:),Mp(3,:),'bo',...
%       Dicp(1,:),Dicp(2,:),Dicp(3,:),'r.');
% axis equal;
% xlabel('x'); ylabel('y'); zlabel('z');
% title('ICP result');
% 
% % Plot RMS curve
% subplot(2,2,[3 4]);
% plot(0:15,ER,'--x');
% xlabel('iteration#');
% ylabel('d_{RMS}');
% legend('partial overlap');
% title(['Total elapsed time: ' num2str(t(end),2) ' s']);

% npI = pointCloud(npI);
% npC = pointCloud(npC);
% npD = pointCloud(npD);
% 
% npI = pcdenoise(npI);
% npC = pcdenoise(npC);
% npD = pcdenoise(npD);
% 
% npI = pcdownsample(npI, 'gridAverage', 0.3);
% npC = pcdownsample(npC, 'gridAverage', 0.3);
% npD = pcdownsample(npD, 'gridAverage', 0.3);
% 
% % Rotar izquierda sobre el eje Y
% ang = deg2rad(120);
% R120 = [cos(ang) 0 -sin(ang) 0;
%             0    1      0    0;
%         sin(ang) 0  cos(ang) 0;
%           -40 0 60 1];
% tform1 = affine3d(R120);
% % npI = pctransform(npI, tform1);
% 
% % Rotar derecha sobre eje Y
% ang2 = deg2rad(-120);
% R_120 = [cos(ang2) 0 -sin(ang2) 0;
%             0    1      0    0;
%         sin(ang2) 0  cos(ang2) 0;
%         -33 0 -65 1];
% tform2 = affine3d(R_120);
% npD = pctransform(npD, tform2);
% 
% % ICP
% moving = npI;
% fixed = npC;
% tform = pcregrigid(moving, fixed, 'InitialTransform', affine3d(R120), 'MaxIterations', 100);
% npI = pctransform(npI, tform);
% npCI = pcmerge(npC, npI, 0.3);
% pcshow(npCI);

% npCI = pcmerge(npC, npI, 0.3);
% pcshowpair(npCI, npD); xlabel('X'); ylabel('Y'); zlabel('Z')