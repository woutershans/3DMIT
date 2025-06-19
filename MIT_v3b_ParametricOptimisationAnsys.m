%clearvars; close all;
colorsNORM = ["#505150", "#FF5050", "#77C8A6", "#42ACC6", "#588DCA", "#897AFA", "#9A9CA1", "#E0CD44"];
colorsPAST = ["#BFBFBF", "#FF9C9C", "#BEEBD8", "#9BD9E9", "#88ABCC", "#C7BDF9", "#C6C9CF", "#ECE18E"];
colorsDARK = ["#000000", "#992F2F", "#417C61", "#3C7A84", "#3D618A", "#545096", "#000000", "#9A8B1A"];
colorsPALE = ["#E9E9E9", "#FFDDDD", "#E8F8F2", "#DCF2F8", "#D6E2ED", "#ECE8FD", "#000000", "#F5EFC1"];
hex2rgb = @(hex) sscanf(hex(2:end),'%2x%2x%2x',[1 3])/255;

% Ensure toolbox is available
assert(~isempty(ver('globaloptim')), 'Global Optimization Toolbox required');
assert(license('test','gads_toolbox'), 'No license for Global Optimization Toolbox');

%% --------------------------------------------------------------------------------------
% Parametric optimisation of the 3D-MIT using custom cores
% --------------------------------------------------------------------------------------
%  Visualisation of Ansys Maxwell FEA results


%% Input parameters
% General input parameters
Vp = 400;  % [V] nominal pri voltage
Vs = 400;  % [V] nominal sec voltage
Ip = 10;  % [A] nominal pri current
Np = 9;  % [-] no. of primary turns

% Calculate basic parameters
nt = Vp./Vs;  % [-] transformer ratio
Is = Ip.*nt;  % [A] nominal pri current
Ns = Np./nt;  % [-] no. of sec turns
Pi = Vp.*Ip;  % [W] input power


%% Import ansys results

T = readtable('data\ITX_v5_Optimizer.tab', 'Delimiter','\t', 'FileType','text', 'ReadVariableNames', true);

y_t = 1e-3.*T.y_t;    % get the 'yt' column
x_t = 1e-3.*T.x_t;    % get the 'xt' column
y_c1 = 1e-3.*T.y_c1;   % get the 'yc1' column
y_c2 = 1e-3.*T.y_c2;   % get the 'yc2' column
z_c1 = 1e-3.*T.z_c1;   % get the 'zc1' column
x_cp = 0.5e-3;
x_pt = 0.5e-3;
lg = 0.3e-3;    % fixed value
Pcu = T.Pcu;
Pfe = T.Pfe;
Ptot = Pcu+Pfe;

At = x_t.*y_t;
Javg = Ip./At.*1e-6;

% Size
Afp = (4.*x_t+2.*y_c1+5.*(x_cp+x_pt)).*(2.*x_t+z_c1+2.*(x_cp+x_pt));  % Calculate footprint
Vtot = (4.*x_t+2.*y_c1+5.*(x_cp+x_pt)).*(2.*x_t+z_c1+2.*(x_cp+x_pt)).*(3.*y_c1+2.*y_c2+2.*lg);  % volume

% Optimiser caluclations
cost = (4.*x_t+2.*y_c1+5.*(x_cp+x_pt)).*(2.*x_t+z_c1+2.*(x_cp+x_pt)).*(3.*y_c1+2.*y_c2+2.*lg)./166600 + (Pfe + Pcu.*(z_c1+2.*x_t+y_c1)./z_c1)./16;  % cost function


% Calculate total magnetic loss
%Ptot = Pfe + Pcu;  % [W] total magnetic loss
eff = (Pi-Ptot)./Pi;

% Calculate footprint
PDa = Pi./Afp;
PDv = Pi./Vtot;


%% Pareto plots
plotPareto = true;
if plotPareto == true
    % Scatter plot pareto front
    fig = figure('units','centimeters','position',[[3 3] [24 8]]);  hold on;
    subplot(1,2,1); hold on;

    scatter(Afp(:).*1e4, Ptot(:), 36, z_c1(:)./y_c1(:), 'filled');  
    scatter(49.55, 17, 36, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', colorsNORM(1), 'LineWidth', 0.5);  
    xlabel('Footprint (cm²)'); ylabel('Magnetic Loss (W)');
    grid on; box on; grid(gca,'minor');
    ax = gca; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1;
    ylim([0 40]); xlim([0 80]); clim([0 15])
    c = colorbar; %c.Label.String = 'Ratio xc/yc1';
    colormap(cmapSpectral(256));
    set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 12);

    isPareto = paretofront([Afp(:), Ptot(:)]);
    Afp_par = Afp(isPareto);
    Ptot_par = Ptot(isPareto);
    [Afp_par_sor, idxSort] = sort(Afp_par);
    Ptot_par_sor = Ptot_par(idxSort);
    plot(Afp_par_sor.*1e4, Ptot_par_sor, 'w-', 'LineWidth', 2.5);
    plot(Afp_par_sor.*1e4, Ptot_par_sor, 'k-', 'LineWidth', 1.5);

    % Scatter plot PD vs eff
    subplot(1,2,2); hold on;
    scatter(Vtot(:).*1e6, Ptot(:), 36, z_c1(:)./y_c1(:), 'filled');  
    scatter(166.6, 17, 36, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', colorsNORM(1), 'LineWidth', 0.5);  
    xlabel('Volume (cm³)'); ylabel('Magnetic Loss (W)');
    grid on; box on; grid(gca,'minor');
    ax = gca; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1;
    ylim([0 40]); xlim([0 500]); clim([0 15])
    c = colorbar; %c.Label.String = 'Ratio xc/yc1';
    colormap(cmapSpectral(256));
    set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 12);

    isPareto = paretofront([Vtot(:), Ptot(:)]);
    Vtot_par = Vtot(isPareto);
    Ptot_par = Ptot(isPareto);
    [Vtot_par_sor, idxSort] = sort(Vtot_par);
    Ptot_par_sor = Ptot_par(idxSort);
    plot(Vtot_par_sor.*1e6, Ptot_par_sor, 'w-', 'LineWidth', 2.5);
    plot(Vtot_par_sor.*1e6, Ptot_par_sor, 'k-', 'LineWidth', 1.5);

    figName = "figs/ansys_pareto_opt-rw.pdf"; exportgraphics(fig, figName, 'BackgroundColor', 'none', 'ContentType', 'vector');
end




%% Iterations
% Read table, sort by Evaluation so lines plot left to right
T = readtable('data\ITX_v5_Optimizer_Cost.csv');
T = sortrows(T,"Evaluation"); 

% Extract x (Evaluation) and y (Cost)
ev = T.Evaluation;
ct = T.Cost;

% Plotting
plotIters = true;
if plotIters == true
    fig = figure('units','centimeters','position',[[2 2] [26 5]]);  hold on;
    subplot(1,2,1); hold on
    plot(ev, ct, '-', 'color', colorsPAST(1), 'LineWidth', 1);
    plot(ev, cummin(ct), '-', 'color', colorsDARK(1), 'LineWidth', 2);
    ylim([0.3 2]); xlim([0 100])
    xlabel('Evaluation'); 
    ylabel('Cost');
    set(gca, 'YScale', 'log');    grid on; ax = gca; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1; box on;

    subplot(1,2,2); hold on
    plot(ev, ct, '-', 'color', colorsPAST(1), 'LineWidth', 1);
    plot(ev, cummin(ct), '-', 'color', colorsDARK(1), 'LineWidth', 2);
    ylim([0.3 2]); xlim([100 1000])
    legend({'Trials', 'Best'}, 'Orientation', 'vertical', 'Location', 'northeast');
    xlabel('Evaluation'); 
    ylabel('Cost');
    set(gca, 'YScale', 'log');    grid on; ax = gca; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1; box on;
    set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 12);
    figName = "figs/ansys_cost_iter-rw.pdf"; exportgraphics(fig, figName, 'BackgroundColor', 'none', 'ContentType', 'vector');
    figName = "figs/ansys_cost_iter-rw.png"; exportgraphics(fig, figName, 'BackgroundColor', 'white', 'Resolution', 600);
end



