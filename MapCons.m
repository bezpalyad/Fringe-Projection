function [ fd ] = MapCons( fe )
y0 = 0;
fd = fe;

[f, c] = size(fd);

for y = 1 : f
    if mod(y, 2) == 1
        if(y > 1)
            fd(y, 1) = fd(y - 1, 1);
        end
        for x = 1 : c - 1
            Vx = fe(y, x + 1) - fd(y, x);
            fd(y, x + 1) = fd(y, x) + atan(sin(Vx) / cos(Vx));
        end
    else
        fd(y, c) = fd(y - 1, c);
        for x = c : -1 : 2
            Vx = fe(y, x - 1) - fd(y, x);
            fd(y, x - 1) = fd(y, x) + atan(sin(Vx) / cos(Vx));
        end
    end
end

end

