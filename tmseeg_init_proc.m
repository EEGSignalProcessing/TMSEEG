% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez,Faranak Farzan
% 2016

% tmseeg_init_proc() - Initial Data processing (epoching, baseline,
% resampling, selecting channels for removal.
% inputs:   S        - GUI parent structure
%           step_num - step number in workflow (for modularity)

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.


function [] = tmseeg_init_proc(S,step_num)
global basepath basefile VARS
%     Takes the parent structure S as an input, loads and preprocesses data
%     using the EEGLAB specific functions...
VARS = tmseeg_init();
S.step_num = step_num;

files   = dir(fullfile(basepath,[basefile '.set']));
EEG     = pop_loadset('filename',[basefile '.set'],'filepath',basepath);
h           = msgbox('Initial Data Processing...','Importing Dataset','help');
child       = get(h,'Children');
delete(child(3))

EEG     = epoch_prompt(EEG);
EEG     = baseline_prompt(EEG);

%Check for data sampling rate, ask for resampling
EEG         = resample_prompt(EEG);

%Custom chanlocs file
select_chanlocs = questdlg('Channel locations are set to standard 385-electrode format.  Select a custom channel location file?');
if strcmp(select_chanlocs,'Yes')
    EEG = pop_chanedit(EEG);
else
    EEG         = pop_chanedit(EEG, 'lookup',VARS.CHANLOC_FILE);
end
EEG         = eeg_checkset( EEG );

del_chans = questdlg('Select and delete channels?');
if strcmp(del_chans,'Yes')
    EEG     = channels_del(EEG);   
    EEG     = eeg_checkset( EEG );
end


%Saving original channels and epoch length before modifications
EEG.chanloc_orig = EEG.chanlocs; 
EEG.epoch_length = length(EEG.times)/EEG.srate;


tmseeg_step_check(files, EEG, S, S.step_num)
close(h)
tmseeg_upd_stp_disp(S, '.set', S.step_num)

end

function [EEG] = channels_del(EEG)
% Calls channel plot through EEGLAB topoplot() function, allows selection
% of channels for deletion with list
global chans_rm
chans_rm = [];

%Channels display
t = figure;
topoplot([],EEG.chanlocs,'style','blank','electrodes','labelpoint')
channel_list = uicontrol('style','list','max',10,...
     'Units','normalized',...
     'min',1,'Position',[0.85 0.1 0.1 0.8],...
     'Parent',t,...
     'string',{EEG.chanlocs.labels});
done_button = uicontrol('style','pushbutton',...
     'Units','normalized',...
     'string','Done',...
     'Position',[0.75 0.1 0.1 0.05],...
     'Parent',t,...
     'Callback',{@retrieve_value,channel_list,t, {EEG.chanlocs.labels}});
cancel_button = uicontrol('style','pushbutton',...
     'Units','normalized',...
     'string','Cancel',...
     'Position',[0.75 0.05 0.1 0.05],...
     'Parent',t,...
     'Callback',{@cancel_call,t});
waitfor(t)

EEG = pop_select(EEG, 'nochannel', chans_rm);
check_missing_coords(EEG)
end

function check_missing_coords(EEG)
% Alerts User to channels in the dataset that do not have coordinate
% information
missing_coords = '';
label_list = {EEG.chanlocs.labels};
for k = 1:length(label_list)
    if isempty(EEG.chanlocs(k).theta) && ...
            isempty(EEG.chanlocs(k).X) && ...
            isempty(EEG.chanlocs(k).sph_theta)
        missing_coords = [missing_coords, char(label_list(k)), ' '];
    end
end
if ~strcmp('',missing_coords)
    uiwait(warndlg(['The following channels do not have coordinates: ' missing_coords]))
end
end

function retrieve_value(varargin)
%Retrieve user-selected channels from list for deletion
global chans_rm
h_list = varargin{3};
labels = varargin{5};
chans_sel = get(h_list,'value');
del_txt = ['Delete channels ?' labels(chans_sel) ];
choice = questdlg(del_txt);
if strcmp(choice,'Yes')
    chans_rm = chans_sel;
    close(varargin{4})
end
end

function cancel_call(varargin)
%Cancel selection of channels for removal
close(varargin{3});
end

function [EEG_resamp] = resample_prompt(EEG)
% Pop-up guided selection of resampling process
global VARS

    sample_str = ['Sampling rate of data is ', num2str(EEG.srate),...
        'Hz.  Recommend resampling to 1000Hz, would you like to resample?'];
    resample_data = questdlg(sample_str);
    if strcmp(resample_data,'Yes')
        disp_str = ['Enter resampling rate for data (200 - ' num2str(EEG.srate) ' Hz)'];
        prompt = {disp_str};
        dlg_title = 'Input';
        num_lines = 1;
        defaultans = {num2str(VARS.RESAMPLE_FREQ)};
        user_freq = inputdlg(prompt,dlg_title,num_lines,defaultans);
        resamp_select = str2num(user_freq{1});
        if resamp_select < 200 || resamp_select > EEG.srate
            warning('Invalid Resampling frequency, please select a frequency from the recommended range')
            EEG = resample_prompt(EEG);
        else
            VARS.RESAMPLE_FREQ = resamp_select;
            EEG         = pop_resample( EEG, VARS.RESAMPLE_FREQ);   %resample to 1KHz
            EEG         = eeg_checkset( EEG );
        end
        EEG_resamp = EEG;

    else
        EEG_resamp = EEG;           
    end

end

function [EEG] = baseline_prompt(EEG)
%pop-up display guide for user baseline process
global VARS

%Automatic baseline adjustment for changing epoch
VARS.BASELINE_RNG = [0.8*VARS.EPCH_STRT (0 +0.2*VARS.EPCH_STRT) ];

baseline = questdlg('Remove Baseline?');
if strcmp(baseline,'Yes') %Choose to resample
    prompt = {'Baseline Calculation Range (ms)'};
    dlg_title = 'Baseline Settings';
    num_lines = 1;
    defaultans = {num2str(VARS.BASELINE_RNG)};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

if (length(answer) ~= 0) %User enters a resampling value
    try
        VARS.BASELINE_RNG = str2num(answer{1});
        EEG               = pop_rmbase(EEG,VARS.BASELINE_RNG); 
    catch
        error('Could not baseline data with given settings')
    end
end
end
end

function [EEG] = epoch_prompt(EEG)
% Pop-up guide format for user epoch input
global VARS
if isempty(EEG.epoch) %Epoch if data is not already epoched

    %User selection of event type (2 possible format types)
    try
        eventstr = unique({EEG.event.type});
    catch
        try
            eventstr = {EEG.event.type};
            eventstr = strsplit(num2str(unique(horzcat(eventstr{:}))),' ');
        catch
            error('Incompatible EEG event type format, please epoch using EEGLAB')
        end
    end

     %Epoch event selection
    [i,sel] = listdlg('PromptString','Select epoch event',...
                    'SelectionMode','single',...
                    'ListString',eventstr);
    if sel
        %User selection of epoch time
        prompt = {'Enter epoch start (ms)','Enter epoch end (ms)'};
        dlg_title = 'Input';
        num_lines = 1;
        defaultans = {num2str(VARS.EPCH_STRT),num2str(VARS.EPCH_END)};
        tf = inputdlg(prompt,dlg_title,num_lines,defaultans);
        usr_epch_st  = str2num(tf{1});
        usr_epch_end = str2num(tf{2});
        
        %Setting Epoch times
        VARS.EPCH_STRT = usr_epch_st;
        VARS.EPCH_END  = usr_epch_end;
        EEG = pop_epoch(EEG,eventstr(i),[VARS.EPCH_STRT/1000 VARS.EPCH_END/1000]);
        
        %Update necessary display settings
        VARS.TIME_ST   = usr_epch_st;
        VARS.TIME_END  = usr_epch_end;
        
        if VARS.EPCH_STRT > VARS.TMS_DSP_XMIN
            VARS.TMS_DSP_XMIN = VARS.EPCH_STRT;
        end
        if VARS.EPCH_STRT > (-VARS.ISI + VARS.SLIDER_MIN)
            VARS.ISI = -VARS.EPCH_STRT + VARS.SLIDER_MIN + 10;
        end
        
        if VARS.EPCH_STRT > VARS.UPD_WDW_STRT
            VARS.UPD_WDW_STRT = VARS.EPCH_STRT;
        end
        if VARS.EPCH_END < VARS.UPD_WDW_END
            VARS.UPD_WDW_END  = VARS.EPCH_END;
        end
            
    else
        warning('No epoch event selected, continuing without epoching')
    end
end
end

