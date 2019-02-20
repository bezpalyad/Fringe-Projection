function phase_e=h4(I1,I2,I3,I4)

w0=pi/2;
h4convs=I1-I2*(1+exp(-1i*w0)+exp(-2i*w0))+I3*(exp(-1i*w0)+exp(-2i*w0)+exp(-3i*w0))-I4*exp(-3i*w0);
phase_e=angle(h4convs);