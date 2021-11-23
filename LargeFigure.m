% Make figure large
% 
% figurehandle = figure handle (e.g., use gcf to refer to current figure)
% bottommargin = margin to leave at bottom for increased taskbar, etc.
% varargin{1} is leftmargin
% e.g., LargeFigure(gcf, 0.15)
% e.g., LargeFigure(gcf, 0.15, 0.25)

function LargeFigure(figurehandle, bottommargin, varargin)

if nargin>2
    leftmargin = varargin{1};
else    
    leftmargin = 0;
end

set(figurehandle, 'units', 'normalized', 'outerposition', [leftmargin, bottommargin, 1-leftmargin, 1-bottommargin]);

