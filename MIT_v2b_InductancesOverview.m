close all; clear;
colorsNORM = ["#505150", "#FF5050", "#77C8A6", "#42ACC6", "#588DCA", "#897AFA", "#E0CD44"];
colorsPAST = ["#9e9e9e", "#FF9C9C", "#BEEBD8", "#9BD9E9", "#88ABCC", "#C7BDF9", "#ECE18E"];
colorsDARK = ["#000000", "#992F2F", "#417C61", "#3C7A84", "#3D618A", "#545096", "#9A8B1A"];
colorsPALE = ["#E9E9E9", "#FFDDDD", "#E8F8F2", "#DCF2F8", "#D6E2ED", "#ECE8FD", "#F5EFC1"];


%% --------------------------------------------------------------------------------------
%  3D-MIT inductance model visualisation for various parameter sweeps
%  --------------------------------------------------------------------------------------
%  Sweeping number of turns N, air gap length lg, and turns delta dN

% Define colormaps
nColors = 256;  % Number of colors in the colormap
color1 = hex2rgb(char("#ffffff"));  % White color

% Create a gradient between the two colors
color2 = hex2rgb(char(colorsPAST(5)));
cmap1 = [linspace(color1(1), color2(1), nColors)', ...
          linspace(color1(2), color2(2), nColors)', ...
          linspace(color1(3), color2(3), nColors)'];

% Create a gradient between the two colors
color2 = hex2rgb(char(colorsPAST(1)));
cmap2 = [linspace(color1(1), color2(1), nColors)', ...
          linspace(color1(2), color2(2), nColors)', ...
          linspace(color1(3), color2(3), nColors)'];

% Create a gradient between the two colors
color2 = hex2rgb(char(colorsPAST(3))); 
cmap3 = [linspace(color1(1), color2(1), nColors)', ...
          linspace(color1(2), color2(2), nColors)', ...
          linspace(color1(3), color2(3), nColors)'];

%% Inputs
% Windings input parameters
N = 5:1:30;  % Number of turns
lg = linspace(10e-6,1e-3,100);  % Air gap length range in meters
dN_values = [1, 2, 3];  % Turns difference values

% Create grids for N and lg
[N_grid, lg_grid] = meshgrid(N, lg);

% Geometry input parameters
la = 79.3e-3;  % Top path length in meters
lb = 61.9e-3;  % Center path length in meters
lc = 79.3e-3;  % Bottom path length in meters
Aa = 260e-6;   % Top path area in square meters
Ab = 260e-6;   % Center path area in square meters
Ac = 260e-6;   % Bottom path area in square meters
Ag = Aa.*1.2;  % Adjusted area for fringing effect in square meters
mu_r = 1200;   % Relative permeability
mu_0 = 4.*pi.*1e-7;  % Permeability of free space

% Calculate reluctance of the elements
Ra = la./(mu_0.*mu_r.*Aa);  % Top path reluctance
Rb = lb./(mu_0.*mu_r.*Ab);  % Center path reluctance
Rc = lc./(mu_0.*mu_r.*Ac);  % Bottom path reluctance
Rg_grid = lg_grid./(mu_0.*Ag);  % Airgap reluctance grid


%% Plot init
fig = figure('units','centimeters','position',[[1 1] [20 18]]);


%% Calculate and plot Lm, Ln, and Lk
for idx = 1:length(dN_values)
    dN = dN_values(idx);  % Current value of dN
    
    Lm_num = (N_grid.^2).*Ra + 2.*(N_grid.^2).*Rb + 2.*(N_grid.^2).*Rg_grid - Ra.*(dN.^2) - 2.*Rg_grid.*(dN.^2);  % Numerator of Lm
    Lm_den = 2.*(Ra + 2.*Rg_grid).*(Ra + 2.*Rb + 2.*Rg_grid);  % Denominator of Lm
    Lm = Lm_num ./ Lm_den;  % Final Lm based on the derived equation
    
    Lk = (dN.^2) ./ (Ra + 2.*Rb + 2.*Rg_grid);  % Calculate Lk based on the derived equation
    Ln = Lm ./ Lk;  % Calculate Ln using the derived equation
    
    % Plot Lm
    subplot(3,3,idx);
    ax1 = gca;
    contourf(ax1, lg_grid*1e3, N_grid, Lm*1e6, 50, 'LineStyle', 'none'); hold on;
    contour_levels = [1 2 5 10 20 50 100];
    [C,hc] = contour(ax1, lg_grid*1e3, N_grid, Lm*1e6, contour_levels, 'LineColor', 'k', 'LineWidth', 1);
    clabel(C, hc, 'FontSize', 10, 'FontName', 'Cambria', 'Color', 'k'); hold off;
    xlabel('Air Gap Length (mm)');
    ylabel('Number of Turns (-)');
    title(sprintf('Lm (µH) for dN = %d', dN));
    %c = colorbar(ax1);
    c.Label.String = 'Magnetising Inductance Lm (µH)';
    colormap(ax1, cmap1);
    caxis(ax1, [10 200]);

    % Plot Ln
    subplot(3,3,idx+3);
    ax2 = gca;
    contourf(ax2, lg_grid*1e3, N_grid, Ln, 50, 'LineStyle', 'none'); hold on;
    contour_levels = [0.1 0.2 0.5 1 2 5 10 20 50 100 200 500];
    [C,hc] = contour(ax2, lg_grid*1e3, N_grid, Ln, contour_levels, 'LineColor', 'k', 'LineWidth', 1);
    clabel(C, hc, 'FontSize', 10, 'FontName', 'Cambria', 'Color', 'k'); hold off;
    xlabel('Air Gap Length (mm)');
    ylabel('Number of Turns (-)');
    title(sprintf('Ln (-) for dN = %d', dN));
    %c = colorbar(ax2);
    c.Label.String = 'Inductance Ratio Ln (-)';
    colormap(ax2, flipud(cmap2));
    caxis(ax2, [1 40]);

    % Plot Lk
    subplot(3,3,idx+6);
    ax3 = gca;
    contourf(ax3, lg_grid*1e3, N_grid, Lk*1e6, 50, 'LineStyle', 'none'); hold on;
    contour_levels = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 100];
    [C,hc] = contour(ax3, lg_grid*1e3, N_grid, Lk*1e6, contour_levels, 'LineColor', 'k', 'LineWidth', 1);
    clabel(C, hc, 'FontSize', 10, 'FontName', 'Cambria', 'Color', 'k'); hold off;
    xlabel('Air Gap Length (mm)');
    ylabel('Number of Turns');
    title(sprintf('Lk (µH) for dN = %d', dN));
    %c = colorbar(ax3);
    c.Label.String = 'Leakage Inductance Lk (µH)';
    colormap(ax3, cmap3);
    caxis(ax3, [0 5]);
end
set(findall(gcf, '-property', 'FontName'), 'FontName', 'Cambria', 'FontSize', 12);
exportgraphics(fig, "..\Figs 3DMIT\LmLnLk_all-rw.pdf", 'BackgroundColor', 'none', 'ContentType', 'vector');
