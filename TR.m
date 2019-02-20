function [ nptr ] = TR( np, n, Tx, Ty, Tz, rx, ry, rz )

% Translation vector
T = [Tx; Ty; Tz];

Rx = [1 0 0;
      0 cos(rx) -sin(rx);
      0 sin(rx) cos(rx)];
  
Ry = [cos(ry) 0 sin(ry);
      0 1 0;
      -sin(ry) 0 cos(ry)];
  
Rz = [cos(rz) -sin(rz) 0;
      sin(rz) cos(rz) 0;
      0 0 1];
  
  % Rotation matrix
R = Rx*Ry*Rz;

nptr = R * np + repmat(T, 1, n);
 
end

