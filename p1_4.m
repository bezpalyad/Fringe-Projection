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

mask = logical(imread('imaskC.tif'));
mask = bwareaopen(mask,1000);
se = strel('disk',3);
mask = imclose(mask,se);
% figure(3); imshow(mask);
fenvO = maskNaN(fenvO, mask);
fenvR = maskNaN(fenvR, mask);

figure(2);
subplot(221); imagesc(fenvO); colormap gray; colorbar; h = colorbar; set(get(h,'ylabel'),'String', '\Psi'); set(get(h,'ylabel'),'FontSize', 15); axis off;
subplot(222); plot(fenvO(:, round(c/2)), 'm'); title('Perfil objeto');
subplot(223); imagesc(fenvR); colormap gray; colorbar;  h = colorbar; set(get(h,'ylabel'),'String', '\Psi'); set(get(h,'ylabel'),'FontSize', 15); axis off;
subplot(224); plot(fenvR(:, round(c/2)), 'r'); title('Perfil referencia');


%% UNWRAP
fdesO = UnwrapMedio(fenvO);
fdesR = UnwrapMedio(fenvR);
z = fdesO - fdesR;
z = medfilt2(z, [5 5]);

figure(3);
subplot(131); imagesc(fdesO); colormap gray; colorbar; h = colorbar; title('Objeto'); set(get(h,'ylabel'),'String', '\Phi'); set(get(h,'ylabel'),'FontSize', 15); axis off;
subplot(132); imagesc(fdesR); colormap gray; colorbar; h = colorbar; title('Referencia'); set(get(h,'ylabel'),'String', '\Phi'); set(get(h,'ylabel'),'FontSize', 15); axis off;
subplot(133); imagesc(z); colormap gray; colorbar; h = colorbar; title('Topografia'); set(get(h,'ylabel'),'String', '\Phi'); set(get(h,'ylabel'),'FontSize', 15); axis off;


%% X, Y, Z
% figure(5);
% imshow(imread('tablero.tif'));
P = 125.0 ; % distancia proyector a camara en mm
tamCuadro = 21.32;  % mm
L = 655.0;
fi = med; % pico a pico en pixeles
px = 127; % cuadro en pixeles
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
for i = 1 : f
    for j = 1 : c
        if y(i,j) > 20.5
            z(i,j) = NaN;
        end
    end
end


%y z x
[xi, yi, zi] = AngulosEuler(deg2rad(120), deg2rad(0), deg2rad(0), 11.47, 0, -30.4, x, y, z);
[xd, yd, zd] = AngulosEuler(deg2rad(-120), deg2rad(0), deg2rad(0), -20.67, 0, -25.3, x, y, z);

% figure(4); 
% mesh(x, y, z); colormap summer; xlabel('X mm'); ylabel('Y mm'); zlabel('Z mm'); axis equal;
% hold on;
% mesh(xi, yi, zi); colormap jet; xlabel('X mm'); ylabel('Y mm'); zlabel('Z mm'); axis equal;
% mesh(xd, yd, zd); colormap jet; xlabel('X mm'); ylabel('Y mm'); zlabel('Z mm'); axis equal;

npC = pointCloud([x(:) y(:) z(:)]);
npI = pointCloud([xi(:) yi(:) zi(:)]);
npD = pointCloud([xd(:) yd(:) zd(:)]);

ptcOut = pcmerge(npC, npI, 0.001);
ptcOut = pcmerge(ptcOut, npD, 0.001);

pc = ptcOut;
eX = abs(pc.XLimits(1)) + abs(pc.XLimits(2));
rX = 40.5;
eY = (abs(pc.YLimits(1)) + abs(pc.YLimits(2)));
rY = 120
eZ = (abs(pc.ZLimits(1)) + abs(pc.ZLimits(2)));
rZ = 40.5;
eaX = eX - rX;
eaY = eY - rY;
eaZ = eZ - rZ;
erX = (eaX / rX) * 100;
erY = (eaY / rY) * 100;
erZ = (eaZ / rZ) * 100;
sprintf('X = %f mm\nY = %f mm\nZ = %f mm\n', eX, eY, eZ)
sprintf('----------------------------------------------\n\t\t\t\t\tERRORES\n----------------------------------------------\nError absoluto\t\t\t\t\tError relativo\nX = %f mm\t\t\t\t\t%f %%\nY = %f mm\t\t\t\t\t%f %%\nZ = %f mm\t\t\t\t\t%f %%', eaX, erX, eaY, erY, eaZ, erZ)


%%
d = 1160;
g = 9.81;
r0 = 0.0148;
e = 0.00007;
E = 874500;
z = linspace(0.0,0.12,5);

for i = 1 : numel(z);
    rz(i) = 1 + ((d*g*r0*z(i)) / (e*E)); 
end
rzexp = [1, 1.1 1.18 1.25 1.35];

% Defaults
width = 4;     % Width in inches
height = 3;    % Height in inches
alw = 0.75;    % AxesLineWidth
fsz = 15;      % Fontsize
lw = 1.5;      % LineWidth
msz = 8;       % MarkerSize

figure(5);
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
plot(z,rz, 'b-o', z,rzexp,'r-x',z,ones(1,numel(z)), 'k','LineWidth',lw,'MarkerSize',msz);
legend('Theoretical', 'Experimental');
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
ax.Box = 'off';
xlabel('y(m)', 'FontSize', 15); ylabel('r(y)/r', 'FontSize', 15); ylim([0 2]);
% Set Tick Marks
set(gca,'XTick',0:0.02:0.12);
set(gca,'YTick',0:0.2:2);

% Here we preserve the size of the image when we save it.
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);

% Save the file as PNG
print('unwo','-dpng','-r300');


figure(6); pcshow(ptcOut); grid off;

xlabel('X (mm)', 'FontSize', 15)
ylabel('Y (mm)', 'FontSize', 15)
zlabel('Z (mm)', 'FontSize', 15)
camproj('orthographic')

((r0 * max(rz))*100)*2



