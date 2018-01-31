% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez, Faranak Farzan
%         2016
%         Ben Schwartzmann 
%         2017

% tmseeg_plot_Trial() - displays all channels for selected data

% Display window interface:
%       "Activity Plot" - [main window] displays the channels for each
%       trial
%       "Delete/UnDelete" - [Button] if channels are selected, marks
%       selected channels for deletion.  If no channels are selected,
%       marks the channels for deletion.  If channel has been marked for
%       deletion (tagged as "undelete"), restores channel.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.


function tmseeg_plot_trial(S)
% plotTrialnew() - creates UI, formats data, plots trials. Display is
% adjusted based on the deletion status of specific channels/entire trial.

global backcolor 

%Create Figure, Plot
figure('Position',[340   00   750   600],'Toolbar','figure',...
                'DockControls','off','MenuBar','none',...
                'color',backcolor,'CloseRequestFcn',@my_closefcn)
uicontrol('Style','push',...
                'Units','normalized',...
                'Position',[0.6 0.94 0.15 0.05],...
                'Fontsize',11,...
                'String','Delete',...
                'Tag','dt',...
                'Callback',{@deleteTrial,S});
            
%Data Load and formatting
data = S.EEG.data(:,:,S.trial);
data = data-repmat(mean(data(:,1:floor(S.EEG.pnts)),2),1, size(data,2));
sep = 50; % distance between series 
add = sep*cumsum(ones(size(data)));
ndata = (add + data)';

%Plot Trials
plot(S.EEG.times,ndata)
ylim([sep-sep sep*size(data,1)+sep])
xlim([floor(min(S.EEG.times)) ceil(max(S.EEG.times))])
lines = flipud(findobj(gca,'type','line'));
ylabel('Channels')
xlabel('Time(ms)')
listca = {S.EEG.chanlocs.labels};
set(lines,'ButtonDownFcn',{@select_line,size(data,2),listca})

%Changing Display if Trials are deleted
if ~isempty(S.toDelete)  
    
    if any(ismember(S.toDelete,[S.trial 0],'rows')) %Trial has been deleted
        set(gca,'Color',[0.5 0.5 0.5])
        set(lines,'hittest','off');
        set(findobj('tag','dt'),'string','UnDelete')      
    else %Bad channels in Trial, bc = bad channel
        bc = S.toDelete((S.toDelete(:,1)==0 | S.toDelete(:,1)==S.trial),2);
        
        if get(findobj('tag','visible'),'value')
            set(lines(bc),'hittest','off','linewidth',3);
        else
            set(lines(bc),'hittest','off','visible','off');
        end
        
    end
    
end

%Setting Y Axis labelling
set(gca,'YTick',sep*(1:5:size(data,1)),'YTickLabel',{listca{1:5:end}})
axis ij
ylabv = get(gca,'Ylabel');
set(ylabv,'Position',get(ylabv,'Position')- [0.2 0 0])
title(['Trial ' num2str(S.trial)])

end


%Delete Function
function deleteTrial(varargin)
% Deletes lines if lines are selected, otherwise marks trial for deletion.
% If trial is marked for deletion, unmarks the trial and restored display.

global dotcolor basepath colorsDot

%Data load
S = varargin{3};
S = guidata(S.fh);
tline = findobj(gca,'type','line');
BC = flipud(cell2mat(get(tline,'linewidth'))==3 & ismember(get(tline,'hittest'),'on'));
points = flipud(findobj(get(S.ft,'Children'),'type','scatter'));

if any(BC) %If lines selected, delete those lines
    choice = questdlg('Delete Selected Channels in Trial?');
    
    switch choice 
        case 'Yes'
            toadd = [repmat([S.trial],sum(BC),1) find(BC)];
            S.toDelete = cat(1,S.toDelete, toadd);
            guidata(S.fh,S);
            toDelete = S.toDelete; %#ok
            
            if isfield(S,'sp') && ishandle(S.sp(1))
                updating(S,toadd);
            end
            
            save(fullfile(basepath,[S.name '_' num2str(S.step_num) '_toDelete.mat']), 'toDelete');
            close(get(varargin{1},'parent'));
    end
    
else % If no lines selected, check Trial Deletion Status
    del_pair = [S.trial 0];
   
    if ~isempty(S.toDelete) && ...  %Undelete Trial
            (any(ismember(S.toDelete,del_pair,'rows')) && ... 
            strcmp(get(findobj('tag','dt'),'string'),'UnDelete'))
        choice = questdlg('Undelete Full Trial?');
        
        switch choice
            case 'Yes'
                %Remove del_pair from toDelete Matrix, reset appearance of plot
                
                if isfield(S, 'sp') && all(ishandle(S.sp))
                    updating2(S,del_pair);
                else
                    colorsDot(S.trial,:)=[0 0 0];
                    set(points,'CData',colorsDot);
                end
                
                S.toDelete = S.toDelete(S.toDelete(:,1)~=del_pair(1,1),:);
                guidata(S.fh,S);
                toDelete = S.toDelete; %#ok
                set(gca,'Color','default')
                set(tline,'hittest','on');
                set(findobj('tag','dt'),'string','Delete')
                save(fullfile(basepath,[S.name '_' num2str(S.step_num) '_toDelete.mat']), 'toDelete');
                close(get(varargin{1},'parent'));
        end
        
    else % Delete Trial
        choice = questdlg('Delete full Trial?');
        
        switch choice
            case 'Yes'
                %Add del_pair to toDelete Matrix, reset appearance of plot
                S.toDelete = cat(1,S.toDelete,del_pair);
                
                if isfield(S, 'sp') && all(ishandle(S.sp))
                    updating(S,S.toDelete);
                else
                    colorsDot(S.trial,:)=dotcolor;
                    set(points,'CData',colorsDot);
                end
                
                guidata(S.fh,S);
                toDelete = S.toDelete;
                disp(toDelete(end,:))
                save(fullfile(basepath,[S.name '_' num2str(S.step_num) '_toDelete.mat']), 'toDelete');
                close(get(varargin{1},'parent'));
        end
        
    end
    
end

if ~isempty(findobj('tag','pop'))
    uicontrol(findobj('tag','pop'));
end

end

% Line Selection callback
function select_line(varargin)
%Changes display of line when line is selected by user

listca = varargin(4);
sep = 50;
tline = flipud(findobj(gca,'type','line'));
ind = find(ismember(tline,gco));

set(gca,'YTick',ind*sep,'YTickLabel',listca{1}{ind})

if get(gco,'linewidth')==3
    set(gco,'linewidth',0.5);
else
    set(gco,'linewidth',3);
end

end

function updating(S, D)
%If plotTrialnew is called from the Plot Channels function, this will
%update the colors of all the subplot dots
global colorsDot dotcolor 

if ~isempty(D(D(:,2)==0,1))
    bt4ch=D(D(:,2)==0);
    for k = 1:S.EEG.nbchan
        p = flipud(findobj(get(S.sp(k),'Children'),'type','scatter'));
        colorsDot(bt4ch,:,k)=repmat(dotcolor,size(bt4ch,1),1);
        set(p,'CData',colorsDot(:,:,k));
    end
end

for k = setdiff(1:S.EEG.nbchan,find(ismember(cell2mat(get(S.sp,'Color')),[.5 .5 .5],'rows')))
    bt4ch = D(D(:,2)==k,1);
    p = flipud(findobj(get(S.sp(k),'Children'),'type','scatter'));
    colorsDot(bt4ch,:,k)=repmat(dotcolor,size(bt4ch,1),1);
    set(p,'CData',colorsDot(:,:,k));
end

points=flipud(findobj(get(S.ft,'Children'),'type','scatter'));
set(points,'CData',colorsDot(:,:,S.ch));

end

function updating2(S, D)
%If plotTrialnew is called from the Plot Channels function, this will
%update the colors of all the subplot dots

global colorsDot
if ~isempty(D(D(:,2)==0,1))
    bt4ch=D(D(:,2)==0);
    for k = 1:S.EEG.nbchan
        p = flipud(findobj(get(S.sp(k),'Children'),'type','scatter'));
        colorsDot(bt4ch,:,k)=repmat([0 0 0],size(bt4ch(:,1),1),1);
        set(p,'CData',colorsDot(:,:,k));
    end
end

points=flipud(findobj(get(S.ft,'Children'),'type','scatter'));
set(points,'CData',colorsDot(:,:,S.ch));

end

function my_closefcn(varargin)

if ~isempty(findobj('tag','pop'))
    uicontrol(findobj('tag','pop'));
end

delete(varargin{1});

end
