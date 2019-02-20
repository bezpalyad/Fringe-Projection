function [ unwrapped ] = UnwrapMedio( fase )

Fa_env = fase;
[fila, columnas] = size(Fa_env);
Fa_desv = zeros(fila, columnas);

for m = round(columnas / 2) : 1 : columnas - 1
    Fa_desv(round(fila / 2), m + 1) = Fa_desv(round(fila / 2), m) + (angle(exp(1i * (Fa_env(round(fila / 2), m + 1) - Fa_desv(round(fila / 2), m)))));
end

for m = round(columnas / 2) : -1 : 2
    Fa_desv(round(fila / 2), m - 1) = Fa_desv(round(fila / 2), m) + (angle(exp(1i * (Fa_env(round(fila / 2), m - 1) - Fa_desv(round(fila / 2), m)))));
end

for m = 1 : 1 : columnas 
    for k = round(fila / 2) : -1 : 2
        Fa_desv(k - 1, m) = Fa_desv(k, m) + (angle(exp(1i * (Fa_env(k - 1, m) - Fa_desv(k, m)))));
    end
end

for m = 1 : 1 : columnas
    for k = round(fila / 2) : 1 : fila - 1
        Fa_desv(k + 1, m) = Fa_desv(k, m) + (angle(exp(1i * (Fa_env(k + 1, m) - Fa_desv(k, m)))));
    end
end

unwrapped = Fa_desv;
end

