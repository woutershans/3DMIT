%clearvars; close all;
colorsNORM = ["#505150", "#FF5050", "#77C8A6", "#42ACC6", "#588DCA", "#897AFA", "#9A9CA1"];
colorsPAST = ["#BFBFBF", "#FF9C9C", "#BEEBD8", "#9BD9E9", "#88ABCC", "#C7BDF9", "#C6C9CF"];
colorsDARK = ["#000000", "#992F2F", "#417C61", "#3C7A84", "#3D618A", "#545096", "#000000"];
colorsPALE = ["#E9E9E9", "#FFDDDD", "#E8F8F2", "#DCF2F8", "#D6E2ED", "#ECE8FD", "#000000"];
hex2rgb = @(hex) sscanf(hex(2:end),'%2x%2x%2x',[1 3])/255;

%% --------------------------------------------------------------------------------------
% 3D-MIT Gen1 prototype experimental impedance measurements
% --------------------------------------------------------------------------------------


% Define filenames
base = '../data/';
file_Loc = '250117220908';
file_Lsc = '250117221056';
file_Zoc = '2025-01-17T14_20_25_OC';
file_Zsc = '2025-01-17T14_20_25_SC';

% Extract data
data_Loc = readtable([base file_Loc '.csv']);
data_Lsc = readtable([base file_Lsc '.csv']);
data_Zoc = readtable([base file_Zoc '.csv']);
data_Zsc = readtable([base file_Zsc '.csv']);

f_Loc = data_Loc.FREQUENCY_Hz_;
Loc = data_Loc.LS_H_;
f_Lsc = data_Lsc.FREQUENCY_Hz_;
Lsc = data_Lsc.LS_H_;
f_Zoc = data_Zoc.Frequency_Hz_;
Zoc = data_Zoc.Trace1_Impedance_Magnitude___;
f_Zsc = data_Zsc.Frequency_Hz_;
Zsc = data_Zsc.Trace1_Impedance_Magnitude___;


% Plotting
fig = figure('units','centimeters','position',[[2 2] [20 7]]);  hold on;

subplot(1,2,1); hold on;
h0 = plot(f_Loc, Loc.*1e6, '-', 'color', colorsNORM(1), 'LineWidth', 1.5);
h0 = plot(f_Lsc, Lsc.*1e6, '-', 'color', colorsPAST(1), 'LineWidth', 1.5);
legend({'Loc', 'Lsc'}, 'Orientation', 'vertical', 'Location', 'northwest');
xlabel('Frequency (Hz)');  ylabel('Inductance (µH)');
ax1=gca; ax1.XScale = 'log'; %ax1.YScale = 'log';
xlim([1e3 5e6]); ylim([-350 350]);
grid on; ax1 = gca; ax1.GridLineStyle = ':'; ax1.GridColor = 'k'; ax1.GridAlpha = 1; box on;

subplot(1,2,2); hold on;
h0 = plot(f_Zoc, Zoc.*1e6, '-', 'color', colorsNORM(1), 'LineWidth', 1.5);
h0 = plot(f_Zsc, Zsc.*1e6, '-', 'color', colorsPAST(1), 'LineWidth', 1.5);
legend({'Zoc', 'Zsc'}, 'Orientation', 'vertical', 'Location', 'northwest');
xlabel('Frequency (Hz)');  ylabel('Impedance (Ohm)');
ax2 = gca; ax2.XScale = 'log'; ax2.YScale = 'log';
%xlim([0 5e6]);%ylim([0 125]);
grid on; ax2 = gca; ax2.GridLineStyle = ':'; ax2.GridColor = 'k'; ax2.GridAlpha = 1; box on;

set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 12);
%figName = "../results/LZ_exp_gen1-rw.pdf"; exportgraphics(fig, figName, 'BackgroundColor', 'none', 'ContentType', 'vector');
%figName = "../results/LZ_exp_gen1-rw.png"; exportgraphics(fig, figName, 'BackgroundColor', 'white', 'Resolution', 600);


