function [ fEnvI,  fEnvC, fEnvD, fEnvRI, fEnvRC, fEnvRD ] = MaskNaN( fEnvI,  fEnvC, fEnvD, fEnvRI, fEnvRC, fEnvRD, maskI, maskC, maskD)

[f, c] = size(fEnvI);

for i = 1 : f
    for j = 1: c
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

end

