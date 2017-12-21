% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez,Faranak Farzan
% 2016

% tmseeg_plot_channel() - Displays all trials within a selected channel for
% deletion of bad trials or deletion of the full trial.  Allows scrolling
% between channels, and offers visualization of channel data as a stacked
% or spread display.

% Display window interface:
%       "Activity Plot" [main window] - Displays channel data for each trial
%       in the datasets.  Individual trial/channel pairs can be marked for
%       deletion using the "R/ Trial in Chan" button or the right mouse
%       button.  Trials marked for deletion will appear in red
%       "Stack" [Button] - changes the "Activity Plot" display between spread
%       and stacked display style
%       "R/ Channel" [Button] - marks all trials in the channel for
%       deletion, changes the appearance of the channel GUI.
%       "R/ Trial in Chan" [Button] - markes a selected trial within the
%       channel for deletion, turning it red.  This functionality also
%       works by pressing the right mouse button.  Acivating this button
%       again will undelete the selected trial.
%       "pop" [popupmenu] - displays current electrode (channel), allows
%       for quick scrolling between electrode displays.
%       "Visible" [check] - switches visibility mode, which will toggle
%       trials marked for deletion as visible/invisible

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
%
% Updated on Dec 2017 by Ben Schwartzmann 
% Plot Channels is now faster 



function tmseeg_plot_channel(S)
%plot_channel_new - creates initial GUI and initializes labels based on
%status of input data.

global backcolor

S.tr = figure('units','normalized',...
              'position',[0 0 0.8 1],...
              'color',backcolor,...
              'toolbar','figure');

colororder = repmat(linspace(0.2,0.6,5)',1,3);
set(gcf,'DefaultAxesColorOrder',colororder)

%Setting buttons from previous defaults
if ~isempty(S.toDelete)
    if any(ismember(S.toDelete,[0 S.ch],'rows'))
        ch_txt = 'UnDel Ch';
    else
        ch_txt = 'R/ Channel';
    end
else
    ch_txt = 'R/ Channel';
end

%Read channel location data
lista = {S.EEG.chanlocs.labels}';


uicontrol('style','togglebutton',...
                'units','normalized',...
                'position',[.13 0.94 0.08 0.04],...
                'fontsize',11,...
                'value', S.ch,...
                'string','Stack',...
                'tag','tg',...
                'value',0,...
                'callback',{@change_channel,S});
uicontrol('style','push',...
                'units','normalized',...
                'position',[.24 0.94 0.11 0.04],... 
                'fontsize',11,...
                'tag','rm_ch',...
                'string',ch_txt,...
                'callback',{@deleteChannel,S});
uicontrol('style','push',...
                'units','normalized',...
                'position',[0.38 0.94 0.08 0.04],...
                'fontsize',11,...
                'string','Show Trial',...
                'visible','on',...
                'callback',{@see_trial,S});
uicontrol('style','push',...
                'units','normalized',...
                'position',[0.49 0.94 0.15 0.04],... 
                'fontsize',11,...
                'tag','rm_tr_ch',...
                'string','R/ Trial in Chan (Ctrl)',...
                'callback',{@deleteChannelInTrial,S});
uicontrol('style','popupmenu',...
                'units','normalized',...
                'position',[0.69 0.94 0.1 0.04],... 
                'fontsize',14,...
                'value', S.ch,...
                'tag','pop',...
                'string',lista,... 
                'callback',{@change_channel,S});
uicontrol('style','check',...
                'units','normalized',...
                'position',[0.82 0.94 0.1 0.04],... 
                'fontsize',11,...
                'string','Visible',...
                'tag','visible',...
                'value',1,...
                'callback',{@change_visibility,S});

S.traces = subplot(5,1,1:4);
S.Sp_ch_labels(S.ch).ch_txt = ch_txt;

guidata(S.fh,S);
plot_traces(S)
uicontrol(findobj('tag','pop'))
end


%------------------------------------------------------------------
function deleteChannel(varargin)
%Called by "R/Channel" button, marks/unmarks the trial deletion based on
%the current deletion status, updates the GUI display.

global lines linecolor basepath
S     = varargin{3};
S     = guidata(S.fh);


del_pair = [0 S.ch]; %Create pairing to check deletion matrix

if ~isempty(S.toDelete)
    if(any(ismember(S.toDelete,del_pair,'rows'))) %Check for deletion
    
        button = questdlg(['UnDelete channel ' S.EEG.chanlocs(S.ch).labels '?'],'UnDeleting Channel');
    
        if isequal(button,'Yes') %Undelete channel, reset all displays
            S.toDelete = S.toDelete(~ismember(S.toDelete,del_pair,'rows'),:);
            set(S.sp(S.ch),'Color','default'); 
            toDelete = S.toDelete;
            disp(toDelete(ismember(S.toDelete,del_pair,'rows'),:))
            save(fullfile(basepath,[S.name '_' num2str(S.step_num) '_toDelete.mat']), 'toDelete'); 
            guidata(S.fh,S);
            set(lines,'Color','default','LineWidth',1);
            but = findobj('tag','rm_ch');
            set(but,'string','R/ Channel');
            S.Sp_ch_labels(S.ch).ch_txt = 'R/ Channel';
        
            guidata(S.fh,S);
        end
    else
    
        button = questdlg(['Delete channel ' S.EEG.chanlocs(S.ch).labels '?'],'Deleting Channel');
    
        if isequal(button,'Yes') %Delete channel, change displays
            S.toDelete = cat(1,S.toDelete, [0 S.ch]);
            set(S.sp(S.ch),'Color',[0.5 0.5 0.5])
            toDelete = S.toDelete;
            disp(toDelete(end,:))
            save(fullfile(basepath,[S.name '_' num2str(S.step_num) '_toDelete.mat']), 'toDelete'); 
            guidata(S.fh,S);
            set(lines,'Color',linecolor,'LineWidth',1);
            but = findobj('tag','rm_ch');
            set(but,'string','Undel Ch');
            S.Sp_ch_labels(S.ch).ch_txt = 'Undel Ch';
            set(gca,'Color',[0.5 0.5 0.5])
            guidata(S.fh,S);
        end
    end
else
    
    button = questdlg(['Delete channel ' S.EEG.chanlocs(S.ch).labels '?'],'Deleting Channel');
    
    if isequal(button,'Yes') %Delete channel, change displays
        S.toDelete = cat(1,S.toDelete, [0 S.ch]);
        set(S.sp(S.ch),'Color',[0.5 0.5 0.5])
        toDelete = S.toDelete;
        disp(toDelete(end,:))
        save(fullfile(basepath,[S.name '_' num2str(S.step_num) '_toDelete.mat']), 'toDelete'); 
        guidata(S.fh,S);
        set(lines,'Color',linecolor,'LineWidth',1);
        but = findobj('tag','rm_ch');
        set(but,'string','Undel Ch');
        S.Sp_ch_labels(S.ch).ch_txt = 'Undel Ch';
        set(gca,'Color',[0.5 0.5 0.5])
        guidata(S.fh,S);
    end
end
plot_traces(S)
uicontrol(findobj('tag','pop'))
end

function deleteChannelInTrial(varargin)
%Called by "R/ Trial in Chan" button or right mouse button, marks/unmarks a
%selected trial for deletion and updates its appearance.

global trial lines linecolor dotcolor basepath colorsDot
S          = varargin{3};
S          = guidata(S.fh);
S.trial    = trial;

del_pair = [S.trial  S.ch];

if ~isempty(S.toDelete) && (any(ismember(S.toDelete,del_pair,'rows')))  %Undelete Trial
    S.toDelete = S.toDelete(~ismember(S.toDelete,del_pair,'rows'),:);
    p   = flipud(findobj(S.sp(S.ch),'type','scatter'));
    colorsDot(del_pair(:,1),:,S.ch)=repmat([0 0 0],size(del_pair,1),1);
    set(p,'CData',colorsDot(:,:,S.ch));
    if get(findobj('tag','visible'),'value')
        set(lines(trial),'Color','default','LineWidth',1);
    else
        set(lines(trial),'visible','on');
    end
else
    S.toDelete = cat(1,S.toDelete, del_pair);
    p   = flipud(findobj(S.sp(S.ch),'type','scatter'));
    
    colorsDot(del_pair(:,1),:,S.ch)=repmat(dotcolor,size(del_pair,1),1);
    set(p,'CData',colorsDot(:,:,S.ch));

    if get(findobj('tag','visible'),'value')
        set(lines(trial),'Color',linecolor,'LineWidth',1);
    else
        set(lines(trial),'visible','off');
    end
end

guidata(S.fh,S);
toDelete = S.toDelete; %#ok
save(fullfile(basepath,[S.name '_' num2str(S.step_num) '_toDelete.mat']), 'toDelete'); 
uicontrol(findobj('tag','pop'))
end

%------------------------------------------------------------------
function change_channel(varargin)
% Changes the current selected channel, loads the new data updating the
% "Activity plot" main window.
S     = varargin{3};
S     = guidata(S.fh);
if ismember(get(findobj('tag','pop'),'value'),1:S.EEG.nbchan)
    
    S.ch  = get(findobj('tag','pop'),'value');
    del_pair = [0  S.ch];
    if ~isempty(S.toDelete) && not(any(ismember(S.toDelete,del_pair,'rows')))
            but = findobj('tag','rm_ch');
            set(but,'string','R/ Channel');
    else
        but = findobj('tag','rm_ch');
        set(but,'string','UnDel Ch');
    end
else
    S.ch = [];
end
guidata(S.fh,S);
plot_traces(S)
uicontrol(findobj('tag','pop'))
end

%------------------------------------------------------------------
function see_trial(varargin)
%Calls Trial Deletion window with currently selected trial
global trial
S        = varargin{3};
S        = guidata(S.fh);
S.trial  = trial;
guidata(S.fh,S);
tmseeg_plot_Trial(S)
uiwait(gcf)
plot_traces(S)

uicontrol(findobj('tag','pop'))
end

%------------------------------------------------------------------
function plot_traces(S)
% Function called to plot Trial data for each channel and summmed Trial
% Display at bottom of figure

global data lines linecolor VARS
S      = guidata(S.fh);
obj    = findobj('tag','tg');
state  = get(obj,'value');
Ch     = 1:S.EEG.nbchan; 
if isempty(S.ch) || ~ismember(S.ch,Ch)  
    data = nan(size(S.EEG.data,2),size(S.EEG.data,3));
else
    data   = squeeze(S.EEG.data(Ch==S.ch,:,:));
    data   = data-repmat(mean(data(1:ceil(S.EEG.pnts),:)),size(data,1),1);
end
time   = S.EEG.times;
if ~isempty(S.toDelete) && ~isempty(S.ch)
    badtrial = ismember(S.toDelete(:,2),[S.ch  0]);
    badtrial = S.toDelete(badtrial,1);
else
    badtrial=[];
end
if any(badtrial==0)
    badtrial = 1:S.EEG.trials;
end
subplot(5,1,1:4);
if ~isempty(S.toDelete)
    if any(ismember(S.toDelete,[0 S.ch],'rows'))
        set(gca,'Color',[0.5 0.5 0.5])
    end
end
% 333
% state
% 444
if ~state
    set(obj,'String','Stack')
    sep    = 50;
    add    = sep*cumsum(ones(size(data)),2);
    ndata  = (add + data);
    plot(time,ndata)
    ylim([sep-sep sep*size(data,2)+sep])
    xlim([floor(min(S.EEG.times)) ceil(max(S.EEG.times))]);
    lines = flipud(findobj(gca,'Type','line'));
    
    if any(badtrial)
        if get(findobj('tag','visible'),'value')
            set(lines(badtrial),'Color',linecolor);
        else
            set(lines(badtrial),'visible','off');
        end
    end
    set(gca,'YTick',sep*(0:5:size(data,2)),'YTickLabel',(0:5:size(ndata,2)))
    ylabel('Trial Number')
    hold off
else
    set(obj,'String','Spread')
    axes(S.traces)
    plot(time,data);
    ylabel(['Amplitude (' char(0181) 'V)']);
    lines = flipud(findobj(gca,'Type','line'));
    if any(badtrial)
        if get(findobj('tag','visible'),'value')
            set(lines(badtrial),'Color',linecolor);
        else
            set(lines(badtrial),'visible','off');
        end
    end
    ylim([VARS.PLT_CHN_YMIN VARS.PLT_CHN_YMAX]);
    xlim([floor(min(S.EEG.times)) ceil(max(S.EEG.times))]);
    hold off
end

%Bottom mean trace plot
subplot(5,1,5)

if isfield (S.EEG,'epochinfo')
    e    = S.EEG.epochinfo;
    erp1 = mean(data(:,ismember(setdiff(1:S.EEG.trials,badtrial), find(e==1))),2);
    erp2 = mean(data(:,ismember(setdiff(1:S.EEG.trials,badtrial), find(e==2))),2);
    plot(time,erp2,'Color',[1 0 0.3],'LineWidth',2)
    hold on
    plot(time,erp1,'Color',[0 0 0],'LineWidth',2)
    ylim([-40 40])
    xlim([floor(min(S.EEG.times)) ceil(max(S.EEG.times))])
    hold off
else
    erp  = mean(data(:,setdiff(1:S.EEG.trials,badtrial)),2);
    plot(time,erp,'Color',[0 0 0],'LineWidth',2)
    xlim([floor(min(S.EEG.times)) ceil(max(S.EEG.times))])
%     ylim([VARS.PLT_CHN_YMIN VARS.PLT_CHN_YMAX]);
end
guidata(S.fh,S);
title(['Channel No. ' num2str(S.ch)])
set(lines,'ButtonDownFcn',{@button_down,S})
% waitforBP
uicontrol(findobj('tag','pop'))

end

%------------------------------------------------------------------
function button_down(varargin)
% Called during selection of trials in channel display
global lines trial
src = varargin{1};
set(lines,'LineWidth',1)
set(src,'LineWidth',3)
trial  = find(ismember(lines,gco));
if isequal(get(gcbf, 'SelectionType'),'alt') % Ctrl
    S      = varargin{3};
    S      = guidata(S.fh);
    deleteChannelInTrial([],[],S)
end

end

function change_visibility(varargin)
%Displays/hides traces selected for deletion.  Controlled by the "Visible"
%checkbox.

global linecolor lines
S     = varargin{3};
S     = guidata(S.fh);

if ~isempty(S.toDelete) && ~isempty(S.ch)  
    badtrial = ismember(S.toDelete(:,2),[S.ch  0]);
    badtrial = S.toDelete(badtrial,1);
else
    badtrial=[];
end
if any(badtrial==0)
    badtrial = 1:S.EEG.trials;
end
   if any(badtrial)
        if get(findobj('tag','visible'),'value')
            set(lines,'visible','on');
            set(lines(badtrial),'Color',linecolor);
        else
            set(lines(badtrial),'visible','off');
        end
    end
guidata(S.fh,S)
uicontrol(findobj('tag','pop'))
end
