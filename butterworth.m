function [ im_filtered ] = butterworth(im, FrecuenciaCorte, orden)

PQ = paddedsize(size(im));
D0 = FrecuenciaCorte * PQ(1);
H = lpfilter('btw', PQ(1), PQ(2), D0, orden);
F = fft2(im, size(H, 1), size(H, 2));
LPF_im = real(ifft2(H .* F));
LPF_im = LPF_im(1 : size(im, 1), 1 : size(im, 2));
im_filtered = LPF_im;
end

