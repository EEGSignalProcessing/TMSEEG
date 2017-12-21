function [files, EEG] = tmseeg_load_step(step_num)
% tmseeg_load_step() loads previous step dataset given basepath and the step
% number

global basepath
checkext = '';

for i = 1:step_num - 1
    checkext = strcat(checkext,['_' num2str(i)]); %modification by Ben
    %    checkext = [checkext '_' num2str(i)]; 
end

files   = dir(fullfile(basepath,['*' checkext '.set']));
EEG     = pop_loadset('filename',files.name,'filepath',basepath);

end
