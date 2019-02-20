clear; close all; clc;

ims = cell(4); ref = cell(4);
imd = cell(4);

for i = 1 : 4
    ims{i} = im2double(imread(strcat('i', int2str(i+3), '.tif')));
    ref{i} = im2double(imread(strcat('ref', int2str(i+3), '.tif')));
    imd{i} = im2double(imread(strcat('id', int2str(i+3), '.tif')));
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
fenvR1 = WrapTan4Pasos(ref{1}, ref{2}, ref{3}, ref{4});
fenvOD = WrapTan4Pasos(imd{1}, imd{2}, imd{3}, imd{4});

mask = logical(imread('imaskC.tif'));
mask = bwareaopen(mask,1000);
se = strel('disk',100);
mask = imclose(mask,se);
% figure(3); imshow(mask);
maskDesp = logical(imread('idmaskC.tif'));
maskDesp = bwareaopen(maskDesp,1000);
se = strel('disk',3);
maskDesp = imclose(maskDesp,se);
% figure(3); imshow(maskDesp);
fenvO = maskNaN(fenvO, mask);
fenvR = maskNaN(fenvR1, mask);
fenvOD = maskNaN(fenvOD, maskDesp);
fenvRD = maskNaN(fenvR1, maskDesp);

% figure(4);
% subplot(221); imagesc(fenvO); colormap gray; colorbar; h = colorbar; set(get(h,'ylabel'),'String', '\Psi'); set(get(h,'ylabel'),'FontSize', 15); axis off;
% subplot(222); plot(fenvO(:, round(c/2)), 'm'); title('Perfil objeto');
% subplot(223); imagesc(fenvR); colormap gray; colorbar;  h = colorbar; set(get(h,'ylabel'),'String', '\Psi'); set(get(h,'ylabel'),'FontSize', 15); axis off;
% subplot(224); plot(fenvR(:, round(c/2)), 'r'); title('Perfil referencia');

%% UNWRAP
fdesO = UnwrapMedio(fenvO);
fdesR = UnwrapMedio(fenvR);
fdesOD = UnwrapMedio(fenvOD);
fdesRD = UnwrapMedio(fenvRD);
z = fdesO - fdesR;
z2 = fdesOD - fdesRD;
z = medfilt2(z, [25 25]);
z2 = medfilt2(z2, [13 13]);

z = imcrop(z, [180, 170, 165, 770]);
z2 = imcrop(z2, [240, 1, 165, 770]);
z(isnan(z)) = min(min(z));
z2(isnan(z2)) = min(min(z2));
% % znorm = z/max(abs(z(:)));
% % z2norm = z2/max(abs(z2(:)));
% z = z - (max(max(z)/2));
% z2 = z2 - (max(max(z2)/2));
% zdesp = z2 - z;

figure(2);
subplot(121); imagesc(z); colorbar; colormap jet; h = colorbar; set(get(h,'ylabel'),'String', '\Phi'); set(get(h,'ylabel'),'FontSize', 15); axis off;
subplot(122); imagesc(z2); colorbar; colormap jet; h = colorbar; set(get(h,'ylabel'),'String', '\Phi'); set(get(h,'ylabel'),'FontSize', 15); axis off;


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
z2 = (z2 ./ (2 * pi)) .* (t / (tan(theta)));
y = 0 : pix2mm : (pix2mm * (f - 1));
x = 0 : pix2mm : (pix2mm * (c - 1));
% y = y - (max(y) / 2);
% x = x - (max(x) / 2);
[x, y] = meshgrid(x, y);
z = z-(min(min(z)));
z2 = z2-(min(min(z2)));
zdesp = z2-z;

[f,c] = size(z);
y = 0 : pix2mm : (pix2mm * (f - 1));
x = 0 : pix2mm : (pix2mm * (c - 1));
[x, y] = meshgrid(x, y);

zdesp = medfilt2(zdesp, [20 20]);

% figure(2);
% subplot(231); mesh(x,y,z); colorbar; colormap jet; h = colorbar; set(get(h,'ylabel'),'String', 'Z(mm)'); set(get(h,'ylabel'),'FontSize', 15);  title('\phi_{a}'); xlabel('X(mm)'); ylabel('Y(mm)'); zlabel('z(mm)'); view(0,-90); grid off;
% subplot(232); mesh(x,y,z2); colorbar; colormap jet; h = colorbar; set(get(h,'ylabel'),'String', 'Z(mm)'); set(get(h,'ylabel'),'FontSize', 15); title('\phi_{d}'); xlabel('X(mm)'); ylabel('Y(mm)'); zlabel('z(mm)'); view(0,-90); grid off;
% subplot(233); mesh(x,y,zdesp); colorbar; colormap jet; h = colorbar; set(get(h,'ylabel'),'String', 'Z(mm)'); set(get(h,'ylabel'),'FontSize', 15); title('\deltah'); xlabel('X(mm)'); ylabel('Y(mm)'); zlabel('z(mm)'); view(0,-90); grid off;

def = zdesp(:, 123);
def = def(1:700);
yy = y(:);
yy = yy(1:700);
def = def - 1.8;

e = zdesp./29.6;

% Defaults
width = 4;     % Width in inches
height = 4.5;    % Height in inches
alw = 0.75;    % AxesLineWidth
fsz = 15;      % Fontsize
lw = 1.5;      % LineWidth
msz = 5;       % MarkerSize

figure(4);
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
mesh(x,y,zdesp,'LineWidth',lw,'MarkerSize',msz);
colorbar; colormap jet;
h = colorbar;
set(get(h,'ylabel'),'String', '\delta{z}(mm)');
set(get(h,'ylabel'),'FontSize', 15); 
set(get(h,'ylabel'),'FontWeight', 'bold');
xlabel('X(mm)','FontSize', fsz,'FontWeight', 'bold');
ylabel('Y(mm)','FontSize', fsz,'FontWeight', 'bold'); 
view(0,-90); grid off; 

% Set Tick Marks
set(gca,'XTick',0:5:c);
set(gca,'YTick',0:30:f);
% Here we preserve the size of the image when we save it.
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);

% Save the file as PNG
print('desplazamientos','-dpng','-r300');




% figure(5);
% pos = get(gcf, 'Position');
% set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
% set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
% plot(yy(1:15:end), def(1:15:end), 'd','LineWidth',lw,'MarkerSize',msz); hold on;
% yi = polyfit(yy,def,1);
% f = polyval(yi, yy);
% plot(yy, f, 'k','LineWidth',lw,'MarkerSize',msz); xlabel('Y (mm)');  ylabel('Disp. Z (mm)');
% txt = sprintf('y = %.3fx + %.3f', yi(1), yi(2));
% legend({'Experimental value', 'Lest-squares fitting line'}, 'FontSize',8, 'Location', 'southeast');
% text(20, 5, txt, 'FontSize', 12);
% 
% % Set Tick Marks
% set(gca,'XTick',0:20:120);
% set(gca,'YTick',0:1:6);
% 
% % Here we preserve the size of the image when we save it.
% set(gcf,'InvertHardcopy','on');
% set(gcf,'PaperUnits', 'inches');
% papersize = get(gcf, 'PaperSize');
% left = (papersize(1)- width)/2;
% bottom = (papersize(2)- height)/2;
% myfiguresize = [left, bottom, width, height];
% set(gcf,'PaperPosition', myfiguresize);
% 
% % Save the file as PNG
% print('unwo','-dpng','-r300');
% 
% 
% % 
% % % [Gx, Gy] = imgradientxy(zdesp);
% % % figure(4); 
% % % subplot(221); mesh(x,y,Gx); colorbar; colormap jet; h = colorbar; set(get(h,'ylabel'),'String', 'Z(mm)'); set(get(h,'ylabel'),'FontSize', 15);  title('Gx'); xlabel('X(mm)'); ylabel('Y(mm)'); zlabel('z(mm)'); view(0,-90); grid off;
% % % subplot(222); mesh(x,y,Gy); colorbar; colormap jet; h = colorbar; set(get(h,'ylabel'),'String', 'Z(mm)'); set(get(h,'ylabel'),'FontSize', 15);  title('Gy'); xlabel('X(mm)'); ylabel('Y(mm)'); zlabel('z(mm)'); view(0,-90); grid off;
% % % [Gmag, Gdir] = imgradient(Gx, Gy);
% % % subplot(223); mesh(x,y,Gmag); colorbar; colormap jet; h = colorbar; set(get(h,'ylabel'),'String', 'Z(mm)'); set(get(h,'ylabel'),'FontSize', 15);  title('Gmag'); xlabel('X(mm)'); ylabel('Y(mm)'); zlabel('z(mm)'); view(0,-90); grid off;
% % % subplot(224); mesh(x,y,Gdir); colorbar; colormap jet; h = colorbar; set(get(h,'ylabel'),'String', 'Z(mm)'); set(get(h,'ylabel'),'FontSize', 15);  title('Gdir'); xlabel('X(mm)'); ylabel('Y(mm)'); zlabel('z(mm)'); view(0,-90); grid off;
% % 

% % 
% % 
% % % pc1 = pointCloud([x(:) y(:) z(:)]);
% % % pc2 = pointCloud([x(:) y(:) z2(:)]);
% % % eX = abs(pc1.XLimits(1)) + abs(pc1.XLimits(2));
% % % eY = (abs(pc1.YLimits(1)) + abs(pc1.YLimits(2)));
% % % eZ = (abs(pc1.ZLimits(1)) + abs(pc1.ZLimits(2)));
% % % eX2 = abs(pc2.XLimits(1)) + abs(pc2.XLimits(2));
% % % eY2 = (abs(pc2.YLimits(1)) + abs(pc2.YLimits(2)));
% % % eZ2 = (abs(pc2.ZLimits(1)) + abs(pc2.ZLimits(2)));
% % % sprintf('X = %f mm\nY = %f mm\nZ = %f mm\n', eX, eY, eZ)
% % % sprintf('X = %f mm\nY = %f mm\nZ = %f mm\n', eX2, eY2, eZ2)
% % % figure(7); pcshow(pc1); xlabel('X mm'); ylabel('Y mm'); zlabel('Z mm'); colorbar; view(0,90);
% % % figure(8); pcshow(pc2); xlabel('X mm'); ylabel('Y mm'); zlabel('Z mm'); colorbar; view(0,90);
% % % %%
% % % 
