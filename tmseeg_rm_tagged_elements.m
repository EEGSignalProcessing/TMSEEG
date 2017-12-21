% Author: Ye Mei, Luis Garcia Dominguez,Faranak Farzan   2015

% tmseeg_rm_tagged_elements() - removed selected trials, channels, and
% trial/channel pairings according to the toDelete.mat file generated in
% the relevant editing step.

% inputs:   EEG      - EEG dataset in .set format
%           toDelete - list of elements tagged for deletion

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

function [EEG, GC, GT] = tmseeg_rm_tagged_elements(EEG,toDelete)
global VARS
labels = {EEG.chanlocs.labels};
X               = ones(EEG.nbchan,EEG.trials);
full_ch_rm = [];
full_tr_rm = [];
for i=1:size(toDelete,1) % Reconstruction of deletion from sparse toDelete
    tr=toDelete(i,1);
    ch=toDelete(i,2);
    if tr==0
        X(ch,:)=0;
        full_ch_rm = [full_ch_rm ch];
    end
    if ch==0
        X(:,tr)=0;
        full_tr_rm = [full_tr_rm tr];
    end
    if (tr~=0)&&(ch~=0)
    X(ch,tr)=0;
    end   
end

toDelete=X;

GC             = 1:size(toDelete,1);
GT             = 1:size(toDelete,2);

% If the number of channels marked for deletion in a trial exceeds the set
% threshold VARS.NUM_BAD_CHANS, the corresponding trial is deleted
bt             = (sum(~toDelete) - numel(full_ch_rm))  > VARS.NUM_BAD_CHANS; 
toDelete(:,bt) = [];

% If the number of trials marked for deletion in a channel exceeds the set
% threshold VARS.NUM_BAD_TRIAL, the corresponding channel is deleted
bc             = sum(~toDelete,2)> VARS.NUM_BAD_TRIALS; 
toDelete(bc,:) = [];
labels(bc) = [];


EEG     = pop_select(EEG, 'nochannel', find(bc)); %Remove bad channels
GC(bc)  = [];
EEG     = pop_select(EEG, 'notrial',   find(bt)); %Remove bad trials
GT(bt)  = [];
EEG     = eeg_checkset( EEG );
if  isfield(EEG, 'epochinfo')
    EEG.epochinfo(bt)  = [];
end

%Interpolate bad trials within channels that do not meet the criteria for
%removal (set by threshold VARS.NUM_BAD_CHANS and visa versa
if any(~toDelete(:))
    EEGkk   = EEG;
    x       = find(any(~toDelete,2));
    disp(['Interpolating ' num2str(numel(x)) ' channels within trials'])
    EEGkk   = pop_interp(EEGkk, x, 'spherical');
    for i = 1:numel(x)
        newdata = find(~toDelete(x(i),:));
        disp(['Interpolating ' num2str(numel(newdata)) ' trials within channel ' labels{x(i)}])
        EEG.data(x(i),:,newdata) = EEGkk.data(x(i),:,newdata);
    end
    EEG     = eeg_checkset( EEG );
end
