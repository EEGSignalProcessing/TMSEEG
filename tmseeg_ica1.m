% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez,Faranak Farzan
% 2016

% tmseeg_ica1() - Runs Independent Component Analysis using the pop_runica
% EEGLAB function and the fastica algorithm

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.


function [] = tmseeg_ica1(S,step_num)
%Runs Independent Component Analysis on the dataset from the previous step
 %using EEGLab's pop_runica()
global basepath existcolor
    %Data Load
    [files, EEG] = tmseeg_load_step(step_num);
    %Run ICA, save new dataset
    h1 = msgbox('Running ICA1,now!');
    EEG   = pop_runica( EEG, 'icatype' ,'fastica','g','tanh','approach','symm');
    EEG   = eeg_checkset(EEG);
    tmseeg_step_check(files, EEG, S, step_num)
    if ishandle(h1)
        close(h1)
    end

end

