function [f] = calcSkinFrequency(delta)
%CALCSKINFREQUENCY Calculate the frequency for which a certain skin depth applies
% delta  [m] skin depth  

% General constants.
rho_cu = 2.3e-08;  % [Ohm*m] resistivity copper
mu_0 = 4*pi*10^-7;  % [H/m] permeability free space

f = rho_cu./(pi.*mu_0.*delta.^2);  % [Hz] frequency for certain skin depth


end

