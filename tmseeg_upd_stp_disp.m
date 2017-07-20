function [] = tmseeg_upd_stp_disp(S, ext, num_steps)
%update_step_display() - updates parent GUI display
%   Using path and file information, sets the buttons as either
%   'existcolor'(active) or 'notexistcolor' (inactive), both set as global
%   variables
global existcolor notexistcolor basepath basefile
checkext = '';
for i = 1:num_steps
    checkext = [checkext '_' num2str(i)];
    if exist([basepath '\' basefile checkext ext],'file')
            streval = ['set(S.button' num2str(i) ,' ,',...
                '''BackgroundColor''',' ,','existcolor',');'];
            strevals = ['set(S.button' num2str(i) ,'s ,',...
            '''BackgroundColor''',' ,','existcolor',');'];
        eval(streval)
        eval(strevals)
    else
        streval = ['set(S.button' num2str(i) ,' ,',...
                '''BackgroundColor''',' ,','notexistcolor',');'];
            strevals = ['set(S.button' num2str(i) ,'s ,',...
            '''BackgroundColor''',' ,','notexistcolor',');'];
        eval(streval)
        eval(strevals)
    end
end


end

