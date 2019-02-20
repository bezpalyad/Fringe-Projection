function [ Xrt, Yrt, Zrt ] = AngulosEuler( psi, chi, phi, Lx, Ly, Lz, x, y, z )

a = [cos(psi) * cos(chi), -cos(psi) * sin(chi), sin(psi);
     cos(phi) * sin(chi) + sin(phi) * sin(psi) * cos(chi), cos(phi) * cos(chi) - sin(phi) * sin(psi) * sin(chi), -sin(phi) * cos(psi);
     sin(phi) * sin(chi) - cos(phi) * sin(psi) * cos(chi), sin(phi) * cos(chi) + cos(phi) * sin(psi) * sin(chi), cos(phi) * cos(psi)];
 
Xrt = a(1,1) * x + a(1,2) * y + a(1,3) * z + Lx;
Yrt = a(2,1) * x + a(2,2) * y + a(2,3) * z + Ly;
Zrt = a(3,1) * x + a(3,2) * y + a(3,3) * z + Lz;

end

