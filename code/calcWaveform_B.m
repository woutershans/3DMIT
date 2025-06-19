function [B, Bpeak] = calcWaveform_B(V,t,Ae,N)
%CALCWAVEFORM_B Calculate the flux density (B) waveform from voltage V(t) waveform.
%   Based on known transformer parameters: effective area (Ae), number of turns (N)

colors = ["black", "#FF5050", "#77C8A6", "#42ACC6", "#588DCA", "#897AFA", "#9A9CA1", "red", "green", "blue", "cyan", "magneta", "yellow"];
colorsPASTEL = ["#3B3B3B", "#FF9C9C", "#BEEBD8", "#9BD9E9", "#88ABCC", "#C7BDF9", "#C6C9CF"];
colorsDARK = ["#000000", "#3D618A", "#000000", "#000000", "#3D618A", "#000000", "#000000"];
colorsR = [[153, 47, 47]./255 [255, 80, 80]./255 [255, 155, 155]./255];
colorsG = [[81, 138, 114]./255 [119, 200, 166]./255 [165, 213, 191]./255];
colorsB = [[61, 97, 138]./255 [88, 141, 202]./255 [124, 159, 200]./255];

B = 1./(Ae.*N).*cumtrapz(t,V);  % [T] calculated B by integrating V and hopkinson's law
B = B-mean(B);  % [T] centred B waveform
Bpeak = max(abs(B));

% Plot the B waveform with V
plotB = false;
if plotB == true
    figure('units','centimeters','position',[[2 2] [15 10]]); hold on;
    colororder({'k','k'});
    yyaxis left;
    h0 = plot(t, V, '-', 'color', colors(5), 'LineWidth',2);
    ylabel('V (V)');
    ylim(1.5.*[min(V) max(V)])
    yyaxis right;
    h0 = plot(t, B, '-', 'color', colors(2), 'LineWidth',2);
    xlabel('t (s)'); ylabel('B (T)');
    xlim([0, t(end)]); ylim(1.5.*[min(B) max(B)])
    title('Flux density waveform');
    legend({'Voltage', 'Flux density'}, 'Orientation', 'vertical', 'Location', 'northeast');
    grid on; box on;
    ax = gca; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1;
end

end
