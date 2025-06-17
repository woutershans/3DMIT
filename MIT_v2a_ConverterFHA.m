close all; clear;
colorsNORM = ["#505150", "#FF5050", "#77C8A6", "#42ACC6", "#588DCA", "#897AFA", "#9A9CA1"];
colorsPAST = ["#BFBFBF", "#FF9C9C", "#BEEBD8", "#9BD9E9", "#88ABCC", "#C7BDF9", "#C6C9CF"];
colorsDARK = ["#000000", "#992F2F", "#417C61", "#3C7A84", "#3D618A", "#545096", "#000000"];
colorsPALE = ["#E9E9E9", "#FFDDDD", "#E8F8F2", "#DCF2F8", "#D6E2ED", "#ECE8FD", "#000000"];


%% CLLC design 
% based on Texas Instruments TIDM-02013 design guide

Po = linspace(1, 6000, 7);  % [W] output power
fs = logspace(5,6,1000);  % [Hz] frequency
fr = 500e3;  % [Hz] resonant frequency
N = 1;  % [-] turns ratio
Vo_nom = 400;  % [V] nominal output voltage
Io_nom = Po./Vo_nom;  % [A] steps from zero to max current
RL_dc = Vo_nom./Io_nom;  % [Ohm] output load to represent different output current and power (TBC)
RL_eff = 8/pi^2.*RL_dc;  % [Ohm] effective secondary load with FHA 
Lm = 18e-6;  % [H] magnetising inductance for ZVS condition
Ln = 15;  % [-] inductor ratio for trade-off between voltage gain vs losses
Lrp = Lm/Ln;  % [H] primary resonant tank series inductor
Lrs = Lrp;  % [H] secondary resonant tank series inductor when N=1
Crp = 1./(4*pi^2.*Lrp.*fr.^2);  % [F] primary resonant tank capacitor
Crs = Crp;  % [F] secondary resonant tank capacitor when N=1

Gsp = zeros(length(Io_nom), length(fs));
gain = zeros(length(Io_nom), length(fs));
for x = 1:length(Io_nom)
    LrsX = Lrs.*N^2;
    CrsX = Crs./N^2;
    RLX = RL_eff(x).*N^2;
    
    % Calculate the impedances
    Zm = 2*pi.*fs.*Lm*1i;  % [Ohm]
    Z_Lrp = 2*pi.*fs.*Lrp*1i;  % [Ohm]
    Z_Lrs = 2*pi.*fs.*Lrs*1i;  % [Ohm]
    Z_LrsX = 2*pi.*fs.*LrsX*1i;  % [Ohm]
    Z_Crp = 1./(2*pi*fs*Crp*1i);  % [Ohm]
    Z_Crs = 1./(2*pi*fs*Crs*1i);  % [Ohm]
    Z_CrsX = 1./(2*pi*fs*CrsX*1i);  % [Ohm]
    
    Zrp = Z_Lrp+Z_Crp;  % [Ohm]
    Zrs = Z_Lrs+Z_Crs;  % [Ohm]
    ZrsX = Z_LrsX+Z_CrsX;  % [Ohm]
    
    Z_rsX_rlX = ZrsX+RLX;  % [Ohm]
    Z_m_rsX_rlX = (1./Zm+1./Z_rsX_rlX).^-1;  % [Ohm]
    Z_tot = Zrp+Z_m_rsX_rlX;  % [Ohm]
    
    % Calculate the Voltage Ratio Vsec/Vprim for the circuit (FHA)
    Gsp(x,:) = abs((Z_m_rsX_rlX.*RLX)./(N.*Z_tot.*Z_rsX_rlX));  % [-] gain Vsec/Vprim
    gain(x,:) = 20*log10(Gsp(x,:));  % [dB] gain in decibels
end

% Plotting
plotCLLC = true;
if plotCLLC == true
    fig = figure('units','centimeters','position',[[2 2] [25 12]]);  hold on;
    subplot(2,1,1); hold on;
    plot(fs.*1e-3, Gsp(1,:), '-', 'color', colorsPAST(5), 'LineWidth', 1.2);
    plot(fs.*1e-3, Gsp(2,:), '-', 'color', colorsNORM(5), 'LineWidth', 1.2);
    plot(fs.*1e-3, Gsp(3,:), '-', 'color', colorsDARK(5), 'LineWidth', 1.2);
    plot(fs.*1e-3, Gsp(4,:), '-', 'color', colorsPAST(6), 'LineWidth', 1.2);
    plot(fs.*1e-3, Gsp(5,:), '-', 'color', colorsNORM(6), 'LineWidth', 1.2);
    plot(fs.*1e-3, Gsp(6,:), '-', 'color', colorsDARK(6), 'LineWidth', 1.2);
    plot(fs.*1e-3, Gsp(7,:), '-', 'color', colorsDARK(1), 'LineWidth', 1.2);
    for i=1:length(RL_eff)
        legendCell{i} = num2str(Po(i)*1e-3, 'Power %.1f kW');  % add to legend
    end
    xlabel('Frequency (kHz)'); ylabel('Voltage Ratio (-)');
    ylim([0 100])
    legend(legendCell, 'Orientation', 'vertical','Location','northeast');
    ax = gca; grid on; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1;
    ax.XScale = 'log'; ax.YScale = 'log'; box on;

    subplot(2,1,2); hold on;
    plot(fs.*1e-3, Gsp(1,:), '-', 'color', colorsPAST(5), 'LineWidth', 1.2);
    plot(fs.*1e-3, Gsp(2,:), '-', 'color', colorsNORM(5), 'LineWidth', 1.2);
    plot(fs.*1e-3, Gsp(3,:), '-', 'color', colorsDARK(5), 'LineWidth', 1.2);
    plot(fs.*1e-3, Gsp(4,:), '-', 'color', colorsPAST(6), 'LineWidth', 1.2);
    plot(fs.*1e-3, Gsp(5,:), '-', 'color', colorsNORM(6), 'LineWidth', 1.2);
    plot(fs.*1e-3, Gsp(6,:), '-', 'color', colorsDARK(6), 'LineWidth', 1.2);
    plot(fs.*1e-3, Gsp(7,:), '-', 'color', colorsDARK(1), 'LineWidth', 1.2);
    xlabel('Frequency (kHz)'); ylabel('Voltage Ratio (-)');
    xlim([250 1000]); ylim([0.9 1.3])
    ax = gca; grid on; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1;
    ax.XScale = 'log'; ax.YScale = 'log'; box on;

    set(findall(gcf, '-property', 'FontName'), 'FontName', 'Cambria', 'FontSize', 12);
    %figName = "cllc_fr-rw"; export_fig(fullfile(figName), '-pdf', '-nocrop', '-transparent');
end

