% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez, Faranak Farzan
%         2016
%         Ben Schwartzmann 
%         2017

% tmseeg_show() - Displays EEG data in a butterfly plot after the processing 
% step given by afterstep

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

function []=tmseeg_show(afterstep)

%Check if previous step was done
if tmseeg_previous_step(afterstep+1)
    return
end

global hfinalax hzoom xshowmin xshowmax yshowlimit backcolor VARS

hfig = figure('Units','normalized',...
              'Name',['EEG After Step ' num2str(afterstep)],...
              'Numbertitle','off',...
              'Resize','on',...
              'Color',backcolor,...
              'Position',[0 0 0.7 0.7],...
              'DockControls','off'); %#ok
          
pre_pulse_deletion = 0;

yshowlimit = VARS.YSHOWLIMIT;

%Adjust display limits based on epoching
if xshowmin < VARS.EPCH_STRT
    xshowmin = VARS.EPCH_STRT;
end
if xshowmax > VARS.EPCH_END
    xshowmax = VARS.EPCH_END;
end
%Load proper dataset
[~, EEG] = tmseeg_load_step(afterstep + 1);

if afterstep == 1 || afterstep == 10
    pre_pulse_deletion = 1;
end
%EEGtimes  = EEG.times;

%Create topo plot with EEGLAB timtopo() command  
if(pre_pulse_deletion)
    data_temp = squeeze(nanmean(EEG.data,3));
else
    data_temp = squeeze(nanmean(EEG.data,3));

    if(isfield(EEG,{'TMS_period2remove_b'}))
        ix = min(EEG.TMS_period2remove_b);
        rm_pulse_fill = NaN(size(data_temp,1),length(EEG.TMS_period2remove_b));
        data_temp = cat(2,data_temp(:,1:ix-1),rm_pulse_fill,data_temp(:,ix:end));
    end

    %Insert NaN values to fill space where TMS pulse was removed
    ix = min(EEG.TMS_period2remove_1);
    rm_pulse_fill = NaN(size(data_temp,1),length(EEG.TMS_period2remove_1));
    data_temp = cat(2,data_temp(:,1:ix-1),rm_pulse_fill,data_temp(:,ix:end));

end

EEGtimes =  min(EEG.times):1000/EEG.srate:max(EEG.times);
data = data_temp(:,EEGtimes>=xshowmin & EEGtimes<=xshowmax);
timtopo(data, EEG.chanlocs,'limits',[xshowmin xshowmax -yshowlimit yshowlimit])

%Load EEG Data, display in custom plot allowing zoom feature

figure('Units','normalized',...
        'Numbertitle','off',...
        'Name',['After Step ' num2str(afterstep)],...
        'Position',[0 0 .9 .9 ]);

x = EEGtimes(EEGtimes>=xshowmin & EEGtimes<=xshowmax);
y = squeeze(nanmean(data,3));
 
plot(x,y)
hfinalax  = gca;
% xlim([-200 500]); 
hzoom     = zoom;
titlestr  = ['Data after processing step ' num2str(afterstep) ...
    ', use cursor to zoom in, shift + click to zoom out'];
title(titlestr)
xlabel('Time(ms)');
ylabel(['Amplitude (' char(0181) 'V)']);
zoom on

end

