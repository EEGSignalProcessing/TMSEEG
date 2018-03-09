% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez, Faranak Farzan
%         2016
%         Ben Schwartzmann 
%         2017

% eegdatapro_ica() - Runs Independent Component Analysis using the pop_runica
% EEGLAB function and the fastica algorithm
%
% Inputs: S        - parent GUI information (structure)
%         step_num - step number for current cleaning step in workflow
%         option_num - option number of eegdatapro_ica step

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.


function [] = tmseeg_ica2(S, step_num)
%Runs Independent Component Analysis on the dataset from the previous step
%using EEGLab's pop_runica()
 
%Check if previous steps were done
if tmseeg_previous_step(step_num) 
    return
end
 
global basepath VARS chans_rm

%Data Load
[files, EEG] = eegdatapro_load_step(step_num);
[~,name,~]          = fileparts(files.name); 
S.name              = name;

del_chans = questdlg('Unselect some channels for ICA?');

chans_rm = [];
if strcmp(del_chans,'Yes')
    EEG = channels_del(EEG);   
    EEG = eeg_checkset( EEG );
end


VARS.ICA2_COMP_NUM = ceil((EEG.nbchan-length(chans_rm))*VARS.ICA_COMP_PCT/100);


%Run ICA, save new dataset
h1 = msgbox('Running ICA2,now!');
EEG_ica=EEG;
EEG_O=EEG;
EEG_ica.nbchan=EEG.nbchan-length(chans_rm);
EEG_ica.data=EEG.data(setdiff(1:EEG.nbchan,chans_rm),:,:);
EEG_ica.chanlocs=EEG.chanlocs(setdiff(1:EEG.nbchan,chans_rm));
EEG_ica   = pop_runica( EEG_ica , 'icatype' ,'fastica','g','tanh',...
'approach','symm','lasteig',VARS.ICA2_COMP_NUM);


EEG=EEG_ica;
EEG.data=EEG_O.data;
EEG.chanlocs=EEG_O.chanlocs;
EEG.nbchan=EEG_O.nbchan;
EEG.data(setdiff(1:EEG.nbchan,chans_rm),:,:)=EEG_ica.data;

EEG   = eeg_checkset(EEG);

tmseeg_step_check(files, EEG, S, step_num);
if ~isempty(chans_rm)
    save(fullfile(basepath,[S.name '_' num2str(step_num)  '_ICA2chansUnsel.mat']), 'chans_rm');
end

if ishandle(h1)
    close(h1);
end

end

function [EEG] = channels_del(EEG)
% Calls channel plot through EEGLAB topoplot() function, allows selection
% of channels for deletion with list

%Channels display
t = figure;
topoplot([],EEG.chanlocs,'style','blank','electrodes','labelpoint');
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
     'Callback',{@retrieve_value,channel_list,t, {EEG.chanlocs.labels}}); %#ok
cancel_button = uicontrol('style','pushbutton',...
     'Units','normalized',...
     'string','Cancel',...
     'Position',[0.75 0.05 0.1 0.05],...
     'Parent',t,...
     'Callback',{@cancel_call,t}); %#ok
waitfor(t)

end

function retrieve_value(varargin)
%Retrieve user-selected channels from list for deletion
global chans_rm
h_list = varargin{3};
labels = varargin{5};
chans_sel = get(h_list,'value');
del_txt = ['Unselect channels for ICA?' labels(chans_sel) ];
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