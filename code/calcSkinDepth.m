function [delta] = calcSkinDepth(f)
%CALCSKINDEPTH Calculate the skin depth for a certain frequency
%   f   [Hz] frequency  

% General constants.
rho_cu = 2.3e-08;  % [Ohm*m] resistivity copper
mu_0 = 4*pi*10^-7;  % [H/m] permeability free space

delta = (rho_cu./(pi.*mu_0.*f)).^0.5;  % [m] skin depth

end

