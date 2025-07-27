%clearvars; close all;
% =================================================================================================
% CLLC converter with 3D-MIT experimental efficiency curves
% =================================================================================================
%
%  TI PMP22650-based CLLC resonant converter with Gen-1 3D-MIT prototype
% 
% =================================================================================================
% (c) 2025, Hans Wouters, MIT Licence
% =================================================================================================

colorsNORM = ["#505150", "#FF5050", "#77C8A6", "#42ACC6", "#588DCA", "#897AFA", "#9A9CA1"];
colorsPAST = ["#BFBFBF", "#FF9C9C", "#BEEBD8", "#9BD9E9", "#88ABCC", "#C7BDF9", "#C6C9CF"];
colorsDARK = ["#000000", "#992F2F", "#417C61", "#3C7A84", "#3D618A", "#545096", "#000000"];
colorsPALE = ["#E9E9E9", "#FFDDDD", "#E8F8F2", "#DCF2F8", "#D6E2ED", "#ECE8FD", "#000000"];
hex2rgb = @(hex) sscanf(hex(2:end),'%2x%2x%2x',[1 3])/255;


% Get data
data = readtable('../data/20250117 efficiency measurements.csv');

% Extract parameters
pt = data.Ptarget_W;  % Target power

pi400_1 = data.Pi1_W;  % Input Power
pi400_2 = data.Pi2_W;
pi400_3 = data.Pi3_W;
pi300_1 = data.Pi4_W;
pi300_2 = data.Pi5_W;
pi300_3 = data.Pi6_W;

po400_1 = data.Po1_W;  % Output Power
po400_2 = data.Po2_W;
po400_3 = data.Po3_W;
po300_1 = data.Po4_W;
po300_2 = data.Po5_W;
po300_3 = data.Po6_W;

eff400_1 = data.Eff1;  % Efficiency
eff400_2 = data.Eff2;
eff400_3 = data.Eff3;
eff300_1 = data.Eff4;
eff300_2 = data.Eff5;
eff300_3 = data.Eff6;

% Error bar calculationsc
meanEff400 = mean([eff400_1, eff400_2, eff400_3], 2);
meanEff300 = mean([eff300_1, eff300_2, eff300_3], 2);


% Plotting
fig = figure('units','centimeters','position',[[2 2] [20 7]]);  hold on;

scatter(pt, eff300_1, 60, '+', 'MarkerEdgeColor', colorsPAST(1), 'LineWidth', 1);
scatter(pt, eff300_2, 60, '+', 'MarkerEdgeColor', colorsPAST(1), 'LineWidth', 1);
scatter(pt, eff300_3, 60, '+', 'MarkerEdgeColor', colorsPAST(1), 'LineWidth', 1);
plot(pt, meanEff300, '-', 'color', colorsPAST(1), 'LineWidth', 1.5);
scatter(pt, meanEff300, 20, 'o', 'MarkerEdgeColor', colorsPAST(5), 'MarkerFaceColor', colorsPALE(1), 'LineWidth', 0.5);

scatter(pt, eff400_1, 60, '+', 'MarkerEdgeColor', colorsDARK(5), 'LineWidth', 1);
scatter(pt, eff400_2, 60, '+', 'MarkerEdgeColor', colorsDARK(5), 'LineWidth', 1);
scatter(pt, eff400_3, 60, '+', 'MarkerEdgeColor', colorsDARK(5), 'LineWidth', 1);
plot(pt, meanEff400, '-', 'color', colorsDARK(5), 'LineWidth', 1.5);
scatter(pt, meanEff400, 20, 'o', 'MarkerEdgeColor', colorsDARK(5), 'MarkerFaceColor', colorsPAST(5), 'LineWidth', 1);

xlabel('Output Power (W)'); ylabel('Efficiency (%)');
xlim([0 4.1e3]); ylim([80 100]);
grid on; box on; grid(gca,'minor');
ax = gca; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1;

set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 12);
%exportgraphics(fig, '../results/eff_curve-rw.pdf', 'BackgroundColor', 'none', 'ContentType', 'vector');



