% tmseeg_init() - function to read in a set of tmseeg variables as a
% structure
%
% Author: Matthew Frehlich, 2016 

% Copyright (C) 2016 Matthew Frehlich, UToronto,
% matthew.frehlich@mail.utoronto.ca
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function[INIT_VARS] = tmseeg_init()
global xshowmin xshowmax

xshowmin = -200;
xshowmax = 500;

INIT_VARS = struct;

%Step 1 - Initial Processing
INIT_VARS.RESAMPLE_FREQ = 1000;
INIT_VARS.CHANLOC_FILE  = 'standard-10-5-cap385.elp';
INIT_VARS.EPCH_STRT     = -1000;
INIT_VARS.EPCH_END      = 1000;
INIT_VARS.BASELINE_RNG  = [-650 -250];

%Step 2
INIT_VARS.ISI = 100;
INIT_VARS.TMS_DSP_XMIN   = -150;
INIT_VARS.TMS_DSP_XMAX   = 50;
INIT_VARS.SLIDER_MIN     = -5;
INIT_VARS.SLIDER_MAX     = 10;
INIT_VARS.PULSE_DURATION = 0;

%Step 3 - Remove Trials and Channels
INIT_VARS.NUM_BAD_CHANS  = 5;
INIT_VARS.NUM_BAD_TRIALS = 5;
INIT_VARS.PCT_BAD_CHANS  = 10;
INIT_VARS.PCT_BAD_TRIALS = 10;
INIT_VARS.HEAD_PLOT      = 1;
INIT_VARS.PLT_CHN_YMIN   = -400;
INIT_VARS.PLT_CHN_YMAX   = 400;

%Step 3 & 9, ATTRIBUTE extraction
INIT_VARS.PULSE_ST  = 0;
INIT_VARS.PULSE_END = 50;
INIT_VARS.TIME_ST   = -1000;
INIT_VARS.TIME_END  = 1000;
INIT_VARS.FREQ_MIN  = 1;
INIT_VARS.FREQ_MAX  = 80;

%Step 6
INIT_VARS.FIR_FILTER_ORDER = 80;
INIT_VARS.IIR_FILTER_ORDER = 2;

%Step 7, ICA2
INIT_VARS.ICA_COMP_PCT    = 100;
INIT_VARS.ICA2_COMP_CHANS = 0;

%Step 8, ICA2
INIT_VARS.UPD_WDW_STRT    = -100;
INIT_VARS.UPD_WDW_END     = 500;
INIT_VARS.UPD_WDW_YMIN    = -50;
INIT_VARS.UPD_WDW_YMAX    = 50;
INIT_VARS.KURTOSIS_THRESH = 15;

%Step 9 - Remove Trials and Channels
INIT_VARS.NUM_BAD_CHANS_2  = 5;
INIT_VARS.NUM_BAD_TRIALS_2 = 5;
INIT_VARS.PCT_BAD_CHANS_2  = 10;
INIT_VARS.PCT_BAD_TRIALS_2 = 10;
INIT_VARS.HEAD_PLOT_2      = 1;
INIT_VARS.PLT_CHN_YMIN_2   = -400;
INIT_VARS.PLT_CHN_YMAX_2   = 400;

%Vew Data
INIT_VARS.YSHOWLIMIT = 100;



end


