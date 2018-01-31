% Author: Ye Mei, Luis Garcia Dominguez, Faranak Farzan   2015

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

function tmseeg_displ_comp(comptype, I)

i = comptype>0;

if ~any(i)
    return
else
    f = find(i);
    
    for k=1:numel(f)
        a(k)=find(I==f(k)); %#ok
    end
    
    [find(i)' comptype(i)' a(:)] %#ok
end

end
