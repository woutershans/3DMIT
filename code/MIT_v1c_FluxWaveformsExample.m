%clearvars; close all;
colorsNORM = ["#505150", "#FF5050", "#77C8A6", "#42ACC6", "#588DCA", "#897AFA", "#9A9CA1"];
colorsPAST = ["#BFBFBF", "#FF9C9C", "#BEEBD8", "#9BD9E9", "#88ABCC", "#C7BDF9", "#C6C9CF"];
colorsDARK = ["#000000", "#992F2F", "#417C61", "#3C7A84", "#3D618A", "#545096", "#000000"];
colorsPALE = ["#E9E9E9", "#FFDDDD", "#E8F8F2", "#DCF2F8", "#D6E2ED", "#ECE8FD", "#000000"];
hex2rgb = @(hex) sscanf(hex(2:end),'%2x%2x%2x',[1 3])/255;

%% --------------------------------------------------------------------------------------
% Example flux density waveforms based on PLECS converter currents.
% --------------------------------------------------------------------------------------


% Load the current waveform data from the CSV file
data = readtable('data/ResonantCurrent_TI.csv');

% Extract the time and current data
time = data.Time_S-0.006309707461001;   % Time in seconds
Ip = data.L1_InductorCurrent;          % Primary current (i_p) in Amperes
Is = data.R4_ResistorCurrent;          % Secondary current (i_s) in Amperes

% Sweep currents
steps = 10;
scale = linspace(0,1,steps);
Ip = scale .* Ip;
Is = scale .* Is;

% Define winding parameters
N = 7;  % Turns ratio
dN = 1; % Adjustment parameter

Np1 = (N+dN)/2;
Np2 = (N-dN)/2;
Ns1 = (N-dN)/2;
Ns2 = (N+dN)/2;

% Geometry input parameters.
la = 79.3e-3;  % [m] top path length
lb = 61.9e-3;  % [m] centre path length
lc = 79.3e-3;  % [m] bottom path length
lg = 200e-6;  % [m] airgap 1 length
Aa = 260e-6;  % [m²] top path area
Ab = 260e-6;  % [m²] centre path area
Ac = 260e-6;  % [m²] bottom path area
Ag = Aa.*1.2;  % Fringing effect
mu_r = 1200;  % [-] relative permeability
mu_0 = 4.*pi.*1e-7;  % [H/m]

% Calculate reluctance of the elements.
Ra = la./(mu_0.*mu_r.*Aa);  % [A/Wb] top path reluctance
Rb = lb./(mu_0.*mu_r.*Ab);  % [A/Wb] centre path reluctance
Rc = lc./(mu_0.*mu_r.*Ac);  % [A/Wb] bottom path reluctance
Rg = lg./(mu_0.*Ag);  % [A/Wb] top airgaps reluctance

% Compute PhiA1, PhiB, PhiA2 for each time step
PhiA1 = (Ip.*Np1.*Ra + Ip.*Np1.*Rb + Ip.*Np2.*Rb + 2.*Ip.*Np1.*Rg - Is.*Ns1.*Ra - Is.*Ns1.*Rb - Is.*Ns2.*Rb - 2.*Is.*Ns1.*Rg)./((Ra + 2.*Rg).*(Ra + 2.*Rb + 2.*Rg));
PhiB = -(Ip.*Np1 - Ip.*Np2 - Is.*Ns1 + Is.*Ns2)./(Ra + 2.*Rb + 2.*Rg); 
PhiA2 = (Ip.*Np2.*Ra + Ip.*Np1.*Rb + Ip.*Np2.*Rb + 2.*Ip.*Np2.*Rg - Is.*Ns2.*Ra - Is.*Ns1.*Rb - Is.*Ns2.*Rb - 2.*Is.*Ns2.*Rg)./((Ra + 2.*Rg).*(Ra + 2.*Rb + 2.*Rg));  

B_A1 = PhiA1./Aa;
B_B = PhiB./Ab;
B_A2 = PhiA2./Ac;

% Plotting
plotLines = true;
if plotLines == true
    fig = figure('units', 'centimeters', 'position', [[1 1] [20 15]]); hold on;

    subplot(4, 1, 1); hold on;
    plot(time*1e6, Ip, '-', 'Color', colorsDARK(1), 'LineWidth', 0.25);
    plot(time*1e6, Ip(:,steps), '-', 'Color', colorsDARK(1), 'LineWidth', 1.25);
    plot(time*1e6, Is, '-', 'Color', colorsPAST(1), 'LineWidth', 0.25);
    plot(time*1e6, Is(:,steps), '-', 'Color', colorsPAST(1), 'LineWidth', 1.25);
    xlabel('Time (µs)'); ylabel('Current (A)');
    legend("Prim.", "Sec.")
    xlim([0 2/500000].*1e6); ylim([-7 7]);

    subplot(4, 1, 2); hold on;
    plot(time*1e6, B_A1*1e3, '-', 'Color', colorsDARK(5), 'LineWidth', 0.25);
    plot(time*1e6, B_A1(:,steps)*1e3, '-', 'Color', colorsDARK(5), 'LineWidth', 1.25);
    xlabel('Time (µs)'); ylabel('B (mT)');
    legend("Core A1")
    xlim([0 2/500000]*1e6); ylim([-130 130]);

    subplot(4, 1, 3); hold on;
    plot(time*1e6, B_B*1e3, '-', 'Color', colorsPAST(5), 'LineWidth', 0.25);
    plot(time*1e6, B_B(:,steps)*1e3, '-', 'Color', colorsPAST(5), 'LineWidth', 1.25);
    xlabel('Time (µs)'); ylabel('B (mT)');
    legend("Core B")
    xlim([0 2/500000].*1e6); ylim([-40 40]);

    subplot(4, 1, 4); hold on;
    plot(time*1e6, B_A2*1e3, '-', 'Color', colorsDARK(5), 'LineWidth', 0.25);
    plot(time*1e6, B_A2(:,steps)*1e3, '-', 'Color', colorsDARK(5), 'LineWidth', 1.25);
    xlabel('Time (µs)'); ylabel('B (mT)');
    legend("Core A2")
    xlim([0 2/500000].*1e6); ylim([-130 130]);

    set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 14);
    %exportgraphics(fig, "results/waves_B-rw.pdf", 'BackgroundColor', 'none', 'ContentType', 'vector');
end

plotCurrents = true;
if plotCurrents == true
    fig = figure('units', 'centimeters', 'position', [[2 2] [25 6]]); hold on;
    plot(time, Ip, '-', 'Color', colorsDARK(1), 'LineWidth', 0.25);
    plot(time, Is, '-', 'Color', colorsDARK(5), 'LineWidth', 0.25);
    xlabel('Time (s)'); ylabel('Current (A)');
    xlim([0 3/500000])

    set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 12);
    %exportgraphics(fig, "results/waves_I-rw.pdf", 'BackgroundColor', 'none', 'ContentType', 'vector');
end

