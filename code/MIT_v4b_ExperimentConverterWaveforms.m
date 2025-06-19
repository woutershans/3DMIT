%clearvars; close all;
colorsNORM = ["#505150", "#FF5050", "#77C8A6", "#42ACC6", "#588DCA", "#897AFA", "#9A9CA1"];
colorsPAST = ["#BFBFBF", "#FF9C9C", "#BEEBD8", "#9BD9E9", "#88ABCC", "#C7BDF9", "#C6C9CF"];
colorsDARK = ["#000000", "#992F2F", "#417C61", "#3C7A84", "#3D618A", "#545096", "#000000"];
colorsPALE = ["#E9E9E9", "#FFDDDD", "#E8F8F2", "#DCF2F8", "#D6E2ED", "#ECE8FD", "#000000"];
hex2rgb = @(hex) sscanf(hex(2:end),'%2x%2x%2x',[1 3])/255;

%% --------------------------------------------------------------------------------------
% CLLC converter with 3D-MIT Gen1 prototype experimental waveforms
% --------------------------------------------------------------------------------------


%% Plot converter operation waveforms

% Define filename
base = 'data/20250121_cllc_3dmit__';

i = 4;  % Choos a specific file no.
file = sprintf('%03d', i);

% Get data tables
data_ip1 = load([base file '_ch1.mat']);
data_is1 = load([base file '_ch2.mat']);
data_vp1 = load([base file '_ch4.mat']);
data_vs1 = load([base file '_ch5.mat']);

% Extract the data arrays
time1 = data_ip1.time;
time1 = time1 - time1(1);
ip1 = data_ip1.data;
is1 = data_is1.data;
vp1 = data_vp1.data;
vs1 = data_vs1.data;

% Calculate parameters
is1_rms = sqrt(mean(is1.^2));
ip1_rms = sqrt(mean(ip1.^2));
vs1_avg = mean(vs1);
po1_avg = is1_rms*vs1_avg;


% Plotting
fig = figure('units','centimeters','position',[[2 2] [20 9]]);  hold on;
subplot(2,1,1); hold on;

plot(time1*1e6, ip1, '-', 'color', colorsDARK(5), 'LineWidth', 1);
plot(time1*1e6, 1.*is1, '-', 'color', colorsPAST(5), 'LineWidth', 1);
legend({'P', 'S'}, 'Orientation', 'vertical', 'Location', 'southeast');
% title(sprintf('Waveforms for Experiment #%03d @Is=%.1f A, Vs=%.1f V, Po=%d W', i, is1_rms, vs1_avg, round(po1_avg)));
xlabel('Time (µs)');  ylabel('Current (A)');
ylim([-20 20]); %xlim([0,1]);
grid on; ax = gca; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1; box on;

subplot(2,1,2); hold on;
plot(time1*1e6, vp1, '-', 'color', colorsNORM(1), 'LineWidth', 1);
plot(time1*1e6, vs1, '-', 'color', colorsPAST(1), 'LineWidth', 1);
legend({'P', 'S'}, 'Orientation', 'vertical', 'Location', 'southeast');
xlabel('Time (µs)');  ylabel('Voltage (V)');
ylim([-500 500]); %xlim([0,1]);
grid on; ax = gca; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1; box on;
set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 12);
%exportgraphics(fig, 'results/waveforms300V-rw.pdf', 'BackgroundColor', 'none', 'ContentType', 'vector');


%% Plot converter ZVS validation waveforms

% Define filename
base = 'data/20250115_cllc_3dmit__';

%for i = 0:65  % Loop the files
i = 100;  % Choos a specific file
file = sprintf('%03d', i);

% Get data tables
data_ir1 = load([base file '_ch2.mat']);
data_vds = load([base file '_ch5.mat']);
data_vg1 = load([base file '_ch6.mat']);

% Extract the data arrays
time1 = data_ir1.time;
time1 = time1 - time1(1);
ir1 = data_ir1.data;
vds = data_vds.data;
vg1 = data_vg1.data;

% Calculate parameters
vds_rms = sqrt(mean(vds.^2));
ir1_rms = sqrt(mean(ir1.^2));
vg1_avg = mean(vg1);
po1_avg = vds_rms*vg1_avg;


% Plotting
fig = figure('units','centimeters','position',[[4 4] [20 4.5]]);  hold on;

yyaxis right
plot(time1*1e6, vg1, '-', 'color', colorsPAST(6), 'LineWidth', 0.75);
ylabel('Gate Voltage (V)');
ylim([-2, 12]);

yyaxis left
plot(time1*1e6, vds, '-', 'color', colorsNORM(1), 'LineWidth', 0.5);
ylabel('Drain-Source Voltage (V)'); xlabel('Time (µs)');  
ylim([-2, 12].*(500/12));

grid on; ax = gca; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1; box on;
set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 12);
ax.YAxis(1).Color = colorsDARK(1); ax.YAxis(2).Color = colorsDARK(1);
%exportgraphics(fig, 'results/waveforms_zvs-rw.pdf', 'BackgroundColor', 'none', 'ContentType', 'vector');
