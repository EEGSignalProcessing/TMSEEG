% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez,Faranak Farzan
% 2016

% tmseeg_rm_ch_tr_2: Creates child GUI for analysis and removal
% of noisy channels/trials in the EEG data.

% Inputs: 
%     A             - parent GUI information (structure)
%     step_num      - Step number for current cleaning step in workflow


% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

function [] = tmseeg_rm_ch_tr_2(A,step_num)
clc
global basepath dotcolor linecolor backcolor VARS
linecolor = [1 0 0];
dotcolor  = linecolor;
S.step_num = step_num;

%Main Figure
S.fh = figure('menubar','none',...
              'Toolbar','none',...
              'Units','normalized',...
              'name','tmseeg_remove_channel_trials',...
              'numbertitle','off',...
              'resize','off',...
              'color',backcolor,...
              'Position',[0.1 0.1 0.4 0.8],...
              'DockControls','off');


% -------------------------Pop-up Menu --------------------------------
S.ls_var =  uicontrol('style','popupmenu',...
    'units','normalized',...
    'position',[.5 0.9 0.4 0.05],...
    'fontsize',12,...
    'value', 3,...
    'tag','vv',...
    'string',{'minmax w/ TMS residual','minmax wo/ TMS residual','High Freq'});

S.ls_notation = uicontrol('style','text',...
    'units','normalized',...
    'String','Select attribute for display:',...
    'position',[0.01 0.91 .44 0.04],...
    'fontsize',14,...
    'tag','vv_txt');

S.pb_tr = uicontrol('style','push',...
    'units','normalized',...
    'position',[0 0.7 1 0.1],...
    'fontsize',12,...
    'string','Plot Trials',...
    'callback',{@pb_tr_call,S});

S.pb_ch = uicontrol('style','push',...
    'units','normalized',...
    'position',[0 0.6 1 0.1],...
    'fontsize',12,...
    'string','Plot Channels',...
    'callback',{@pb_ch_call,S});

S.pb_eeg = uicontrol('style','push',...
    'units','normalized',...
    'position',[0 0.5 1 0.1],...
    'fontsize',12,...
    'string','EEGplot',...
    'callback',{@pb_eeg_call,S});

S.pb_clear = uicontrol('style','push',...
    'units','normalized',...
    'position',[0 0.4 1 0.1],...
    'fontsize',12,...
    'string','Clear Subject',...
    'callback',{@pb_clear_call,S});

S.pb_del_matrix = uicontrol('style','push',...
    'units','normalized',...
    'position',[0 0.3 1 0.1],...
    'fontsize',12,...
    'string','The Deleting Matrix',...
    'callback',{@pb_del_matrix_call,S});

S.pb_del = uicontrol('style','push',...
    'units','normalized',...
    'position',[0 0.2 1 0.1],...
    'fontsize',12,...
    'string','Remove Bad Trials and Channels',...
    'callback',{@pb_del_tr_ch_call,S,A});


%------------------------Load Channel and EEG Data-------------------------

[file, EEG]   = tmseeg_load_step(S.step_num);
[~,name,~]  = fileparts(file.name); 
S.name      = name;
if ~exist(fullfile(basepath,[name '_' num2str(S.step_num) '_toDelete.mat']))
    S.toDelete=[];
else
    load(fullfile(basepath,[name '_' num2str(S.step_num) '_toDelete.mat']));
    S.toDelete = toDelete;
end

%Set bad channel/trial num based of pct and loaded data
VARS.NUM_BAD_CHANS_2  = ceil(EEG.nbchan*VARS.PCT_BAD_CHANS_2/100);
VARS.NUM_BAD_TRIALS_2 = ceil(EEG.trials*VARS.PCT_BAD_TRIALS_2/100);


% Update GUI
guidata(S.fh,S);


end

%% Callback Functions

% Plot Trial Call
function [] = pb_tr_call(varargin)
%Load the EEG data from previous step, extract selected ATTRIBUTE using the
%Get_SM() function.  Displays Trials based on their ATTRIBUTE value.

global points dotcolor basepath prevdot backcolor

%Data Load
S       = varargin{3};
S       = guidata(S.fh);
S.EEG   = pop_loadset('filename',fullfile(basepath,[S.name '.set']));
% S.chan  = ismember({S.chanloc.labels},{S.EEG.chanlocs.labels});
S.M     = Get_SM2(S.EEG);
S.ch    = [];
S.trial = [];
guidata(S.fh,S);

%Figure Setup
S.ft = figure('position',[40 80 800 500],'color',backcolor);
N = size(S.M,2);

%Scatter Plot
if N>100
    warning('off','MATLAB:usev6plotapi:DeprecatedV6ArgumentForFilename')
    scatter('v6',1:N,mean(S.M),'ko','filled');
else
    scatter(1:N,mean(S.M),'ko','filled');
end
points   = flipud(findobj(get(gca,'Children'),'type','patch'));
set(gca,'NextPlot','add');
if ~isempty(S.toDelete)
    Del   = S.toDelete;
    Del   = Del(ismember(Del(:,2),0),:);
    set(points(Del(:,1)),'MarkerFaceColor',dotcolor)   
end

guidata(S.fh,S);
set(points, 'HitTest','on','ButtonDownFcn', {@button_down_points,S})
title('Trials represented by selected attribute')
xlabel('Trial Number')
attr = get(findobj('tag','vv'),'value');
lst =get(findobj('tag','vv'),'string');
ylabel(lst(attr))

end

%Plot Channels Call
function [] = pb_ch_call(varargin)
%Load the EEG data from previous step, extract selected ATTRIBUTE using the
%Get_SM() function.  Creates a scatter plot for each channel and plot the
%Trials within that channel based on their ATTRIBUTE value.

global dotcolor basepath backcolor VARS %prevdot prevback

%Data Load and initialization
S       = varargin{3};
S       = guidata(S.fh);
S.EEG   = pop_loadset('filename',fullfile(basepath,[S.name '.set']));
% S.chan  = ismember({S.chanloc.labels},{S.EEG.chanlocs.labels});
S.M     = Get_SM2(S.EEG);
S.ch    = [];
S.trial = [];
guidata(S.fh,S);

%Set Child Figure
S.fsp       = figure('units','normalized',...
    'position',[0.025 0 .95 .95],...
    'menubar','none',...
    'toolbar','none',...
    'numbertitle','off',...
    'visible','off',...
    'color',backcolor,...
    'Name','Select channel with mouse button',...
    'resize','off','WindowButtonDownFcn',{@ClickOnWindow,S});

label_list = {S.EEG.chanlocs.labels};
if VARS.HEAD_PLOT
    S.sp          = tmseeg_plottopo (S.EEG.data,S.EEG.chanlocs)';
else
    S.sp          = tmseeg_plottopo (S.EEG.data)';
end

guidata(S.fh,S);
% set(S.fsp,'visible','on')
% set(S.sp,'XLimMode','manual','YLimMode','manual');
N = size(S.M,2);

%Scatter plots
for k = 1:S.EEG.nbchan
    if N>100
        warning('off','MATLAB:usev6plotapi:DeprecatedV6ArgumentForFilename')
        scatter('v6',S.sp(k),1:N,S.M(k,:),'k.');
    else
        scatter(S.sp(k),1:N,S.M(k,:),'k.');
        title(S.sp(k),label_list{k})
    end
    set(S.sp(k),'XLim',[-0.1*N N+N*0.1;],'NextPlot','add');
end
set(findobj('type','patch'),'Hittest','on')
set(S.sp,'XTickLabel',{' '},'YTickLabel',{' '})

% Setting Deleted elements to red dots
if ~isempty(S.toDelete)
    Del    =  S.toDelete;
    badch  = ismember(Del(:,1),0);
    set(S.sp(Del(badch,2)),'Color',[0.5 0.5 0.5]);
    badtr  = ismember(Del(:,2),0);
    for k  = setdiff(1:S.EEG.nbchan,Del(badch,2))
        bt4ch = [Del(ismember(Del(:,2),k),1); Del(badtr,1)]; 
        p     = flipud(findobj(get(S.sp(k),'Children'),'type','patch'));
        set(p(bt4ch),'MarkerEdgeColor',dotcolor)
    end
end

end


%Call EEGLAB function to view data by trial
function [] = pb_eeg_call(varargin)
global TMPREJ basepath

%Data load and Variables
S       = varargin{3};
S       = guidata(S.fh);
S.EEG   = pop_loadset('filename',fullfile(basepath,[S.name '.set']));
S.M     = Get_SM2(S.EEG);
S.ch    = [];
S.trial = [];
guidata(S.fh,S);


evalin('base', 'global TMPREJ');
[~,IX] = sort(mean(S.M),'descend'); %Sort by attribute!!!!!
%data = S.EEG.data(:,:,IX); 
data = S.EEG.data;
eegplot(data,'spacing',100,'srate',S.EEG.srate,'limits',S.EEG.times([1 end]),...
    'winlength',5,'command','eegplot2trial');
waitfor(gcf)

%If Trials were set for deletion, execute
if ~isempty(TMPREJ)
    [trialrej ~] = eegplot2trial( TMPREJ, size(S.EEG.data,2), size(S.EEG.data,3));%  %#ok<NASGU>
    caca         = find(trialrej);
    disp(caca)
    N            = numel(caca);
    S.toDelete   = uint16(cat(1,S.toDelete, [caca(:) zeros(N,1)]));
    toDelete     = S.toDelete;
    save(fullfile(basepath,[S.name '_' num2str(S.step_num) '_toDelete.mat']), 'toDelete');
    guidata(S.fh,S);
end

end

%Call Deletion Matrix
function [] = pb_del_matrix_call(varargin)
global basepath backcolor

S = varargin{3}
% Load EEG, Deletion matrix
[ files, EEG ] = tmseeg_load_step(S.step_num);
[~,name,~] = fileparts(files.name); 

toDelete=[];
if exist(fullfile(basepath,[name '_' num2str(S.step_num) '_toDelete.mat']))
        load(fullfile(basepath,[name '_' num2str(S.step_num) '_toDelete.mat']));
end

% Create Image of Deletion Matrix
image=zeros(EEG.nbchan,EEG.trials);
if ~isempty(toDelete)
    for k=1:size(toDelete,1)
        ch = toDelete(k,2);
        tr = toDelete(k,1);%% column2 channel column1 trial
        if (ch*tr)==0
            if ch==0
                image(:,tr)=1;
            end
            if tr==0
                image(ch,:)=1;
            end
        else
            image(ch,tr) = 1; 
        end
    end
end

figure('menubar','none','Toolbar','none','Color',backcolor);
imagesc(image);
xlabel('Trial')
ylabel('Channel')
title('Deletion Matrix (Red = marked for deletion)')
end

%Clear Deletion Matrix
function [] = pb_clear_call(varargin)
global basepath
S     = varargin{3};
S     = guidata(S.fh);
    if ~isempty(S.name)
    button = questdlg('Clear Current Subject?','Clear Subject');
        if isequal(button,'Yes')
           S.toDelete = [];
           guidata(S.fh,S);
           toDelete        = S.toDelete;
           save(fullfile(basepath,[S.name '_' num2str(S.step_num) '_toDelete.mat']), 'toDelete');
        end
    end
end

%Delete Selected Trials
function [] = pb_del_tr_ch_call(varargin)
global basepath basefile
S       = varargin{3};
S       = guidata(S.fh);
A        = varargin{4};
[files, EEG] = tmseeg_load_step(S.step_num);
try
    disp(exist([basepath '\' S.name '_' num2str(S.step_num) '_toDelete.mat']))
    if exist([basepath '\' S.name '_' num2str(S.step_num) '_toDelete.mat'])
        load(fullfile(basepath,[S.name '_' num2str(S.step_num) '_toDelete.mat']));
    else
        toDelete = [];
    end
[EEG, GC, GT] = tmseeg_rm_tagged_elements2(EEG,toDelete);
EEG                = eeg_checkset( EEG );
tmseeg_step_check(files, EEG, A, S.step_num)
save(fullfile(basepath,[S.name '_' num2str(S.step_num) '_toDelete.mat']), 'toDelete');

close
tmseeg_clear_figs()
catch
    error('Could not delete selected data')
end

end

%------------------------------Helper Functions----------------------------

%Select Window Callback
function ClickOnWindow(varargin)
global points trial
S       = varargin{3};
S       = guidata(S.fh);
if isequal(get(gco,'type'),'patch')
    points   = flipud(findobj(get(gca,'Children'),'type','patch'));
    trial    = find(ismember(points,gco));
    S.trial  = trial;
    guidata(S.fh,S);
    tmseeg_plot_Trial(S);
elseif isequal(get(gco,'type'),'axes')
    points   = flipud(findobj(get(gca,'Children'),'type','patch'));
    S.ch = find(ismember(S.sp,gco));
    guidata(S.fh,S);
    tmseeg_plot_channel2(S);
end
end

%Select Point callback
function button_down_points(varargin)
global points trial
S         = varargin{3};
S         = guidata(S.fh);
trial   = find(ismember(points,gco));
S.trial = trial;

guidata(S.fh,S);

tmseeg_plot_Trial(S)

end

% Select Display Attribute Calculation
function SM2 = Get_SM2(EEG)
global VARS
N     = EEG.trials;
ch = 1:EEG.nbchan;
SM2    = zeros(EEG.nbchan,N);
findobj('tag','var')
get(findobj('tag','var'),'value')

%Attribute Extraction window, Pulse window
t_st  = find(EEG.times>VARS.TIME_ST,1,'first');
t_end = find(EEG.times<VARS.TIME_END,1,'last');
p_st  = find(EEG.times<VARS.PULSE_ST,1,'last');
p_end = find(EEG.times<VARS.PULSE_END,1,'last');

%Filter Design
Fs=EEG.srate;
ord = 2;
[z1 p1 k1]      = butter(ord,[VARS.FREQ_MIN VARS.FREQ_MAX]/(Fs/2),'bandpass');
[xall1,yall2]   = zp2sos(z1,p1,k1);

switch get(findobj('tag','vv'),'value')
    case 1
        time = [t_st:t_end];
        for trl = 1:N
            EEG_filt = filtfilt(xall1,yall2,double(EEG.data(:,time,trl)));
            SM2(ch,trl) = log(max(EEG_filt,[],2)-min(EEG_filt,[],2));
        end
    case 2
        time = [t_st:p_st p_end:t_end];
        for trl = 1:N
            EEG_filt = filtfilt(xall1,yall2,double(EEG.data(:,time,trl)));
            SM2(ch,trl) = log(max(EEG_filt,[],2)-min(EEG_filt,[],2));
        end
    case 3
        time = [t_st:p_st p_end:t_end];
        for trl = 1:N
            EEG_filt = filtfilt(xall1,yall2,double(EEG.data(:,time,trl)));
            SM2(ch,trl) = log(sum(abs(diff(EEG_filt,1,2)),2));
        end
end
SM2 = SM2*(N/(max(SM2(:))-min(SM2(:)))) - min(SM2(:));
end
