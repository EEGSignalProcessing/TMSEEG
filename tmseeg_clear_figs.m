function tmseeg_clear_figs()

main_fig = findobj('type','figure','name','tmseeg');
set(main_fig,'HandleVisibility','off');
close all;
set(main_fig,'HandleVisibility','on');

end

