clear, clc, close all
img = imread('imascaras.tif');
subplot(2,2,1); imshow(img); title('original');

umb = graythresh(img);
imgBin = im2bw(img, 0.3);
imgBin = imfill(imgBin, 'holes');

% elimina porcion no deseada
imgBin(1570:end, 466:end) = 0;
% imgBin(1715:end, 832:end) = 0;

subplot(2,2,2); imshow(imgBin); title('Binariazada');

[L Ne] = bwlabel(imgBin);
propied = regionprops(L);
hold on

for n = 1:size(propied,1)
    rectangle('Position', propied(n).BoundingBox, 'EdgeColor', 'g', 'LineWidth', 2);
end

pause(1);

s = find([propied.Area] < 400000); % busca areas menores a 500
for n = 1:size(s,2)
    rectangle('Position', propied(s(n)).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
end

% elimina areas menores al valor establecido
for n = 1:size(s,2)
    d = round(propied(s(n)).BoundingBox);
    imgBin(d(2):d(2)+d(4), d(1):d(1)+d(3)) = 0;
end

imgBin = imcrop(imgBin, [275 100 799 1799]);
%imgBin = not(imgBin);
imwrite(imgBin, 'mascaraIzquierda.tif', 'tif');
subplot(2,2,3); imshow(imgBin); title('Mascara Izquierda');
figure; imshow(imgBin);