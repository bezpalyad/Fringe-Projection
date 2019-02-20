function [ fEnvI,  fEnvC, fEnvD, fEnvRI, fEnvRC, fEnvRD] = Mask( fEnvI,  fEnvC, fEnvD, fEnvRI, fEnvRC, fEnvRD, maskI, maskC, maskD)

fEnvI = fEnvI .* maskI;
fEnvC = fEnvC .* maskC;
fEnvD = fEnvD .* maskD;
fEnvRI = fEnvRI .* maskI;
fEnvRC = fEnvRC .* maskC;
fEnvRD = fEnvRD .* maskD;

end

