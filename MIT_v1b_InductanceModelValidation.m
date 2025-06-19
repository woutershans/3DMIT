%clearvars; close all;
colorsNORM = ["#505150", "#FF5050", "#77C8A6", "#42ACC6", "#588DCA", "#897AFA", "#9A9CA1"];
colorsPAST = ["#BFBFBF", "#FF9C9C", "#BEEBD8", "#9BD9E9", "#88ABCC", "#C7BDF9", "#C6C9CF"];
colorsDARK = ["#000000", "#992F2F", "#417C61", "#3C7A84", "#3D618A", "#545096", "#000000"];
colorsPALE = ["#E9E9E9", "#FFDDDD", "#E8F8F2", "#DCF2F8", "#D6E2ED", "#ECE8FD", "#000000"];
hex2rgb = @(hex) sscanf(hex(2:end),'%2x%2x%2x',[1 3])/255;

%% --------------------------------------------------------------------------------------
%  3D-MIT inductance model validation based on the 7:7 proof-of-concept prototype
%  --------------------------------------------------------------------------------------
%  Compared to Ansys Maxwell FEA simulations: IPCBTX v1.aedt/PSP_PSPS-SPS_PSPS sweep 3D EDDY
%  Compared to PLECS electomagnetic circuit co-simulations: ITX_PlecsModel.plecs
%  Compared to experimental measurements with Hioki impedance analyzer: 20241011_I2TX_v1_7-7_LmLk_lg.xlsx


%% 1.1 EXPERIMENTAL DATA
% Experimental data (20241011_I2TX_v1_7-7_LmLk_lg.xlsx)
lg_exp = 0.005 + 0.08.*[0 1 2 3 4 5 6 7 8 9 10 13];  % [mm]
Loc_exp = [115.3, 106.28, 111.2, 124.3; 43.7, 37.65, 35.088, 42.95; 23.13, 22.56, 22.56, 22.56; 15.28, 16.24, 17.61, 13.49; 14.51, 14.61, 14.63, 14.58; 11.42, 11.07, 11.15, 11.18; 9.24, 9.14, 9.34, 9.31; 8.37, 8.37, 8.36, 8.25; 7.3, 7.22, 7.33, 7.3; 6.68, 6.67, 6.68, 6.58; 6.16, 6.12, 6.12, 6.15; 4.9, 4.91, 4.89, 4.9];  % [uH] Experimental Loc Lm values
Lsc_exp = [5.35, 4.5, 4.57, 4.65; 1.97, 1.94, 1.96, 1.92; 1.34, 1.34, 1.37, 1.34; 1.04, 1.02, 1.07, 1.05; 0.99, 0.99, 1, 0.98; 0.85, 0.84, 0.82, 0.83; 0.76, 0.74, 0.76, 0.76; 0.71, 0.71, 0.71, 0.7; 0.65, 0.64, 0.66, 0.65; 0.62, 0.62, 0.61, 0.62; 0.59, 0.59, 0.58, 0.59; 0.51, 0.5, 0.51, 0.5];  % [uH] Experimental Lsc Lk values

L11_exp = Loc_exp;
L22_exp = Loc_exp;  % assuming L11 = L22 based on measurements
k_exp = sqrt(1-Lsc_exp./L11_exp);
L12_exp = k_exp.*sqrt(L11_exp.*L22_exp);  % Based on T-model: Lm = L12 = M
Lkp_exp = L11_exp-L12_exp;  % Based on T-model: Lkp = L12-L11

% Calculate mean, min, and max for error bars
Lm_exp = mean(L12_exp, 2);
min_Lm = min(L12_exp, [], 2);
max_Lm = max(L12_exp, [], 2);
lower_errors_Lm = Lm_exp - min_Lm;
upper_errors_Lm = max_Lm - Lm_exp;
Lkp_exp = mean(Lkp_exp, 2);
min_Lk = min(Lkp_exp, [], 2);
max_Lk = max(Lkp_exp, [], 2);
lower_errors_Lk = Lkp_exp - min_Lk;
upper_errors_Lk = max_Lk - Lkp_exp;

Ln_exp = Lm_exp./(Lkp_exp);


%% 1.2 FEA simulation data
% Ansys data (IPCBTX v1.aedt/PSP_PSPS-SPS_PSPS sweep 3D EDDY)

% yg (mm), Lm (uH), Lk (uH)
L_fea = [...
    0.00,   386.8,   12.86; ...
    0.05,   74.7,    4.70; ...
    0.10,   42.7,    2.99; ...
    0.15,   30.4,    2.23; ...
    0.20,   24.0,    1.81; ...
    0.25,   19.9,    1.53; ...
    0.30,   17.1,    1.34; ...
    0.35,   15.1,    1.20; ...
    0.40,   13.5,    1.10; ...
    0.45,   12.3,    0.999; ...
    0.50,   11.3,    0.929; ...
    0.55,   10.5,    0.868; ...
    0.60,   9.8,     0.815; ...
    0.65,   9.2,     0.772; ...
    0.70,   8.7,     0.734; ...
    0.75,   8.3,     0.701; ...
    0.80,   7.9,     0.671; ...
    0.85,   7.5,     0.644; ...
    0.90,   7.2,     0.620; ...
    0.95,   6.9,     0.599; ...
    1.00,   6.7,     0.579];

lg_fea = L_fea(:,1);
Lm_fea = L_fea(:,2);
Lsc_fea = L_fea(:,3);

L11_fea = Lm_fea;
L22_fea = Lm_fea;  % assuming L11 = L22 based on simulations
k_fea = sqrt(1-Lsc_fea./L11_fea);
L12_fea = k_fea.*sqrt(L11_fea.*L22_fea);  % Based on T-model: Lm = L12 = M
Lkp_fea = L11_fea-L12_fea;  % Based on T-model: Lkp = L12-L11

Ln_fea = Lm_fea./Lkp_fea;


%% 1.4 PLECS simulation
% Based on ITX_PlecsModel.plecs

% Pre-compute the Rg values
lg_plecs = 1e-3.*(0:0.1:1);
Rg_plecs = lg_plecs./(4.*pi.*1e-7.*260e-6*1.2);  % [A./Wb] top airgaps reluctance

	% lg    Rg          Loc      Lsc
L_ple = [...
    0.10,   55055,      55.48,   1.997; ...
    0.20,   510111,     20.137,  1.107; ...
    0.30,   765167,     14.846,  0.886; ...
    0.40,   1020223,    11.758,  0.740; ...
    0.50,   1275279,    9.734,   0.633; ...
    0.60,   1530335,    8.305,   0.554; ...
    0.70,   1785391,    7.242,   0.493; ...
    0.80,   2040447,    6.420,   0.443; ...
    0.90,   2295503,    5.766,   0.403; ...
    1.00,   2550559,    5.232,   0.370;];

lg_ple = L_ple(:,1);
Loc_ple = L_ple(:,3);
Lsc_ple = L_ple(:,4);

k_ple = sqrt(1-Lsc_ple./Loc_ple);
L12_ple = k_ple.*sqrt(Loc_ple.*Loc_ple);  % Based on T-model: Lm = L12 = M

Lm_ple = L12_ple;
Lkp_ple = Loc_ple-L12_ple;  % Based on T-model: Lkp = L12-L11


%% 1.5 Analyical model
%  Based on MIT_v1a_InductanceModelDerivation.m

% Windings input parameters.
Np1 = 4;  % [-] primary turns on top path
Np2 = 3;  % [-] primary turns on bottom path
Ns1 = 3;  % [-] secondary turns on top path
Ns2 = 4;  % [-] secondary turns on bottom path

% Calculate winding distribution parameters.
Np = Np1 + Np2;  % [-] primary turns
Ns = Ns1 + Ns2;  % [-] secondary turns
N = Np1 + Np2;  % [-] total no. of turns
dN = abs(Np1-Np2);  % [-] turns delta

% Geometry input parameters.
la = 79.3e-3;  % [m] top path length
lb = 61.9e-3;  % [m] centre path length
lc = 79.3e-3;  % [m] bottom path length
lg = linspace(0,1e-3,100);  % [m] airgap 1 length (range)
Aa = 260e-6;  % [m²] top path area
Ab = 260e-6;  % [m²] centre path area
Ac = 260e-6;  % [m²] bottom path area
Ag = Aa;  % [m²] fringing effect factor based on FEA
mu_r = 1200;  % [-] relative permeability
mu_0 = 4.*pi.*1e-7;  % [H/m]

% Calculate reluctance of the elements.
Ra = la./(mu_0.*mu_r.*Aa);  % [A./Wb] top path reluctance
Rb = lb./(mu_0.*mu_r.*Ab);  % [A./Wb] centre path reluctance
Rc = lc./(mu_0.*mu_r.*Ac);  % [A./Wb] bottom path reluctance
Rg = lg./(mu_0.*Ag);  % [A./Wb] top airgaps reluctance

Lm = (Np1.*Ns1.*Ra + Np2.*Ns2.*Ra + Np1.*Ns1.*Rb + Np1.*Ns2.*Rb + Np2.*Ns1.*Rb + Np2.*Ns2.*Rb + 2.*Np1.*Ns1.*Rg + 2.*Np2.*Ns2.*Rg)./((Ra + 2.*Rg).*(Ra + 2.*Rb + 2.*Rg));
Lkp = -(Np1.*Ns1.*Ra - Np2.^2.*Ra - Np1.^2.*Rb - Np2.^2.*Rb - 2.*Np1.^2.*Rg - 2.*Np2.^2.*Rg - 2.*Np1.*Np2.*Rb - Np1.^2.*Ra + Np2.*Ns2.*Ra + Np1.*Ns1.*Rb + Np1.*Ns2.*Rb + Np2.*Ns1.*Rb + Np2.*Ns2.*Rb + 2.*Np1.*Ns1.*Rg + 2.*Np2.*Ns2.*Rg)./((Ra + 2.*Rg).*(Ra + 2.*Rb + 2.*Rg)); 
Ln = -(Np1.*Ns1.*Ra + Np2.*Ns2.*Ra + Np1.*Ns1.*Rb + Np1.*Ns2.*Rb + Np2.*Ns1.*Rb + Np2.*Ns2.*Rb + 2.*Np1.*Ns1.*Rg + 2.*Np2.*Ns2.*Rg)./(Np1.*Ns1.*Ra - Np2.^2.*Ra - Np1.^2.*Rb - Np2.^2.*Rb - 2.*Np1.^2.*Rg - 2.*Np2.^2.*Rg - 2.*Np1.*Np2.*Rb - Np1.^2.*Ra + Np2.*Ns2.*Ra + Np1.*Ns1.*Rb + Np1.*Ns2.*Rb + Np2.*Ns1.*Rb + Np2.*Ns2.*Rb + 2.*Np1.*Ns1.*Rg + 2.*Np2.*Ns2.*Rg);


%% 2. Plot Results
plotLmLk = true;
if plotLmLk == true
    fig = figure('units','centimeters','position',[[2 2] [20 15]]); hold on;

    % Lm
    subplot(3,1,1); hold on;
    scatter(lg_fea, Lm_fea, 30, 's', 'MarkerEdgeColor', colorsNORM(1), 'LineWidth', 0.75);  % FEA Lm
    scatter(lg_ple, Lm_ple, 20, 'o', 'MarkerEdgeColor', colorsNORM(1), 'LineWidth', 0.75);  % PLECS Lm
    errorbar(lg_exp, Lm_exp, lower_errors_Lm, upper_errors_Lm, 'linestyle', 'none', 'Marker', 'x', 'Color', colorsNORM(2), 'LineWidth', 1);  % Experimental
    plot(lg.*1e3, Lm.*1e6, '-', 'color', colorsDARK(1), 'LineWidth', 1.5);  % Model Lm
    legend({'Ansys', 'PLECS', 'Exp.', 'Model'}, 'Orientation', 'vertical', 'Location', 'northeast');
    xlabel('Air Gap (mm)');  ylabel('Lm (uH)');
    ylim([0 125]); xlim([0,1]);
    grid on; ax = gca; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1; box on;
    set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 12);
    
    % Lk
    subplot(3,1,2); hold on;
    scatter(lg_fea, Lkp_fea, 30, 's', 'MarkerEdgeColor', colorsNORM(1), 'LineWidth', 0.75);  % fea Lk
    scatter(lg_ple, Lkp_ple, 20, 'o', 'MarkerEdgeColor', colorsNORM(1), 'LineWidth', 0.75);  % PLECS Lk
    errorbar(lg_exp, Lkp_exp, lower_errors_Lk, upper_errors_Lk, 'linestyle', 'none', 'Marker', 'x', 'Color', colorsNORM(2), 'LineWidth', 1);  % Experimental
    plot(lg.*1e3, Lkp.*1e6, '-', 'color', colorsDARK(1), 'LineWidth', 1.5);  % Model Lk
    xlabel('Air Gap (mm)');  ylabel('Lkp (uH)');
    ylim([0 2.5]); xlim([0,1]);
    grid on; ax = gca; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1; box on;
    set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 12);
    
    % Ln
    subplot(3,1,3); hold on;
    scatter(lg_fea, Ln_fea, 30, 's', 'MarkerEdgeColor', colorsNORM(1), 'LineWidth', 0.75);  % Exp
    scatter(lg_ple, Lm_ple./Lkp_ple, 20, 'o', 'MarkerEdgeColor', colorsNORM(1), 'LineWidth', 0.75);  % Exp
    scatter(lg_exp, Ln_exp, 40, '+', 'MarkerEdgeColor', colorsNORM(2), 'LineWidth', 1);  % Exp
    plot(lg.*1e3, Ln, '-', 'color', colorsDARK(1), 'LineWidth', 1.5);  % Model
    xlabel('Air Gap (mm)'); ylabel('Ln (-)');
    ylim([20, 65]); xlim([0, 1]);
    grid on; ax = gca; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1; box on;

    % Save
    set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 12);
    %figName = "figs\L_model_exp-rw.pdf"; exportgraphics(fig, figName, 'BackgroundColor', 'none', 'ContentType', 'vector');
    %figName = "figs\L_model_exp-rw.png"; exportgraphics(fig, figName, 'BackgroundColor', 'white', 'Resolution', 600);
end





