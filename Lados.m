function [ largo, ancho ] = Lados( topografia )

topAux = topografia;
[f c] = size(topAux);

for i = 1 : f
    for j = 1 : c
        if isnan(topografia(i,j))
            topAux(i,j) = 0;
        else
            topAux(i,j) = 255;
        end
    end
end

topAux = im2bw(topAux, 0.5);

[L Ne] = bwlabel(topAux);
propied = regionprops(L);
largo = (propied.BoundingBox(2) + propied.BoundingBox(4)) - propied.BoundingBox(2);
ancho = (propied.BoundingBox(1) + propied.BoundingBox(3)) - propied.BoundingBox(1);

end

