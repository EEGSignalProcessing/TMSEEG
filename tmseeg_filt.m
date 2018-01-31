% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez, Faranak Farzan
%         2016
%         Ben Schwartzmann
%         2017

% tmseeg_filt() - Interactive display for selection and parameterization
% of th filtering process.  User selects between an FIR and IIR filtering
% option.
% 
% Inputs:  A        - parent GUI structure
%          step_num - step number of tmseeg_filt in workflow

% Display window interface:
%       "Low FIR" [slider] - slider indicating the frequency of the FIR
%       low cut frequency in Hz
%       "High FIR" [slider] - slider indicating the frequency of the FIR
%       high cut frequency in Hz
%       "FIR Filter" [Button] - creates and applies an FIR filter based on
%       the parameters specified in "Low FIR" and "High FIR"
%       "Low IIR" [slider] - slider indicating the frequency of the IIR
%       low cut frequency in Hz
%       "High IIR" [slider] - slider indicating the frequency of the IIR
%       high cut frequency in Hz
%       "Notch Center" [slider] - sets the centre frequency (Hz) of the IIR
%       notch filter for removal of ambient electrical noise, recommended
%       60Hz.
%       "Notch Size" [slider] - sets the width of the IIR notch filter in
%       Hz
%       "IIR Filter" [Button] - creates and applies an IIR filter based on
%       the parameters specified in "Low IIR","High IIR","Notch Center" and
%       "Notch Size"

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.


function tmseeg_filt(A, step_num)

%Check if previous steps were done
if tmseeg_previous_step(step_num) 
    return 
end

global backcolor VARS

%Initializing filter parameters
global filt1_slider_low_fir filt1_slider_high_fir
global filt1_slider_low_iir filt1_slider_high_iir
global notch_center notch_size

%Default filter parameters
filt1_slider_low_fir=1; filt1_slider_high_fir=55;
filt1_slider_low_iir=1; filt1_slider_high_iir=80;
notch_center=60; notch_size=10;

%-----------------------------GUI setup------------------------------------
hfig = figure('Menubar','none',...
              'Toolbar','none',...
              'Name','tmseeg_filt1',...
              'Numbertitle','off',...
              'Resize','off',...
              'Color',backcolor,...
              'DockControls','off');

Title_txt  = uicontrol(hfig,'Style','text',...
                    'String','Select Filter Type and Parameters',...
                    'Units','normalized',...,
                    'Position',[0.3 0.9 0.4 0.05]); %#ok
                
%FIR Filter
slider_pre = uicontrol('Parent', hfig,'Style','slider',...
                    'Units','normalized',...
                    'Position',[0.05 0.7 0.4 0.05],...
                    'Tag','filter1_slider1',...
                    'SliderStep',[0.05 0.05],...
                    'Value',filt1_slider_low_fir,...
                    'Max',10,...
                    'Min',0,...                
                    'Callback',@slider_callback1); %#ok
slider_pos = uicontrol('Parent', hfig,'Style','slider',...
                    'Units','normalized',...
                    'Position',[0.55 0.7 0.4 0.05],...
                    'Tag','filter1_slider2',...
                    'SliderStep',[0.05 0.05],...
                    'Value',filt1_slider_high_fir,...
                    'Max',90,...
                    'Min',50,... 
                    'Callback',@slider_callback2); %#ok
text_pre  = uicontrol(hfig,'Style','text',...
                    'String',num2str(filt1_slider_low_fir),...
                    'Units','normalized',...,
                    'Tag','filter1_text1',...
                    'Position',[0.2 0.75 0.1 0.05],...
                    'Callback',@text_callback1); %#ok
text_pre_unit  = uicontrol(hfig,'Style','text',...
                    'String','Hz',...
                    'Units','normalized',...,
                    'Position',[0.3 0.75 0.06 0.05]); %#ok
text_pos  = uicontrol(hfig,'Style','text',...
                    'String',num2str(filt1_slider_high_fir),...
                    'Units','normalized',...
                    'Tag','filter1_text2',...
                    'Position',[0.7 0.75 0.1 0.05],...
                    'Callback',@text_callback2); %#ok
text_pos_unit  = uicontrol(hfig,'Style','text',...
                    'String','Hz',...
                    'Units','normalized',...
                    'Position',[0.8 0.75 0.06 0.05]); %#ok                          
FIR_button = uicontrol('Parent', hfig,'Style','pushbutton',...
                    'Units','normalized',...
                    'Position',[0.4 0.55 0.2 0.1],...
                    'String','FIR Filter',...
                    'Callback',{@tmseeg_FIR_func,A,step_num}); %#ok     
FIR_ord_txt = uicontrol('Parent', hfig,'Style','text',...
                    'Units','normalized',...
                    'Position',[0.65 0.55 0.2 0.05],...
                    'String','FIR Filter Order:'); %#ok
FIR_filt_ord_button = uicontrol('Parent', hfig,'Style','pushbutton',...
                    'Units','normalized',...
                    'Position',[0.85 0.55 0.05 0.05],...
                    'String',num2str(VARS.FIR_FILTER_ORDER),...
                    'tag','fir_filt_ord',...
                    'Callback',{@FIR_filt_ord}); %#ok
                
% IIR Filter
slider_pre_iir = uicontrol('Parent', hfig,'Style','slider',...
                    'Units','normalized',...
                    'Position',[0.05 0.35 0.4 0.05],...
                    'Tag','filter1_slider1_iir',...
                    'SliderStep',[0.05 0.05],...
                    'Value',filt1_slider_low_iir,...
                    'Max',10,...
                    'Min',0,...                
                    'Callback',@slider_callback1_iir); %#ok
slider_pos_iir = uicontrol('Parent', hfig,'Style','slider',...
                    'Units','normalized',...
                    'Position',[0.55 0.35 0.4 0.05],...
                    'Tag','filter1_slider2_iir',...
                    'SliderStep',[1 1]/45,...
                    'Value',filt1_slider_high_iir,...
                    'Max',90,...
                    'Min',45,... 
                    'Callback',@slider_callback2_iir); %#ok
text_pre_iir  = uicontrol(hfig,'Style','text',...
                    'String',num2str(filt1_slider_low_iir),...
                    'Units','normalized',...,
                    'Tag','filter1_text1_iir',...
                    'Position',[0.2 0.40 0.1 0.05],...
                    'Callback',@text_callback1_iir); %#ok
text_pre_unit_iir  = uicontrol(hfig,'Style','text',...
                    'String','Hz',...
                    'Units','normalized',...,
                    'Position',[0.3 0.40 0.06 0.05]); %#ok               
text_pos  = uicontrol(hfig,'Style','text',...
                    'String',num2str(filt1_slider_high_iir),...
                    'Units','normalized',...
                    'Tag','filter1_text2_iir',...
                    'Position',[0.7 0.40 0.1 0.05],...
                    'Callback',@text_callback2_iir); %#ok
text_pos_unit_iir  = uicontrol(hfig,'Style','text',...
                    'String','Hz',...
                    'Units','normalized',...
                    'Position',[0.8 0.40 0.06 0.05]); %#ok               
slider_notch_center = uicontrol('Parent', hfig,'Style','slider',...
                    'Units','normalized',...
                    'Position',[0.05 0.2 0.4 0.05],...
                    'Tag','slider_notch_center',...
                    'SliderStep',[1 1]/10,...
                    'Value',notch_center,... 
                    'Max',60,...
                    'Min',50,... 
                    'Callback',@callback_slider_notch_center); %#ok
slider_notch_size = uicontrol('Parent', hfig,'Style','slider',...
                    'Units','normalized',...
                    'Position',[0.55 0.2 0.4 0.05],...
                    'Tag','slider_notch_size',...
                    'SliderStep',[1 1]/35,...
                    'Value',notch_size,...
                    'Max',40,...
                    'Min',5,... 
                    'Callback',@callback_slider_notch_size); %#ok
text_notch_center  = uicontrol(hfig,'Style','text',...
                    'String',num2str(notch_center),...
                    'Units','normalized',...,
                    'Tag','text_notch_center',...
                    'Position',[0.2 0.25 0.1 0.05],...
                    'Callback',@callback_text_notch_center); %#ok
text_unit_notch_center  = uicontrol(hfig,'Style','text',...
                    'String','Hz',...
                    'Units','normalized',...,
                    'Position',[0.3 0.25 0.06 0.05]); %#ok 
text_f_notch_center  = uicontrol(hfig,'Style','text',...
                    'String','notch center:',...
                    'Units','normalized',...,
                    'Position',[0.05 0.25 0.16 0.05]); %#ok
text_notch_size  = uicontrol(hfig,'Style','text',...
                    'String',num2str(notch_size),...
                    'Units','normalized',...,
                    'Tag','text_notch_size',...
                    'Position',[0.7 0.25 0.1 0.05],...
                    'Callback',@callback_text_notch_size); %#ok
text_unit_notch_size  = uicontrol(hfig,'Style','text',...
                    'String','Hz',...
                    'Units','normalized',...,
                    'Position',[0.8 0.25 0.06 0.05]); %#ok 
text_f_notch_size  = uicontrol(hfig,'Style','text',...
                    'String','notch size:',...
                    'Units','normalized',...,
                    'Position',[0.55 0.25 0.16 0.05]);  %#ok               
button_iir = uicontrol('Parent', hfig,'Style','pushbutton',...
                    'Units','normalized',...
                    'Position',[0.4 0.05 0.2 0.1],...
                    'String','IIR Filter',...
                    'Callback',{@tmseeg_IIR_func, A, step_num}); %#ok
IIR_ord_txt = uicontrol('Parent', hfig,'Style','text',...
                    'Units','normalized',...
                    'Position',[0.65 0.05 0.2 0.05],...
                    'String','IIR Filter Order:'); %#ok
FIR_filt_ord_button = uicontrol('Parent', hfig,'Style','pushbutton',...
                    'Units','normalized',...
                    'Position',[0.85 0.05 0.05 0.05],...
                    'String',num2str(VARS.IIR_FILTER_ORDER),...
                    'tag','iir_filt_ord',...
                    'Callback',{@IIR_filt_ord}); %#ok
                            
end


function slider_callback1(hObject,eventdata)
%Called by "FIR low" slider, updates slider position and relevant title

global filt1_slider_low_fir
h = findobj('Tag','filter1_text1');
set(h,'String',get(hObject,'Value'))
data = guidata(hObject);
filt1_slider_low_fir= get(hObject,'Value');
guidata(hObject,data);

end

function slider_callback2(hObject,eventdata)
%Called by "FIR high" slider, updates slider position and relevant title

global filt1_slider_high_fir
h = findobj('Tag','filter1_text2');
set(h,'String',get(hObject,'Value'))
data = guidata(hObject);
filt1_slider_high_fir=get(hObject,'Value');
guidata(hObject,data);

end

function FIR_filt_ord(varargin)

global VARS

prompt = {'Enter FIR Filter order (50-200):'};
dlg_title = 'FIR Filter Order';
num_lines = 1;
defaultans = {num2str(VARS.FIR_FILTER_ORDER)};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

if isempty(answer)
    disp('No changes made')
else
    order = str2double(answer{1});
    
    if (order < 50) || (order > 200)
        error('Invalid Filter Order Entry')
    else
        VARS.FIR_FILTER_ORDER = order;
        h = findobj('Tag','fir_filt_ord');
        set(h,'String',num2str(order))
    end
    
end
    
end

function tmseeg_FIR_func(varargin)
%Called by selection of the "FIR Filter" button, implements an FIR filter
%for low pass and high pass filtering based on the user-selected frequency
%parameters.
global VARS

A = varargin{3};
step_num = varargin{4};
%Data and variable loading
global filt1_slider_low_fir filt1_slider_high_fir 

[files, EEG] = tmseeg_load_step(step_num);

%FIR filter
EEG.data= eegfilt(EEG.data(:,:),EEG.srate,filt1_slider_low_fir,filt1_slider_high_fir,size(EEG.data,2),VARS.FIR_FILTER_ORDER,0);
tmseeg_step_check(files, EEG, A, step_num)
close;

end

function slider_callback1_iir(hObject,eventdata)
%Called by "IIR low" slider, updates variables and GUI

global filt1_slider_low_iir
h = findobj('Tag','filter1_text1_iir');
set(h,'String',get(hObject,'Value'))
data = guidata(hObject);
filt1_slider_low_iir=get(hObject,'Value');
guidata(hObject,data);

end

function slider_callback2_iir(hObject,eventdata)
%Called by "IIR high" slider, updates variables and GUI

global filt1_slider_high_iir
h = findobj('Tag','filter1_text2_iir');
set(h,'String',get(hObject,'Value'))
data = guidata(hObject);
filt1_slider_high_iir=get(hObject,'Value');
guidata(hObject,data);

end

function callback_slider_notch_center(hObject,eventdata)
%Called by "Notch Center" slider, updates variables and GUI

global notch_center
h = findobj('Tag','text_notch_center');
set(h,'String',get(hObject,'Value'))
notch_center=get(hObject,'Value');

end

function callback_slider_notch_size(hObject,eventdata)
%Called by "Notch Size" slider, updates variables and GUI

global notch_size
h = findobj('Tag','text_notch_size');
set(h,'String',get(hObject,'Value'))
notch_size=get(hObject,'Value');

end

function IIR_filt_ord(varargin)

global VARS

prompt = {'Enter IIR Filter order (1-20):'};
dlg_title = 'IIR Filter Order';
num_lines = 1;
defaultans = {num2str(VARS.IIR_FILTER_ORDER)};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

if isempty(answer)
    disp('No changes made')
else
    order = str2double(answer{1});
    
    if (order < 1) || (order > 20)
        error('Invalid Filter Order Entry')
    else
        VARS.IIR_FILTER_ORDER = order;
        h = findobj('Tag','iir_filt_ord');
        set(h,'String',num2str(order))
    end
    
end
    
end

function tmseeg_IIR_func(varargin)
%Called by selection of the "IIR Filter" button, implements an IIR filter
%for low pass and high pass filtering based on the user-selected frequency
%parameters.  Additionally, applies a Notch Filter based on parameters
%specified with notch sliders.

%Data and variable loading
global VARS
global filt1_slider_low_iir filt1_slider_high_iir
global notch_center notch_size
A        = varargin{3};
step_num = varargin{4};
[files, EEG] = tmseeg_load_step(step_num);

%Filter Design
Fs=EEG.srate;
ord = VARS.IIR_FILTER_ORDER;
[z1, p1, k1]  = butter(ord,[filt1_slider_low_iir filt1_slider_high_iir]/(Fs/2),'bandpass');
[xall1,yall2] = zp2sos(z1,p1,k1);
[z2, p2, k2]  = butter(ord, [notch_center-(notch_size/2) notch_center+(notch_size/2)]/(Fs/2), 'stop'); % 10th order filter
[xs1,xs2]     = zp2sos(z2,p2,k2); % Convert to 2nd order sections form

%Apply Filter
for ch=1:size(EEG.data,1)
	tempA=filtfilt(xall1,yall2,reshape(double(EEG.data(ch,:)),size(EEG.data,2),size(EEG.data,3))); 
	tempB=filtfilt(xs1,xs2,double(tempA)); % apply notch filter
	EEG.data(ch,:,:)= double(tempB);
end

tmseeg_step_check(files, EEG, A, step_num);
close;

end





