%clearvars; close all;
colorsNORM = ["#505150", "#FF5050", "#77C8A6", "#42ACC6", "#588DCA", "#897AFA", "#9A9CA1"];
colorsPAST = ["#BFBFBF", "#FF9C9C", "#BEEBD8", "#9BD9E9", "#88ABCC", "#C7BDF9", "#C6C9CF"];
colorsDARK = ["#000000", "#992F2F", "#417C61", "#3C7A84", "#3D618A", "#545096", "#000000"];
colorsPALE = ["#E9E9E9", "#FFDDDD", "#E8F8F2", "#DCF2F8", "#D6E2ED", "#ECE8FD", "#000000"];
hex2rgb = @(hex) sscanf(hex(2:end),'%2x%2x%2x',[1 3])/255;

%% --------------------------------------------------------------------------------------
% Dowell's equation for PCB windings analysis
% --------------------------------------------------------------------------------------
% This section calculates AC resistance ratios for different PCB parameters
% using Dowell's equation for transformer/magnetic component design


% Example converter parameters.
fsw = logspace(3,8,200);  % [Hz] Switching frequency range (1kHz-100MHz)
J = 9e6;                  % [A/m²] Average current density
I = 10;                   % [A] Rated current

% Winding parameters
N = 8;                    % [-] Number of turns
oz = [1 2 3 4];           % [-] Copper weights (ounces) to analyze

% MMF profile factor "m" (determines winding arrangement)
m = 0.5:0.5:10;           % MMF profile factor range (0.5=optimal interleaving)

% Physical constants
rho_cu = 2.3e-08;         % [Ohm*m] Copper resistivity (20°C)
mu_0 = 4*pi*10^-7;        % [H/m] Vacuum permeability

% Create parameter grids for 3D calculations
[fsw_grid, m_grid] = meshgrid(fsw, m);  % Grids for frequency and MMF factor


%% Create custom colormap for contour plots
color1 = hex2rgb(char("#ffffff"));  % Start color (white)
color2 = hex2rgb(char(colorsPAST(1)));  % Middle color (light gray)
color3 = hex2rgb(char(colorsDARK(5)));  % End color (dark blue)
nColors = 256;            % Total colormap resolution
nSegment1 = floor(nColors / 2);  % First gradient segment
nSegment2 = nColors - nSegment1; % Second gradient segment
% Generate colormap segments
cmap1 = [linspace(color1(1), color2(1), nSegment1)', ...
         linspace(color1(2), color2(2), nSegment1)', ...
         linspace(color1(3), color2(3), nSegment1)'];
cmap2 = [linspace(color2(1), color3(1), nSegment2)', ...
         linspace(color2(2), color3(2), nSegment2)', ...
         linspace(color2(3), color3(3), nSegment2)'];
cmapdark = [cmap1; cmap2];  % Combined colormap


%% Main analysis and plotting
fig = figure('units','centimeters','position',[[1 1] [24 22]]);
Fr_4oz = [];  % Initialize storage for 4oz copper results

% Loop through different copper weights
for idx = 1:length(oz)  
    h = oz(idx).*0.035e-3;  % [m] Convert oz to thickness (35μm/oz)
    
    % Calculate skin depth matrix (frequency-dependent)
    delta_grid = sqrt(2*rho_cu./(mu_0*2*pi.*fsw_grid));  % [m] Skin depth
    
    % Dimensionless thickness parameter (ξ = h/δ)
    xi_grid = h./delta_grid;  
    
    % Dowell's equation: AC/DC resistance ratio (Fr)
    Fr = 0.5.*xi_grid.*( (sinh(xi_grid)+sin(xi_grid))./(cosh(xi_grid)-cos(xi_grid)) ...
        + ((2.*abs(m_grid)-1).^2).*(sinh(xi_grid)-sin(xi_grid))./(cosh(xi_grid)+cos(xi_grid)) );
    
    % Store 4oz results for later detailed analysis
    if oz(idx) == 4
        Fr_4oz = Fr;  
    end

    % Contour plot for current copper weight
    subplot(3,2,idx);
    clevels = [1.1, 1.2, 1.5, 2, 5, 10, 20, 50, 100 200 500 1000 2000 5000]; % Contour levels
    
    % Create filled contour plot
    contourf(fsw_grid, m_grid, Fr, 100, 'LineStyle', 'none'); hold on;
    [C,hc] = contour(fsw_grid, m_grid, Fr, clevels, 'LineColor', 'k', 'LineWidth', 1);
    
    % Format plot
    clabel(C, hc, 'FontSize', 8, 'FontName', 'Cambria', 'Color', 'k'); hold off;
    colormap(cmapdark); 
    c = colorbar; 
    c.Label.String = 'AC Resistance Ratio (-)'; 
    xlabel('Frequency (Hz)'); ylabel('MMF Ratio (-)');
    title(sprintf('%g oz Copper', oz(idx)), 'FontWeight','normal'); % Added descriptive title
    xlim([1e4 1e7]);                % Focus on 10kHz-10MHz range
    set(gca, 'XScale', 'log');      % Logarithmic frequency axis
    caxis([1,100]);                 % Color axis limits
    set(gca, 'ColorScale', 'log');  % Logarithmic color scale
end


    % Detailed plots for 4oz copper (m=0.5,1,4 cases)

    m_values = [0.5, 1, 4];  % Specific interleaving cases to extract
    [~, m_idx1] = min(abs(m - m_values(1)));  % Index for m=0.5 (partial interleave)
    [~, m_idx2] = min(abs(m - m_values(2)));  % Index for m=1 (full interleave)
    [~, m_idx3] = min(abs(m - m_values(3)));  % Index for m=4 (non-interleave)
    
    % Extract resistance ratios for these specific cases
    Fr_part = Fr_4oz(m_idx1, :);  % Partial interleaving
    Fr_full = Fr_4oz(m_idx2, :);  % Full interleaving
    Fr_nonn = Fr_4oz(m_idx3, :);  % Non-interleaved
    
    % Plot comparison curves (log scale)
    subplot(3,2,5); hold on;
    plot(fsw, Fr_nonn, '-', 'Color', colorsDARK(1), 'LineWidth', 1.5);
    plot(fsw, Fr_full, '-.', 'Color', colorsDARK(5), 'LineWidth', 1.5);
    plot(fsw, Fr_part, '--', 'Color', colorsNORM(2), 'LineWidth', 1.5); 
    ylim([1 200]); xlim([1e3 1e8]); % Full frequency range
    xlabel('Frequency (Hz)'); ylabel('Resistance Ratio Rac/Rdc (-)');
    legend(["Non-Interl.", "Full-Interl.", "Partial-Interl."], ...
           'Orientation', 'vertical', 'Location', 'northwest');
    grid on; ax = gca; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1;
    ax.XScale = 'log'; ax.YScale = 'log'; box on;
    
    
    % Plot zoomed comparison (linear y-scale region)
    subplot(3,2,6); hold on;
    plot(fsw, Fr_nonn, '-', 'Color', colorsDARK(1), 'LineWidth', 1.5);
    plot(fsw, Fr_full, '-.', 'Color', colorsDARK(5), 'LineWidth', 1.5);
    plot(fsw, Fr_part, '--', 'Color', colorsNORM(2), 'LineWidth', 1.5); 
    ylim([1 2]); xlim([100e3 1e6]); % Zoomed region (100kHz-1MHz)
    xlabel('Frequency (Hz)'); ylabel('Resistance Ratio Rac/Rdc (-)');
    grid on; ax = gca; ax.GridLineStyle = ':'; ax.GridColor = 'k'; ax.GridAlpha = 1;
    ax.XScale = 'log'; ax.YScale = 'log'; box on;
    
    % Apply consistent font styling
    set(findall(fig, '-property', 'FontName'), 'FontName', 'Cambria', 'Fontsize', 12);
    figName = "../results/Dowell_grid-rw.pdf"; exportgraphics(fig, figName, 'BackgroundColor', 'none', 'ContentType', 'vector');
    figName = "../results/Dowell_grid-rw.png"; exportgraphics(fig, figName, 'BackgroundColor', 'white', 'Resolution', 600);



%% APPENDIX: additional calculations
% -------------------------------------------------------------------------


%% Frequency analysis at target Fr value
findFreq = false;  % Flag to enable/disable this analysis
if findFreq
    Fr_target = 1.1;  % Target resistance ratio
    fsw = fsw(:);     % Ensure frequency vector orientation
    
    % Find frequencies where each curve hits target Fr
    freq_nonn = interp1(Fr_nonn(:), fsw, Fr_target, 'linear', 'extrap');
    freq_full = interp1(Fr_full(:), fsw, Fr_target, 'linear', 'extrap');
    freq_part = interp1(Fr_part(:), fsw, Fr_target, 'linear', 'extrap');

    % Display results
    fprintf('\n---- Frequency Analysis (Fr=%.1f) ----\n', Fr_target);
    fprintf('Non-Interleaved: %.2f kHz\n', freq_nonn/1e3);
    fprintf('Full-Interleaved: %.2f kHz\n', freq_full/1e3);
    fprintf('Partial-Interleaved: %.2f kHz\n\n', freq_part/1e3);
end

%% Calculate Fr at specific operating point
calcFR = false;  % Flag to enable/disable this analysis
if calcFR
    % Target parameters
    fsw = 1e6;        % [Hz] Operating frequency
    oz_value = 5;     % [oz] Copper weight
    m_values = [0.5, 1, 4];  % Interleaving cases
    
    % Calculate skin parameters
    h = oz_value * 0.035e-3;  % [m] Copper thickness
    delta = sqrt(2 * rho_cu / (mu_0 * 2 * pi * fsw));  % [m] Skin depth
    xi = h / delta;           % Dimensionless thickness
    
    % Calculate Fr for each interleaving type
    Fr_values = zeros(size(m_values));
    for i = 1:length(m_values)
        m_val = m_values(i);
        Fr = 0.5 * xi * ( (sinh(xi) + sin(xi)) / (cosh(xi) - cos(xi)) ...
            + ((2 * abs(m_val) - 1)^2) * (sinh(xi) - sin(xi)) / (cosh(xi) + cos(xi)) );
        Fr_values(i) = Fr;
    end

    % Display results
    fprintf('\n---- AC Resistance at %.1fMHz (%g oz) ----\n', fsw/1e6, oz_value);
    fprintf('Partial-Interleaving: Fr = %.3f\n', Fr_values(1));
    fprintf('Full-Interleaving: Fr = %.3f\n', Fr_values(2));
    fprintf('Non-Interleaving: Fr = %.3f\n\n', Fr_values(3));
end