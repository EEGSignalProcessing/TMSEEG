function cantload = tmseeg_previous_step(step_num)
% tmseeg_previous_step() checks if previous steps were done 
% if not current step is aborted
%
% Created on Nov 2017 by Ben Schwartzmann

global basepath basefile

if strcmp(basefile,'None Selected')
    cantload = 1;
    msgbox('Please load data first');
else
    checkext = '';

    for i = 1:step_num - 1
        checkext = strcat(checkext,['_' num2str(i)]); 
    end

    if exist([basepath '/' basefile checkext '.set'],'file')
        cantload = 0; 
    else
        cantload = 1;
        msgbox('Please do previous steps first');
    end
end

end
    