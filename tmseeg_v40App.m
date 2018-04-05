classdef tmseeg_v40App < handle
%
% Usage:
%     app.tmseeg_v40App

  properties
      AppPath = {'/tmseeg_v40/code'};
	  AppClass = 'tmseeg_v40App';
	  AppHandle;
	  AppCount = 0;
      Increment = 1;
	  Decrement = 0;
      Output;
      CurrClass;
      Version = '13a';
  end  
  methods (Static)
      function count = refcount(increment)
          persistent AppCount;
          if(isempty(AppCount))
              AppCount = 1;
          else
              if(increment)
                  AppCount = plus(AppCount,1);
              else
                  AppCount = minus(AppCount,1);
                  if AppCount < 0
                    AppCount = 0;
                  end
              end
          end
          count = AppCount;
       end
  end
  
  methods
    % Create the application object
    function obj = tmseeg_v40App()      
      obj.CurrClass = metaclass(obj);
      startApp(obj)
    end

    function value = get.AppPath(obj)
       appview = com.mathworks.appmanagement.AppManagementViewSilent;
       appAPI = com.mathworks.appmanagement.AppManagementApiBuilder.getAppManagementApiCustomView(appview);
           
       myAppsLocation = char(appAPI.getMyAppsLocation);
       
       value = cellfun(@(x) fullfile(myAppsLocation, x), obj.AppPath, 'UniformOutput', false);
    end

    % Start the application
    function startApp(obj)
        % Put the application directory on the path
        %allpaths = genpath(obj.AppPath{:});
        %addpath(strrep(allpaths, [obj.AppPath{:} filesep 'metadata;'], ''));      

        % Must load function (force by using function handle) or nargout lies.
        % Check if the app is a GUIDE app
        if nargout(@tmseeg_main) == 0  
            eval('tmseeg_main');
        else
			obj.AppHandle = eval('tmseeg_main');   
        end 
        % Increment the reference count by one and lock the file
        mlock;		
        tmseeg_v40App.refcount(obj.Increment);

        if(ishandle(obj.AppHandle))
		    % Traditional graphics handle based app
	        obj.attachOncleanupToFigure(obj.AppHandle);
        elseif isa(obj.AppHandle, 'matlab.apps.AppBase')
		    % appdesigner based app
            obj.attachOncleanupToFigure(appdesigner.internal.service.AppManagementService.getFigure(obj.AppHandle));
        elseif isa(obj.AppHandle,'handle') && ~isvalid(obj.AppHandle)
            % Cleanup in the case where the handle was invalidated before here
            appinstall.internal.stopapp([],[],obj)
        else
            % There will be no call to stopapp, instead decrease the refcount 
            % now to prevent future clearing issues
            tmseeg_v40App.refcount(obj.Increment); 
            munlock;
		end
    end

    function attachOncleanupToFigure(obj, fig)
        % Setup cleanup code on figure handle using onCleanup object
        cleanupObj = onCleanup(@()appinstall.internal.stopapp([],[],obj)); 
        appdata = getappdata(fig); 
        appfields = fields(appdata);
        found = cellfun(@(x) strcmp(x,'AppCleanupCode'), appfields);
        if(~any(found))
            setappdata(fig, 'AppCleanupCode', cleanupObj);     
        end  
    end
  end
end
