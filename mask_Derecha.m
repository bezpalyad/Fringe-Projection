clear, clc, close all
img = imread('imascaras.tif');
subplot(2,2,1); imshow(img); title('original');

umb = graythresh(img);
imgBin = im2bw(img, 0.3);
imgBin = imfill(imgBin, 'holes');

% elimina porcion no deseada
imgBin(1548:end, 2100:end) = 0;
% imgBin(1715:end, 2157:2285) = 0;

subplot(2,2,2); imagesc(imgBin); title('Binariazada');

[L Ne] = bwlabel(imgBin);
propied = regionprops(L);
hold on

for n = 1:size(propied,1)
    rectangle('Position', propied(n).BoundingBox, 'EdgeColor', 'g', 'LineWidth', 2);
end

pause(1);

s = find([propied.Area] < 500000); % busca areas menores a 500
for n = 1:size(s,2)
    rectangle('Position', propied(s(n)).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
end

% elimina areas menores al valor establecido
for n = 1:size(s,2)
    d = round(propied(s(n)).BoundingBox);
    imgBin(d(2):d(2)+d(4), d(1):d(1)+d(3)) = 0;
end

imgBin = imcrop(imgBin, [3000-1000 100 799 1799]);
%imgBin = not(imgBin);
imwrite(imgBin, 'mascaraDerecha.tif', 'tif');
subplot(2,2,3); imshow(imgBin); title('Mascara Derecha');
figure; imshow(imgBin);