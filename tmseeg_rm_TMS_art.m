% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez,Faranak Farzan
% 2016

% tmseeg_rm_TMS_art() - displays epoched TMSEEG data, allowing
% user adjustment of TMS Pulse removal with sliders denoting removal times.
% Supports the single pulse and double pulse paradigms.
% 
% Inputs:   A        - parent GUI structure
%           step_num - step of tmseeg_rm_ch_tr_1 in workflow

% Display window interface:
%       "Activity Plot" - [main window] displays the overlain plot of the
%       mean data amplitude for all trials, from -150ms to 150ms of the
%       main TMS Pulse
%       "Pulse Deletion 1" - [Sliders] controls the deletion of the main
%       pulse (second pulse in case of double pulse paradigm) with sliders
%       controlling the range of deletion.
%       "Pulse Deletion 2" - [Sliders] controls the deletion of the priming
%       pulse (first pulse in case of double pulse paradigm) with sliders
%       controlling the range of deletion.  In the case of a single pulse
%       paradigm, this slider is not visible and does not contribute to
%       deletion.
%       "Select Paradigm" - [drop-down menu] allows user to select between
%       the single and double pulse paradigms, making the "Pulse Deletion
%       2" set of objects active.
%       "Delete TMS" - [button] - zeros the data within the range specified
%       by the current deletion range


% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

function tmseeg_rm_TMS_art(A, step_num)

%Check if previous steps were done
if tmseeg_previous_step(step_num)
    return
end

global backcolor VARS

%-----------------------Child figure creation------------------------------
S.chfig = figure('menubar','none',...
              'Toolbar','figure',...
              'Units','normalized',...
              'name','tmseeg_removeTMS_b',...
              'numbertitle','off',...
              'resize','on',...
              'color',backcolor,...
              'Position',[0.1 0.1 0.8 0.8],...
              'DockControls','off');

% Main EEG Data Plot
subplot(4,5,1:15);

[~, EEG] = tmseeg_load_step(step_num);
plot(EEG.times,squeeze(mean(EEG.data,3)));
xlim([VARS.TMS_DSP_XMIN (VARS.TMS_DSP_XMAX + VARS.PULSE_DURATION)]);
title('Use Sliders and pulldown menu to control deletion of TMS pulse')
xlabel('Time(ms)')
ylabel(['Amplitude (' char(0181) 'V)'])
hold

% Setting lines for visualization of deletion range
s1      = VARS.SLIDER_MIN;
s2      = VARS.SLIDER_MAX + VARS.PULSE_DURATION;
S.hl1   = line([s1 s1],get(gca,'yLim'));
S.hl2   = line([s2 s2],get(gca,'yLim'));

ISI = -VARS.ISI;
s1_b = ISI + VARS.SLIDER_MIN;
s2_b = ISI + VARS.SLIDER_MAX;
S.hl1_b = line([s1_b s1_b],get(gca,'yLim'),'Color','r');
S.hl2_b = line([s2_b s2_b],get(gca,'yLim'),'Color','r');


%------------------------Button/Slider Setup-------------------------------
S.slider_pre = uicontrol('Parent', S.chfig,'Style','slider',...
                    'Units','normalized',...
                    'Position',[0.6 0.15 0.1 0.05],...
                    'Tag','slider1',...
                    'SliderStep',[1 1]/abs(VARS.SLIDER_MIN - 10),...%normalize to slider range
                    'Value',VARS.SLIDER_MIN,...
                    'Max',0,...
                    'Min',(VARS.SLIDER_MIN - 10),...                
                    'Callback',{@slider_callback1,S});
S.slider_pos = uicontrol('Parent', S.chfig,'Style','slider',...
                    'Units','normalized',...
                    'Position',[0.75 0.15 0.1 0.05],...
                    'Tag','slider2',...
                    'SliderStep',[1 1]/(VARS.SLIDER_MAX + 10),...%normalize to slider range
                    'Value',(VARS.PULSE_DURATION + VARS.SLIDER_MAX),...
                    'Max',(VARS.SLIDER_MAX + VARS.PULSE_DURATION + 10),...
                    'Min',0 + VARS.PULSE_DURATION,... 
                    'Callback',{@slider_callback2,S});
S.text_pre  = uicontrol('Parent', S.chfig,'Style','text',...
                    'String',num2str(s1),...
                    'Units','normalized',...,
                    'Tag','rmtms_text1',...
                    'Position',[.6 .2 .1 .025],...
                    'Callback',{@text_callback1,S});
S.text_pos  = uicontrol('Parent', S.chfig,'Style','text',...
                    'String',num2str(s2),...
                    'Units','normalized',...
                    'Tag','rmtms_text2',...
                    'Position',[.75 .2 .1 .025],...
                    'Callback',{@text_callback2,S});
S.text_title_s  = uicontrol('Parent', S.chfig,'Style','text',...
                    'String','Pulse Deletion Min/Max',...
                    'Units','normalized',...
                    'Tag','rmtms_title_s',...
                    'Position',[.65 .25 .15 .025],...
                    'Callback',{@text_callback2,S});
S.slider_pre_b = uicontrol('Parent', S.chfig,'Style','slider',...
                    'Units','normalized',...
                    'Position',[0.2 0.15 0.1 0.05],...
                    'Tag','slider1_b',...
                    'SliderStep',[1 1]/abs(VARS.SLIDER_MIN - 10),...%normalize to slider range
                    'Value',ISI + VARS.SLIDER_MIN,...
                    'Max',ISI,...
                    'Min',ISI + VARS.SLIDER_MIN - 10,...                
                    'Callback',{@slider_callback1_b,S});
S.slider_pos_b = uicontrol('Parent', S.chfig,'Style','slider',...
                    'Units','normalized',...
                    'Position',[0.35 0.15 0.1 0.05],...
                    'Tag','slider2_b',...
                    'SliderStep',[1 1]/(VARS.SLIDER_MAX + 10),... %normalize to slider range
                    'Value',ISI + VARS.SLIDER_MAX,...
                    'Max',ISI + VARS.SLIDER_MAX + 10,...
                    'Min', ISI,... 
                    'Callback',{@slider_callback2_b,S});
S.text_pre_b  = uicontrol('Parent', S.chfig,'Style','text',...
                    'String',num2str(s1_b),...
                    'Units','normalized',...,
                    'Tag','rmtms_text1_b',...
                    'Position',[.2 .2 .1 .025],...
                    'Callback',{@text_callback1_b,S});
S.text_pos_b  = uicontrol('Parent', S.chfig,'Style','text',...
                    'String',num2str(s2_b),...
                    'Units','normalized',...
                    'Tag','rmtms_text2_b',...
                    'Position',[.35 .2 .1 .025],...
                    'Callback',{@text_callback2_b,S});
S.text_title_d  = uicontrol('Parent', S.chfig,'Style','text',...
                    'String','Pulse Deletion Min/Max',...
                    'Units','normalized',...
                    'Tag','rmtms_text_title_d',...
                    'Position',[.25 .25 .15 .025],...
                    'Callback',{@text_callback2,S});                         
S.button = uicontrol('Parent', S.chfig,'Style','pushbutton',...
                    'Units','normalized',...
                    'Position',[0.6 0.02 .2 0.05],...
                    'String','Delete TMS',...
                    'Callback',{@button_callback,S,A,step_num});                

% Set pulse paradigms
pulse{1} = 'double pulse';
pulse{2} = 'single pulse';

S.pop = uicontrol('Parent', S.chfig,'Style','popupmenu',...
                    'Units','normalized',...
                    'Position',[0.2 0.02 .2 0.05],...
                    'Value', 2,...
                    'String',pulse,... 
                    'Callback',{@single_duo_pulse,S});
S.text_pulse = uicontrol('Parent', S.chfig,'Style','text',...
                    'String','Select Paradigm:',...
                    'Units','normalized',...
                    'Tag','rmtms_pulse',...
                    'Position',[.1 0.04 .1 .025],...
                    'Callback',{@text_callback2_b,S});

%Setting deletion limits to the slider positions
S.removeFrom = s1;
S.removeTo = s2;
S.removeFrom_b = s1_b;
S.removeTo_b = s2_b;

%Default to Single pulse
set(S.hl1_b,'Visible','Off');
set(S.hl2_b,'Visible','Off');
set(S.text_title_d,'Visible','Off');
set(S.text_pre_b,'Visible','Off');
set(S.text_pos_b,'Visible','Off');    
set(S.slider_pre_b,'Visible','Off');
set(S.slider_pos_b,'Visible','Off');
guidata(S.chfig,S);
end

function single_duo_pulse(varargin)
% single_duo_pulse() - called by the S.pop popupmenu, changes visibility of
%                      GUI objects based off the selected TMS paradigm.

S = varargin{3};
S = guidata(S.chfig);

if get(S.pop,'Value')==2
    set(S.hl1_b,'Visible','Off');
    set(S.hl2_b,'Visible','Off');
    set(S.text_title_d,'Visible','Off');
    set(S.text_pre_b,'Visible','Off');
    set(S.text_pos_b,'Visible','Off');    
	set(S.slider_pre_b,'Visible','Off');
    set(S.slider_pos_b,'Visible','Off');      
else
    set(S.hl1_b,'Visible','On');
    set(S.hl2_b,'Visible','On');
    set(S.text_title_d,'Visible','On');
	set(S.text_pre_b,'Visible','On');
    set(S.text_pos_b,'Visible','On');
	set(S.slider_pre_b,'Visible','On');
    set(S.slider_pos_b,'Visible','On');
end

end


function slider_callback1(varargin)
% Called by S.slider_pre callback function when slider is moved.
% Sets minimum removal time to updated slider position, refreshes location
% of slider and label.

S = varargin{3};
S = guidata(S.chfig);
set(S.text_pre,'String',get(varargin{1},'Value'));
S.removeFrom=get(varargin{1},'Value');
delete(S.hl1);
S.hl1 = line([S.removeFrom S.removeFrom],get(gca,'yLim'));
guidata(S.chfig,S);

end

function slider_callback2(varargin)
% Called by S.slider_pos callback function when slider is moved.
% Sets maximum removal time to updated slider position, refreshes location
% of slider and label.

S = varargin{3};
S = guidata(S.chfig);
set(S.text_pos,'String',get(varargin{1},'Value'));
S.removeTo = get(varargin{1},'Value');
delete(S.hl2);
S.hl2 = line([S.removeTo S.removeTo],get(gca,'yLim'));
guidata(S.chfig,S);

end


function slider_callback1_b(varargin)
% Called by S.slider_pre_b callback function when slider is moved.
% Sets minimum removal time to updated slider position, refreshes location
% of slider and label.

S = varargin{3};
S = guidata(S.chfig);

set(S.text_pre_b,'String',get(varargin{1},'Value'));
S.removeFrom_b=get(varargin{1},'Value');
delete(S.hl1_b);
S.hl1_b = line([S.removeFrom_b S.removeFrom_b],get(gca,'yLim'),'Color','r');
guidata(S.chfig,S);

end

function slider_callback2_b(varargin)
% Called by S.slider_pos_b callback function when slider is moved.
% Sets maximum removal time to updated slider position, refreshes location
% of slider and label.

S = varargin{3};
S = guidata(S.chfig);
set(S.text_pos_b,'String',get(varargin{1},'Value'));
S.removeTo_b = get(varargin{1},'Value');
delete(S.hl2_b);
S.hl2_b = line([S.removeTo_b S.removeTo_b],get(gca,'yLim'),'Color','r');
guidata(S.chfig,S);

end

function button_callback(varargin)
% Called by selection of "Delete TMS" button. calls tmseeg_removeTMS_func()
S = varargin{3};
A = varargin{4};

step_num = varargin{5};
S = guidata(S.chfig);
tmseeg_removeTMS_func(S, A ,step_num)
guidata(S.chfig,S);
close

end

function tmseeg_removeTMS_func(S,A,step_num)
% removes TMS pulse period based on the position of the sliders

removeFrom  = S.removeFrom; 
removeTo = S.removeTo; 
removeFrom_b = S.removeFrom_b; 
removeTo_b = S.removeTo_b;

[files, EEG]  = tmseeg_load_step(step_num);
%[~,name,ext] = fileparts(files.name);
temp_removeFrom = find(floor(EEG.times)<=removeFrom);
temp_removeTo = find(floor(EEG.times)<=removeTo);
period2remove = temp_removeFrom(end)+1:temp_removeTo(end)-1;
EEG = eeg_checkset( EEG );

%Single Pulse removal case
if get(S.pop,'Value')==2    
        EEG.data(:,period2remove,:) = [];
        EEG.times(period2remove)    = [];
        EEG.TMS_period2remove_1     = period2remove;
        EEG.custom.times            = EEG.times;
        EEG.pnts                    = numel(EEG.times);
        EEG                         = eeg_checkset( EEG ); % some adjustments would be made
%Double pulse removal case
else
        EEG.data(:,period2remove,:) = [];  
        EEG.times(period2remove)    = []; 
        EEG.TMS_period2remove_1     = period2remove; 
        EEG.pnts                    = numel(EEG.times); 
        EEG                         = eeg_checkset(EEG);
        
        temp_removeFrom_b = find(floor(EEG.times)<=removeFrom_b);
        temp_removeTo_b = find(floor(EEG.times)<=removeTo_b);
        period2remove_b = temp_removeFrom_b(end)+1:temp_removeTo_b(end)-1;
        
        EEG                           = eeg_checkset(EEG);
        EEG.data(:,period2remove_b,:) = [];
        EEG.times(period2remove_b)    = [];  
        EEG.TMS_period2remove_b       = period2remove_b;
        EEG                           = eeg_checkset(EEG);
        EEG.custom.times              = EEG.times;
        EEG.pnts                      = numel(EEG.times);
        EEG                           = eeg_checkset(EEG); % some adjustments would be made
end

nevents = length(EEG.event);
for index = 1 : nevents
    EEG.event(index).latency=EEG.event(index).latency-(index-1)*length(period2remove);
end

tmseeg_step_check(files, EEG, A, step_num);

end




