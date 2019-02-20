function [ wraped ] = WrapTan4Pasos( i0, i1, i2, i3 )

[r c] = size(i0);
wraped = zeros(r,c);

for i = 1:r
    for j = 1:c
        Y = i0(i,j) - i2(i,j);
        X = i3(i,j) - i1(i,j);
        wraped(i,j) = atan2(Y, X);
    end
end

end

