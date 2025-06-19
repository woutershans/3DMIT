%clearvars; close all;
colorsNORM = ["#505150", "#FF5050", "#77C8A6", "#42ACC6", "#588DCA", "#897AFA", "#9A9CA1", "#E0CD44"];
colorsPAST = ["#BFBFBF", "#FF9C9C", "#BEEBD8", "#9BD9E9", "#88ABCC", "#C7BDF9", "#C6C9CF", "#ECE18E"];
colorsDARK = ["#000000", "#992F2F", "#417C61", "#3C7A84", "#3D618A", "#545096", "#000000", "#9A8B1A"];
colorsPALE = ["#E9E9E9", "#FFDDDD", "#E8F8F2", "#DCF2F8", "#D6E2ED", "#ECE8FD", "#000000", "#F5EFC1"];
hex2rgb = @(hex) sscanf(hex(2:end),'%2x%2x%2x',[1 3])/255;

%% --------------------------------------------------------------------------------------
% Parametric optimisation of the 3D-MIT using commercial cores
% --------------------------------------------------------------------------------------
%  Based on analytical MATLAB models and Ansys Maxwell FEA results



%% Extract the losses from the Ansys datafile
data = readtable('../data/ITX_Parametric_v2_2D_Losses.csv');
freq = data{:, 'Freq_Hz_'};      % Frequency (Hz)
y_t = data{:, 'y_t_mm_'};        % Y parameter (mm)
x_t = data{:, 'x_t_mm_'};        % X parameter (mm)

mtl_factor = 1.25;  % Correction factor defined as 3D winding length / 2D winding length
solidLoss = mtl_factor.*data{:, 'SolidLoss_W_'}; % Solid loss (W)
coreLoss = data{:, 'CoreLoss_W_'}; % Core loss (W)
magnLoss = solidLoss + coreLoss; % Total magnetic loss

% Get the unique values of x_t and y_t to form the grid
x_t_un = sort(unique(x_t));  
y_t_un = sort(unique(y_t));
[Xt_mesh, Yt_mesh] = meshgrid(x_t_un, y_t_un);  % Create the meshgrid for contour plotting

% Process for winding loss
P_wind = NaN(length(y_t_un), length(x_t_un));  % Empty matrix for solidLoss values, size is based on y_vals and x_vals
for i = 1:length(x_t)  % Populate the Z matrix with solidLoss values corresponding to each (x_t, y_t) pair
    col = find(x_t_un == x_t(i));
    row = find(y_t_un == y_t(i));
    P_wind(row, col) = solidLoss(i);  % Assign the solidLoss value to the correct position in the matrix
end

% Process for core loss
P_core = NaN(length(y_t_un), length(x_t_un));  % Empty matrix for coreLoss values
for i = 1:length(x_t)  % Populate the Z matrix with coreLoss values corresponding to each (x_t, y_t) pair
    col = find(x_t_un == x_t(i));
    row = find(y_t_un == y_t(i));
    P_core(row, col) = coreLoss(i);  % Assign the coreLoss value to the correct position in the matrix
end

% Process for total magnetic loss
P_magn = NaN(length(y_t_un), length(x_t_un));  % Empty matrix for magnLoss values
for i = 1:length(x_t)  % Populate the Z matrix with magnLoss values corresponding to each (x_t, y_t) pair
    col = find(x_t_un == x_t(i));
    row = find(y_t_un == y_t(i));
    P_magn(row, col) = magnLoss(i);  % Assign the magnLoss value to the correct position in the matrix
end


%% Footprint calculation
x_c1 = 58.1;  % mm
x_cp = 0.5;  % mm
x_pt = 0.5;  % mm
y_c1 = 38.1;  % mm
y_cp = x_cp;  % mm
y_pt = x_pt;  % mm
x_fp = 2.*(2*x_pt+Xt_mesh+x_cp+x_c1/2);  % mm
y_fp = 2.*(2*y_pt+Xt_mesh+y_cp+y_c1/2);  % mm
f58 = x_fp.*y_fp;  % mm


%% Static parasitic capacitance estimation
eps_0 = 8.854e-12;  % [F/m] permittivity free space
eps_r = 4.8;  % relative permittivity FR-4
eps = eps_0*eps_r;  % [F/m] permittivity FR-4

Xt_mesh_m = Xt_mesh.*1e-3;
Yt_mesh_m = Yt_mesh.*1e-3;
z_t = 38.1e-3;  % m
x_c2 = 4.2e-3;  % m

y_pcb = 4e-3;  % Total PCB thickness
Nl_PCB = 6;  % Number of layers per PCB
y_p = (y_pcb-Nl_PCB*Yt_mesh_m)/(Nl_PCB-1);

Sa = Xt_mesh_m.*z_t;
Sb = Xt_mesh_m.*(2.*Xt_mesh_m+x_c2+2.*(x_cp.*1e-3+x_pt.*1e-3));
S = 4.*(Sa+Sb);
 
C0 = eps_0.*eps_r.*S./y_p;
C0_ii = eps_0.*eps_r.*S./(2.*y_p);

Nt = 1;  % no of turns per layer
Cd = C0.*(Nt+1).*(2.*Nt+1)./(6.*Nt);  % layer to layer capacitance
Cd_ii = C0_ii.*(Nt+1).*(2.*Nt+1)./(6.*Nt);  % layer to layer capacitance

Nii = 4;  % number of intra-winding interfaces, should be parameterised
Cii = (4.*(Nii-1).*Cd_ii)./Nii;

Nij = 8;  % number of intra-winding interfaces, neglecting the C between the 2 PCB boards with large spacing
Cij = Nij.*Cd;


%% Current density
Irms = 10;  % A
Javg = Irms./(Xt_mesh.*Yt_mesh);  % A/m²


%% Defining Colormaps
color1 = hex2rgb(char("#6D8096"));   % First color
color2 = hex2rgb(char("#ABB7C2"));   % Second color
color3 = hex2rgb(char("#D6C6C6"));   % Third color
color4 = hex2rgb(char("#D5A9A9"));   % Fourth color
nColors = 256;  % Total number of colors in the colormap
nSegment1 = floor(nColors / 3);      % From color1 to color2
nSegment2 = floor(nColors / 3);      % From color2 to color3
nSegment3 = nColors - (nSegment1 + nSegment2);  % From color3 to color4
cmap1 = [linspace(color1(1), color2(1), nSegment1)', linspace(color1(2), color2(2), nSegment1)', linspace(color1(3), color2(3), nSegment1)'];
cmap2 = [linspace(color2(1), color3(1), nSegment2)', linspace(color2(2), color3(2), nSegment2)', linspace(color2(3), color3(3), nSegment2)'];
cmap3 = [linspace(color3(1), color4(1), nSegment3)', linspace(color3(2), color4(2), nSegment3)', linspace(color3(3), color4(3), nSegment3)'];
cmap_1 = [cmap1; cmap2; cmap3];

color1 = hex2rgb(char("#ffffff"));
color2 = hex2rgb(char(colorsPALE(1)));
color3 = hex2rgb(char(colorsNORM(1)));
nColors = 256;
nSegment1 = floor(nColors / 2);
nSegment2 = nColors - nSegment1;
cmap1 = [linspace(color1(1), color2(1), nSegment1)', linspace(color1(2), color2(2), nSegment1)', linspace(color1(3), color2(3), nSegment1)'];
cmap2 = [linspace(color2(1), color3(1), nSegment2)', linspace(color2(2), color3(2), nSegment2)', linspace(color2(3), color3(3), nSegment2)'];
cmap_2 = [cmap1; cmap2];

color1 = hex2rgb(char("#ffffff"));
color2 = hex2rgb(char(colorsPALE(1)));
color3 = hex2rgb(char(colorsNORM(1)));
nColors = 256;
nSegment1 = floor(nColors / 2);
nSegment2 = nColors - nSegment1;
cmap1 = [linspace(color1(1), color2(1), nSegment1)', linspace(color1(2), color2(2), nSegment1)', linspace(color1(3), color2(3), nSegment1)'];
cmap2 = [linspace(color2(1), color3(1), nSegment2)', linspace(color2(2), color3(2), nSegment2)', linspace(color2(3), color3(3), nSegment2)'];
cmap_3 = [cmap1; cmap2];


%% Contour plots of all parameters as function of xc, xt

figDesigns = true;
if figDesigns == true
    fig=figure('units','centimeters','position',[[1 1] [22 18]]);

    % Plotting winding loss
    subplot(3,2,1); ax1 = gca;
    contourf(ax1, Xt_mesh, Yt_mesh, P_wind, 60, 'LineStyle', 'none'); hold on;
    [C,h] = contour(Xt_mesh, Yt_mesh, P_wind, 2:1:40, 'LineColor', 'k');
    clabel(C, h, 'FontSize', 8, 'Color', 'k', 'FontName', 'Cambria'); hold off;
    set(gca,"FontSize",10);
    colormap(ax1, cmap_1); c = colorbar; title('Winding Loss (W)', 'FontSize', 12); %caxis([0, 10]);
    xlabel('Width xt (mm)', 'FontSize', 12); ylabel('Thickness yt (mm)', 'FontSize', 12);
    set(gca,"XTick",[5 10 15 20]); set(gca,"YTick",[0.035 0.070 0.105 0.140]); 

    % Plotting total magnetic loss
    subplot(3,2,2); ax2 = gca;
    contourf(ax2, Xt_mesh, Yt_mesh, P_magn, 60, 'LineStyle', 'none'); hold on;
    [C,h] = contour(Xt_mesh, Yt_mesh, P_magn, 2:1:40, 'LineColor', 'k');
    clabel(C, h, 'FontSize', 8, 'Color', 'k', 'FontName', 'Cambria'); hold off;
    set(gca,"FontSize",10);
    colormap(ax2, cmap_1); c = colorbar; title('Magnetic Loss (W)', 'FontSize', 12); %caxis([12, 24]);
    xlabel('Width xt (mm)', 'FontSize', 12); ylabel('Thickness yt (mm)', 'FontSize', 12);
    set(gca,"XTick",[5 10 15 20]); set(gca,"YTick",[0.035 0.070 0.105 0.140]); 

    % Plotting footprint
    subplot(3,2,3); ax3 = gca;
    contourf(ax3, Xt_mesh, Yt_mesh, f58, 60, 'LineStyle', 'none'); hold on;
    [C,h] = contour(Xt_mesh, Yt_mesh, f58, 'LineColor', 'k');
    clabel(C, h, 'FontSize', 8, 'Color', 'k', 'FontName', 'Cambria'); hold off;
    set(gca,"FontSize",10);
    colormap(ax3, cmap_1); c = colorbar; title('Footprint (mm²)', 'FontSize', 12); % caxis([4000, 8000]);
    xlabel('Width xt (mm)', 'FontSize', 12); ylabel('Thickness yt (mm)', 'FontSize', 12);
    set(gca,"XTick",[5 10 15 20]); set(gca,"YTick",[0.035 0.070 0.105 0.140]); 
   
    % Plotting J
    subplot(3,2,4); ax4 = gca;
    contourf(ax4, Xt_mesh, Yt_mesh, Javg, 60, 'LineStyle', 'none'); hold on;
    [C,h] = contour(Xt_mesh, Yt_mesh, Javg, 'LineColor', 'k');
    clabel(C, h, 'FontSize', 8, 'Color', 'k', 'FontName', 'Cambria'); hold off;
    set(gca,"FontSize",10);
    colormap(ax4, cmap_1); c = colorbar; title('Current Density (A/mm²)', 'FontSize', 12); %caxis([4000, 8000]);
    xlabel('Width xt (mm)', 'FontSize', 12); ylabel('Thickness yt (mm)', 'FontSize', 12);
    set(gca,"XTick",[5 10 15 20]); set(gca,"YTick",[0.035 0.070 0.105 0.140]); 
    
    % Plotting Cii
    subplot(3,2,5); ax5 = gca;
    contourf(ax5, Xt_mesh, Yt_mesh, Cii.*1e9, 60, 'LineStyle', 'none'); hold on;
    [C,h] = contour(Xt_mesh, Yt_mesh, Cii.*1e9, 'LineColor', 'k');
    clabel(C, h, 'FontSize', 8, 'Color', 'k', 'FontName', 'Cambria'); hold off;
    set(gca,"FontSize",10);
    colormap(ax5, cmap_1); c = colorbar; title('Intra-winding Capacitance (nF)', 'FontSize', 12); %caxis([4000, 8000]);
    xlabel('Width xt (mm)', 'FontSize', 12); ylabel('Thickness yt (mm)', 'FontSize', 12);
    set(gca,"XTick",[5 10 15 20]); set(gca,"YTick",[0.035 0.070 0.105 0.140]); 
   
    % Plotting Cij
    subplot(3,2,6); ax6 = gca;
    contourf(ax6, Xt_mesh, Yt_mesh, Cij.*1e9, 60, 'LineStyle', 'none'); hold on;
    [C,h] = contour(Xt_mesh, Yt_mesh, Cij.*1e9, 'LineColor', 'k');
    clabel(C, h, 'FontSize', 8, 'Color', 'k', 'FontName', 'Cambria'); hold off;
    set(gca,"FontSize",10);
    colormap(ax6, cmap_1); c = colorbar; title('Inter-winding Capacitance (nF)', 'FontSize', 12); %caxis([4000, 8000]);
    xlabel('Width xt (mm)', 'FontSize', 12); ylabel('Thickness yt (mm)', 'FontSize', 12);
    set(gca,"XTick",[5 10 15 20]); set(gca,"YTick",[0.035 0.070 0.105 0.140]); 
   
    set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria');
    %figName = "../results/itx_design-rw.pdf"; exportgraphics(fig, figName, 'BackgroundColor', 'none', 'ContentType', 'vector');
end


%% Combined contour plot

figCombined = true;
if figCombined == true
    fig=figure('units','centimeters','position',[[3 3] [25 9]]); hold on;

    [C,hc] = contour(Xt_mesh, Yt_mesh, P_magn, [25 26 27], 'LineStyle', '-', 'LineColor', colorsDARK(6), 'LineWidth', 0.75);
    clabel(C, hc, 'FontSize', 7, 'Color', 'k');
    xlabel('Trace Width (mm)'); ylabel('Trace Thickness (mm)');
    
    [C,hc] = contour(Xt_mesh, Yt_mesh, f58, [4000 5000 6000 7000], 'LineStyle', '-.', 'LineColor', colorsDARK(1), 'LineWidth', 1);
    clabel(C, hc, 'FontSize', 7, 'Color', 'k');
    xlabel('Trace Width (mm)'); ylabel('Trace Thickness (mm)');
    
    [C,hc] = contour(Xt_mesh, Yt_mesh, Javg, [6 8 10], 'LineStyle', '--', 'LineColor', colorsDARK(1), 'LineWidth', 1);
    clabel(C, hc, 'FontSize', 7, 'Color', 'k');
    xlabel('Trace Width (mm)'); ylabel('Trace Thickness (mm)');
    
    [C,hc] = contour(Xt_mesh, Yt_mesh, Cii.*1e9, [0.2 0.3 0.4], 'LineStyle', ':', 'LineColor', colorsDARK(5), 'LineWidth', 1.25);
    clabel(C, hc, 'FontSize', 7, 'Color', 'k');
    xlabel('Trace Width (mm)'); ylabel('Trace Thickness (mm)');
    
    [C,hc] = contour(Xt_mesh, Yt_mesh, Cij.*1e9, [1 2 3], 'LineStyle', '-', 'LineColor', colorsDARK(5), 'LineWidth', 2);
    clabel(C, hc, 'FontSize', 7, 'Color', 'k');
    xlabel('Trace Width (mm)'); ylabel('Trace Thickness (mm)');
    
    legend(["P_magn", "fp", "Javg", "Cii", "Cij"], 'Orientation', 'vertical', 'Location', 'northeastoutside'); box on;
    set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 12);
    %figName = "../results/itx_design_comb-rw.pdf"; exportgraphics(fig, figName, 'BackgroundColor', 'none', 'ContentType', 'vector');
end


%% Final selection considering different cores

% E58-based core results
% 1: E58/11/38 UIU core
% 2: E58/11/38 IU-I-UI core
% 3: E58/11/38 U-I-UI core
V58 = [ 127.0   166.6   146.7 ];  % cm³ transformer box volume
P58 = [ 24.59   16.01   21.11 ];  % W magnetic loss
f58 = [ 4955    4955    4955  ];  % mm² footprint

% E64-based core results
% 1: UIU core
% 2: U-I-UI
% 3: IU-II-UI
V64 = [ 165.1   196.9    228.6];  % cm³ transformer box volume
P64 = [ 16.31   14.05    11.65 ];  % W magnetic loss
f64 = [ 6351    6351     6351  ];  % mm² footprint

% Plot results
plotCores = true;
if plotCores == true
    fig = figure('units','centimeters','position',[[3 3] [7 7]]); hold on;
    scatter(V58, P58, 40, 'o', 'MarkerEdgeColor', colorsNORM(1), 'MarkerFaceColor', colorsPAST(5), 'LineWidth',0.5);    
    scatter(V64, P64, 40, 'o', 'MarkerEdgeColor', colorsNORM(1), 'MarkerFaceColor', colorsPAST(2), 'LineWidth',0.5);    

    xlabel('Box Volume (cm³)'); ylabel('Magnetic Loss (W)');
    legend(["E58-based" "E64-based"], 'Orientation', 'vertical', 'Location', 'northeast')
    xlim([100 250]); ylim([10 26]);
    grid on; box on; ax = gca; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1;
    set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 12);
    %figName = "../results/itx_design_core-rw.pdf"; exportgraphics(fig, figName, 'BackgroundColor', 'none', 'ContentType', 'vector');
end





