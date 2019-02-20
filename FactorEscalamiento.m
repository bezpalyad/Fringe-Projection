function [ fs ] = FactorEscalamiento( topografiaI, topografiaC, topografiaD )

[largoC, anchoC] = Lados(topografiaC);
[largoI, anchoI] = Lados(topografiaI);
[largoD, anchoD] = Lados(topografiaD);

fs = largoC / largoI;

fprintf('largoC = %f -- anchoC = %f\nlargoI = %f -- anchoI = %f\nlargoD = %f -- anchoD = %f\nfs = %f\n', largoC, anchoC, largoI, anchoI, largoD, anchoD, fs);


end

