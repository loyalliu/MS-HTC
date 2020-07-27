function MSHTC_textprogressbar(c,n, varargin)
% This function creates a text progress bar. It should be called with a 
% STRING argument to initialize and terminate. Otherwise the number correspoding 
% to progress in % should be supplied.
% INPUTS:   C   Either: Text string to initialize or terminate 
%                       Percentage number to show progress 
% OUTPUTS:  N/A
% Example:  Please refer to demo_textprogressbar.m

% Author: Paul Proteus (e-mail: proteus.paul (at) yahoo (dot) com)
% Version: 1.0
% Changes tracker:  29.06.2010  - First version

% Inspired by: http://blogs.mathworks.com/loren/2007/08/01/monitoring-progress-of-a-calculation/

% Modified by Yilong Liu, 2020-07

if nargin > 2
   recon_info = varargin{1}; 
else
    recon_info = ' ';
end

%% Initialization
persistent strCR;           %   Carriage return pesistent variable
persistent tmark_progressbar

% Vizualization parameters
strPercentageLength = 10;   %   Length of percentage string (must be >5)
strDotsMaximum      = 10;   %   The total number of dots in a progress bar

dot_mode = 0;

%% Main 
if isempty(strCR) && ~ischar(c)
    % Progress bar must be initialized with a string
    error('The text progress must be initialized with a string');
elseif isempty(strCR) && ischar(c)
    % Progress bar - initialization
    fprintf('%s',c);
    strCR = -1;
    tmark_progressbar = tic;
elseif ~isempty(strCR) && ischar(c)
    % Progress bar  - termination
    strCR = [];  
    fprintf(['    ' c '\n']);
elseif isnumeric(c)
    % Progress bar - normal progress
%     c = floor(c);
    c = double(c);n = double(n);
    percentageOut = [num2str(floor(c/n*100)) '%%'];
    timerval = toc(tmark_progressbar); 
    EstimateTime = ceil(timerval*(n/c-1));
    EstimateTime = ['>Remaining: ' num2str(EstimateTime) 's, ' recon_info];
    percentageOut = [percentageOut repmat('-',1,strPercentageLength-length(percentageOut)-1)];
    if dot_mode
        nDots = floor(c/n*strDotsMaximum);
        dotOut = ['[' repmat('.',1,nDots) repmat(' ',1,strDotsMaximum-nDots) ']'];
        strOut = [percentageOut dotOut EstimateTime];
    else
        strOut = [percentageOut EstimateTime];
    end
    % Print it on the screen
    if strCR == -1
        % Don't do carriage return during first run
        fprintf(strOut);
    else
        % Do it during all the other runs
        fprintf([strCR strOut]);
    end
    
    % Update carriage return
    strCR = repmat('\b',1,length(strOut)-1);
    
else
    % Any other unexpected input
    error('Unsupported argument type');
end
