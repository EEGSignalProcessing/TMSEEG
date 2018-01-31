function [] = tmseeg_upd_stp_disp(S, ext, num_steps)
% tmseeg_upd_stp_disp() - updates parent GUI display
% Using path and file information, sets the buttons as either
% 'existcolor'(active) or 'notexistcolor' (inactive), both set as global
% variables

global existcolor notexistcolor basepath basefile
checkext = '';

for i = 1:num_steps
    checkext = strcat(checkext,['_' num2str(i)]);
    
    if exist([basepath '/' basefile checkext ext],'file')
        setcolor = existcolor;
    else
        setcolor = notexistcolor;
    end
    
    currentbutton = sprintf('button%d',i);
    currentbuttons = sprintf('button%ds',i);
    set(S.(currentbutton),'BackgroundColor',setcolor);
    set(S.(currentbuttons),'BackgroundColor',setcolor);
end

end

