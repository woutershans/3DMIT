function cmap = cmapSpectral(nColors)
% CMAP_SPECTRAL Returns a continuous colormap interpolating between
% 10 specified hex colors.
%
% Usage:
%   cmap = cmap_spectral();        % Returns 256-color map by default
%   cmap = cmap_spectral(128);     % Returns 128-color map
%
% Example:
%   [X, Y, Z] = peaks(200);
%   contourf(X, Y, Z, 20, 'LineColor', 'none');
%   colormap(cmap_spectral); colorbar;

    if nargin < 1
        nColors = 256;  % Default number of colors
    end

    % List of hex color codes (10 colors)
    hexColors = {
        "#9e0142"
        "#d53e4f"
        "#f46d43"
        "#fdae61"
        "#fee08b"
        "#e6f598"
        "#abdda4"
        "#66c2a5"
        "#3288bd"
        "#5e4fa2"
    };

    % Convert hex to RGB
    numPoints = length(hexColors);
    rgbColors = zeros(numPoints, 3);
    for i = 1:numPoints
        rgbColors(i, :) = hex2rgb(char(hexColors{i}));
    end

    % We will piecewise interpolate between each pair of adjacent colors
    nSegments = numPoints - 1;   % 9 segments for 10 colors
    nSegmentBase = floor(nColors / nSegments);  % base number of steps per segment

    cmap = [];
    for s = 1:nSegments
        startColor = rgbColors(s, :);
        endColor   = rgbColors(s + 1, :);

        % Determine how many points to assign to this segment
        % so that total ends up being nColors.
        if s < nSegments
            nSegmentPoints = nSegmentBase;
        else
            % The last segment takes any remainder
            nSegmentPoints = nColors - size(cmap, 1);
        end

        % Generate linearly spaced colors for this segment
        segColors = [
            linspace(startColor(1), endColor(1), nSegmentPoints)', ...
            linspace(startColor(2), endColor(2), nSegmentPoints)', ...
            linspace(startColor(3), endColor(3), nSegmentPoints)'
        ];

        % Concatenate with the running colormap
        cmap = [cmap; segColors]; %#ok<AGROW>

        % Avoid duplicating the last color of the segment in the next segment
        % (unless we are at the very end).
        if s < nSegments
            cmap(end, :) = [];
        end
    end

end