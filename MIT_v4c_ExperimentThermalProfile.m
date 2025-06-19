%clearvars; close all;
colorsNORM = ["#505150", "#FF5050", "#77C8A6", "#42ACC6", "#588DCA", "#897AFA", "#9A9CA1"];
colorsPAST = ["#BFBFBF", "#FF9C9C", "#BEEBD8", "#9BD9E9", "#88ABCC", "#C7BDF9", "#C6C9CF"];
colorsDARK = ["#000000", "#992F2F", "#417C61", "#3C7A84", "#3D618A", "#545096", "#000000"];
colorsPALE = ["#E9E9E9", "#FFDDDD", "#E8F8F2", "#DCF2F8", "#D6E2ED", "#ECE8FD", "#000000"];
hex2rgb = @(hex) sscanf(hex(2:end),'%2x%2x%2x',[1 3])/255;

%% --------------------------------------------------------------------------------------
% CLLC converter and 3D-MIT Gen1 prototype thermal measurement results
% --------------------------------------------------------------------------------------


% Define filename
file = 'data/20250424_thermal.csv';

% Get data tables
data = readtable(file);

% Extract the data arrays
t = data.t_s;
Tc1 = data.CORE;
Tc2 = data.CORE2;
Tw1 = data.WINDING;
Tw2 = data.WINDING2;

 % Calculate parameters
Tc = (Tc1+Tc2)./2;
Tw = (Tw1+Tw2)./2;
dt = max(abs(Tc1-Tc2));

% Smoothen temperature profile
tq = linspace(min(t), max(t), 1000);  % Create Fine Time Vector for Interpolation
p = 1e-3;  % adjust smoothing parameter p in [0,1] (closer to 1 => closer to interpolation)
Tc_q = csaps(t, Tc, p, tq);  % Smoothing Splines (csaps)
Tw_q = csaps(t, Tw, p, tq);


% Plotting
fig = figure('units','centimeters','position', [2 2 20 4.5]); hold on;

plot(tq, Tc_q, '-', 'color', colorsDARK(5), 'LineWidth', 1.5);
plot(tq, Tc_q+dt/2, '-', 'color', colorsPAST(5), 'LineWidth', 0.5);
plot(tq, Tc_q-dt/2, '-', 'color', colorsPAST(5), 'LineWidth', 0.5);

plot(tq, Tw_q, '-', 'color', colorsDARK(1), 'LineWidth', 1.5);
plot(tq, Tw_q+dt/2, '-', 'color', colorsPAST(1), 'LineWidth', 0.5);
plot(tq, Tw_q-dt/2, '-', 'color', colorsPAST(1), 'LineWidth', 0.5);

xlabel('Time (s)'); ylabel('Temperature (°C)'); 
legend({'Core', 'Winding'}, 'Orientation', 'vertical', 'Location', 'southeast');
ylim([20 70]); xlim([0 760]); xticks(60.*(1:1:12));
grid on; ax = gca; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1; box on;

set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 12);
%exportgraphics(fig, 'figs/exp_thermal-rw.pdf', 'BackgroundColor', 'none', 'ContentType', 'vector');




