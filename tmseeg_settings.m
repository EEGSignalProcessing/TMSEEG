% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez,Faranak Farzan
%         2016
%         Ben Schwartzmann
%         2017

% tmseeg_settings() - User-adjustable variables for use in TMSEEG toolbox.
% 
% Input: S - parent GUI information (structure)

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

function [] = tmseeg_settings(S)

global backcolor
hfig = figure('Menubar','none',...
              'Toolbar','none',...
              'Units','normalized',...
              'Name','tmseeg_settings',...
              'Color',backcolor,...
              'Numbertitle','off',...
              'Resize','off',...
              'Position',[0.3 0.3 0.3 0.3],...
              'DockControls','off');

step1_button = uicontrol('Parent', hfig,'Style','pushbutton',... 
                    'Units','normalized',...
                    'Position',[0.2 0.86 0.6 0.10],...
                    'Tag','step1_set',...
                    'String','Initial Processing',...
                    'Callback',{@step1_callback,S}); %#ok
step2_button = uicontrol('Parent', hfig,'Style','pushbutton',...
                    'Units','normalized',...
                    'Position',[0.2 0.74 0.6 0.10],...
                    'Tag','step2_set',...
                    'String','TMS Pulse Removal',...
                    'Callback',{@step2_callback,S}); %#ok
step3_button = uicontrol('Parent', hfig,'Style','pushbutton',...
                    'Units','normalized',...
                    'Position',[0.2 0.60 0.6 0.10],...
                    'Tag','step3_set',...
                    'String','Remove Bad Trials and Channels',...
                    'Callback',{@step3_callback, S}); %#ok
step7_button = uicontrol('Parent', hfig,'Style','pushbutton',...
                    'Units','normalized',...
                    'Position',[0.2 0.48 0.6 0.10],...
                    'Tag','step7_set',...
                    'String','ICA Round 2',...
                    'Callback',{@step7_callback, S}); %#ok
step8_button = uicontrol('Parent', hfig,'Style','pushbutton',...
                    'Units','normalized',...
                    'Position',[0.2 0.36 0.6 0.10],...
                    'Tag','step8_set',...
                    'String','ICA 2 Component Removal',...
                    'Callback',{@step8_callback, S}); %#ok
step9_button = uicontrol('Parent', hfig,'Style','pushbutton',...
                    'Units','normalized',...
                    'Position',[0.2 0.24 0.6 0.10],...
                    'Tag','step9_set',...
                    'String','Remove Bad Trials and Channels 2',...
                    'Callback',{@step9_callback, S}); %#ok
show_button = uicontrol('Parent', hfig,'Style','pushbutton',...
                    'Units','normalized',...
                    'Position',[0.2 0.12 0.6 0.10],...
                    'Tag','show_set',...
                    'String','View Data',...
                    'Callback',{@show_callback, S}); %#ok
end

function step1_callback(varargin)
% Settings call for step 1: Initial Processing
global VARS
S = varargin{3};

%Pop-up display settings
prompt = {'Enter Resampling Frequency:',...
            'Baseline Calculation Range'};
dlg_title = 'Step1 Settings';
num_lines = 1;
defaultans = {num2str(VARS.RESAMPLE_FREQ),...
              num2str(VARS.BASELINE_RNG)};
answer = inputdlg(prompt, dlg_title, num_lines, defaultans);

if isempty(answer) %Cancel Button
    disp('No changes made')
else %OK button
    choice = questdlg('Changing these settings will reset workflow to step 1, continue?');

    switch choice %Change Settings
        case 'Yes'
            VARS.RESAMPLE_FREQ = str2double(answer{1});
            VARS.BASELINE_RNG  = str2double(answer{2});
            tmseeg_reset_workflow(S, 1, S.num_steps)
    end

end
    
end


function step2_callback(varargin)
% Settings call for step 2: TMS Artifact removal
global VARS 
S = varargin{3};

%Pop-up Display settings
prompt = {'Enter ISI time interval (ms)',...
            'TMS Pulse Duration (ms)'};
dlg_title = 'Step2 Settings';
num_lines = 1;
defaultans = {num2str(VARS.ISI),...
              num2str(VARS.PULSE_DURATION)};
answer = inputdlg(prompt, dlg_title, num_lines, defaultans);

if isempty(answer) %Cancel Button
    disp('No changes made')
else %OK button
    choice = questdlg('Changing these settings will reset workflow to step 2, continue?');

    switch choice
        case 'Yes' %Change settings
            VARS.ISI            =  str2double(answer{1});
            VARS.PULSE_DURATION =  str2double(answer{2});
            tmseeg_reset_workflow(S, 2, S.num_steps)
    end

end
    
end

function step3_callback(varargin)
% Settings call for step 3: Remove bad trials and channels
global VARS
S = varargin{3};

%Pop-up Display
prompt = {'% bad channels allowed in trial','% bad trials allowed in channel',...
            'Start time for ATTRIBUTE extraction','End time for ATTRIBUTE extraction',...
            'Pulse gap start time (ms)','Pulse gap end time (ms)',...
            'Frequency band min (Hz)','Frequency band max (Hz)',...
            'Channel plot ymin','Channel plot ymax'};
dlg_title = 'Step3 Settings';
num_lines = 1;
defaultans = {num2str(VARS.PCT_BAD_CHANS),...
              num2str(VARS.PCT_BAD_TRIALS),...
              num2str(VARS.TIME_ST),...
              num2str(VARS.TIME_END),...
              num2str(VARS.PULSE_ST),...
              num2str(VARS.PULSE_END),...
              num2str(VARS.FREQ_MIN),...
              num2str(VARS.FREQ_MAX),...
              num2str(VARS.PLT_CHN_YMIN),...
              num2str(VARS.PLT_CHN_YMAX)};
answer = inputdlg(prompt, dlg_title, num_lines, defaultans);

if isempty(answer) %Cancel Button
    disp('No changes made')
else %OK button
    choice = questdlg('Changing these settings will reset workflow to step 3, continue?');

    switch choice
        case 'Yes' %Change settings
            VARS.PCT_BAD_CHANS  = str2double(answer{1});
            VARS.PCT_BAD_TRIALS = str2double(answer{2});
            VARS.TIME_ST        = str2double(answer{3});
            VARS.TIME_END       = str2double(answer{4});
            VARS.PULSE_ST       = str2double(answer{5});
            VARS.PULSE_END      = str2double(answer{6});
            VARS.FREQ_MIN       = str2double(answer{7});
            VARS.FREQ_MAX       = str2double(answer{8});
            VARS.PLT_CHN_YMIN   = str2double(answer{9});
            VARS.PLT_CHN_YMAX   = str2double(answer{10});
            tmseeg_reset_workflow(S, 3, S.num_steps)
    end

end
    
end

function step7_callback(varargin)
% Settings call for ICA 2 steps 7/8
global VARS
S = varargin{3};

% Pop-up display settings
prompt = {'Percent of maximum ICA Components'};
dlg_title = 'Step7 Settings';
num_lines = 1;
defaultans = {num2str(VARS.ICA_COMP_PCT)};
answer = inputdlg(prompt, dlg_title, num_lines, defaultans);

if isempty(answer) %Cancel Button
    disp('No changes made')
else %OK button
    choice = questdlg('Changing these settings will reset workflow to step 7, continue?');

    switch choice
        case 'Yes' %Update Settings
            VARS.ICA_COMP_PCT = str2double(answer{1});
            tmseeg_reset_workflow(S,7, S.num_steps)
    end

end

end

function step8_callback(varargin)
% Settings call for ICA 2 steps 7/8
global VARS
S = varargin{3};

% Pop-up display settings
prompt = {'Update window start time (ms)',...
          'Update window end time (ms)',...
          'Update window ymin',...
          'Update window ymax',...
          '(Advanced) Kurtosis Threshold for electrode tagging'};
dlg_title = 'Step8 Settings';
num_lines = 1;
defaultans = {num2str(VARS.UPD_WDW_STRT),...
              num2str(VARS.UPD_WDW_END),...
              num2str(VARS.UPD_WDW_YMIN),...
              num2str(VARS.UPD_WDW_YMAX),...
              num2str(VARS.KURTOSIS_THRESH)};
answer = inputdlg(prompt, dlg_title, num_lines, defaultans);

if isempty(answer) %Cancel Button
    disp('No changes made')
else %OK button
    choice = questdlg('Changing these settings will reset workflow to step 8, continue?');

    switch choice
        case 'Yes' %Update Settings
            VARS.UPD_WDW_STRT    = str2double(answer{1});
            VARS.UPD_WDW_END     = str2double(answer{2});
            VARS.UPD_WDW_YMIN    = str2double(answer{3});
            VARS.UPD_WDW_YMAX    = str2double(answer{4});
            VARS.KURTOSIS_THRESH = str2double(answer{5});
            tmseeg_reset_workflow(S, 8, S.num_steps)
    end

end

end

function step9_callback(varargin)
% Settings call for step 9: Remove bad channels and trials 2
global VARS
S = varargin{3};

% Set up pop-up display
prompt = {'% bad channels allowed','% bad trials allowed',...
            'Channel plot ymin','Channel plot ymax'};
dlg_title = 'Step9 Settings';
num_lines = 1;
defaultans = {num2str(VARS.PCT_BAD_CHANS_2),...
              num2str(VARS.PCT_BAD_TRIALS_2),...
              num2str(VARS.PLT_CHN_YMIN_2),...
              num2str(VARS.PLT_CHN_YMAX_2)};
answer = inputdlg(prompt, dlg_title, num_lines, defaultans);

if isempty(answer) %Cancel Button
    disp('No changes made')
else %OK button
    choice = questdlg('Changing these settings will reset workflow to step 9, continue?');

    switch choice
        case 'Yes' %Change Settings
            VARS.PCT_BAD_CHANS_2  = str2double(answer{1});
            VARS.PCT_BAD_TRIALS_2 = str2double(answer{2});
            VARS.PLT_CHN_YMIN_2   = str2double(answer{3});
            VARS.PLT_CHN_YMAX_2   = str2double(answer{4});
            tmseeg_reset_workflow(S, 9, S.num_steps)
    end

end

end

function show_callback(varargin)
% Settings call for View Data button
global VARS

% Set up pop-up display
prompt = {'View Data y limit'};
dlg_title = 'View Data Settings';
num_lines = 1;
defaultans = {num2str(VARS.YSHOWLIMIT)};
answer = inputdlg(prompt, dlg_title, num_lines, defaultans);

if isempty(answer) %Cancel Button
    disp('No changes made')
else %OK button
    VARS.YSHOWLIMIT = str2double(answer{1});
end
    
end