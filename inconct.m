function [counter] = inconct(R, options)
%function [counter] = inconct(R, options)
%
% function for checking inconsistency in the phase map

NIVEL = options.fringe_jump_detect;

P1 = R;

P2 = R;
P2(:,1:end-1) = R(:,2:end);

P3 = R;
P3(1:end-1,1:end-1) = R(2:end,2:end);

P4 = R;
P4(1:end-1,:) = R(2:end,:);

counter_map = zeros(size(R));

salto = (abs(P1-P2)>NIVEL);
counter_map(salto) = sign(P1(salto)-P2(salto));

salto = (abs(P2-P3)>NIVEL);
counter_map(salto) = counter_map(salto)+ sign(P2(salto)-P3(salto));

salto = (abs(P3-P4)>NIVEL);
counter_map(salto) = counter_map(salto)+ sign(P3(salto)-P4(salto));

salto = (abs(P4-P1)>NIVEL);
counter_map(salto) = counter_map(salto)+ sign(P4(salto)-P1(salto));

counter = (sum(abs(counter_map(:)))~=0);

%figure; imagesc(abs(counter_map));