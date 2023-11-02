function [data,figid] = remove_points(data,figid)
%UI for selecting points for each side
%
% Input Arguments:
%   data (mat[n_select,5]): geolocated points 
%
% Output Arguments:
%   data (mat[n_select,5]): cleaned geolocated points


%prompt message
fprintf('Select points to remove (rigth click to undo, space to reset, and enter to exit)\n')

%
iter = 1;
data_hist = {data};
%select points to remove
while true
    figid = plot_profile(data);
    title({'Select points to remove:','(rigth click to undo, space to reset, and enter to exit)'})
    %record point
    [x,y,button] = ginput(1);

    %exit
    if isempty(button)
        break
    end

    %button options
    if button == 1 %remove closest point within 5m
        [d_min,i_rm] = min(vecnorm(data(:,1:2)-[x,y],2,2));
        if d_min < 5
            data = data(~(1:size(data,1)==i_rm),:);
            iter  = iter + 1;
            data_hist{iter} = data;
        end
    elseif button == 3; %undo (right click)
        iter = iter - 1;
        data = data_hist{iter};
    elseif button == 0; %reset (space bar)
        iter = 1;
        data = data_hist{iter};
    end

    close(figid);
end



end