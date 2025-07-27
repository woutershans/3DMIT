%clearvars; close all;
% =================================================================================================
% Modelling the CLLC converter gain
% =================================================================================================
%
% Based on First harmonic approximation (FHA) of the resonant tank
% Defines the frequency modulation range required for a given voltage gain
%
% =================================================================================================
% (c) 2025, Hans Wouters, MIT Licence
% =================================================================================================

colorsNORM = ["#505150", "#FF5050", "#77C8A6", "#42ACC6", "#588DCA", "#897AFA", "#9A9CA1"];
colorsPAST = ["#BFBFBF", "#FF9C9C", "#BEEBD8", "#9BD9E9", "#88ABCC", "#C7BDF9", "#C6C9CF"];
colorsDARK = ["#000000", "#992F2F", "#417C61", "#3C7A84", "#3D618A", "#545096", "#000000"];
colorsPALE = ["#E9E9E9", "#FFDDDD", "#E8F8F2", "#DCF2F8", "#D6E2ED", "#ECE8FD", "#000000"];
hex2rgb = @(hex) sscanf(hex(2:end),'%2x%2x%2x',[1 3])/255;


% Windings parameters
N = 5:1:30;          % Number of turns
lg = linspace(1e-9, 1e-3, 100);  % [m] airgap length range
[N_grid, lg_grid] = meshgrid(N, lg);
dN = 1;              % Set value of dN

% Core geometry parameters
la = 66e-3;        % [m] top path length
lb = 54e-3;        % [m] centre path length
Aa = 1.5*308e-6;         % [m²] magnetic path area
Ag = 308e-6;             % [m²] airgap area
mu_r = 4000;         % [-] relative permeability
mu_0 = 4*pi*1e-7;    % [H/m] vacuum permeability

%Lk_stray = 0.02e-6;  % [H] correction of leakage inductance considering the termination

% Calculate reluctances
Ra = la/(mu_0*mu_r*Aa);   % [A/Wb] top path reluctance
Rb = lb/(mu_0*mu_r*Aa);   % [A/Wb] centre path reluctance
Rg_grid = lg_grid./(mu_0*Ag);  % [A/Wb] airgap reluctance (grid)

% Calculate Lm
Lm_num = N_grid.^2.*Ra + 2*N_grid.^2.*Rb + 2*N_grid.^2.*Rg_grid - Ra*dN^2 - 2*Rg_grid*dN^2;
Lm_den = 2*(Ra + 2*Rg_grid).*(Ra + 2*Rb + 2*Rg_grid);
Lm = Lm_num./Lm_den;  % [H]

% Calculate Lkp
Lkp = dN^2./(Ra + 2*Rb + 2*Rg_grid);  % [H]

% Calculate Ln
Ln = Lm./Lkp;  % Ratio (-)


% Plot combined contour plot
fig=figure('units','centimeters','position',[[2 2] [18 7]]); hold on;

% % Lm magnetizing inductance
ax1 = gca;
Lm_levels = 12:4:32;  % Adjust values as needed
[C,hc] = contour(ax1, lg_grid*1e3, N_grid, Lm*1e6, Lm_levels, 'LineColor', colorsPALE(1), 'LineWidth', 1);
ht = clabel(C, hc, 'FontSize', 10, 'Color', 'k');
xlabel('Air Gap Length (mm)'); ylabel('Number of Turns (-)');

% % Lkp primary leakage inductance
% Lk_levels = 0.2e-6:0.2e-6:1e-6;  % Adjust values as needed
% [C,hc] = contour(ax1, lg_grid*1e3, N_grid, Lkp, Lk_levels, 'LineColor', colorsPALE(1), 'LineWidth', 1);
% ht = clabel(C, hc, 'FontSize', 10, 'Color', 'k');

% Ln inductance ratio
Ln_levels = 20:4:44;  % Adjust values as needed
[C,hc] = contour(ax1, lg_grid*1e3, N_grid, Ln, Ln_levels, 'LineColor', colorsPALE(1), 'LineWidth', 1);
ht = clabel(C, hc, 'FontSize', 10, 'Color', 'k');

% Formatting
xlabel('Air Gap (mm)'); ylabel('Number of Turns (-)');
ylim([5 12]); xlim([0, 1]);
ax1.YTick = 5:1:11; ax1.XTick = 0:0.1:1;  % Set the axis ticks

grid on; ax = gca; ax.GridLineStyle = '-'; ax.GridColor = colorsPALE(1); ax.GridAlpha = 1; box on;
set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 12);
%figName = "../results/LmLn_conv-rw.pdf"; exportgraphics(fig, figName, 'BackgroundColor', 'none', 'ContentType', 'vector');

