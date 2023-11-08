function [data_selected,side_idx,figid] = select_points_side(data, side_name)
%UI for selecting points for each side
%
% Input Arguments:
%   data          (mat[n_select,5]): geolocated points 
%   side_name     (string): name for side to select points
%
% Output Arguments:
%   data_selected (mat[n_select,5]): coordinates and uncertainty of selected points
%   side_idx      (array[n_select):  indices of selected points
%   figid         (handle):          figure handle showing selected points

%default input
if nargin < 2; side_name=''; end

%prompt message
fprintf('Select points for side %s (close polygon or press enter to exit, rigth click to remove)\n',side_name)
%initalize coodinates
x_reg = [];
y_reg = [];
iter = 0;

%create figure
figid = plot_profile(data);
title({sprintf('Select points for side %s:',side_name),'(close polygon or press enter to exit, rigth click to remove)'})

%select region
while true
    %record point
    [x,y,button] = ginput(1);

    %exit
    if isempty(button) || (iter > 1 && norm([x-x_reg(1,:),y-y_reg(1)]) < 1)
        break
    end

    %button options
    if button == 1     %add new point
        x_reg = [x_reg;x];
        y_reg = [y_reg;y];
        iter  = iter + 1;
    elseif button == 3 %remove point
        [d_min,i_rm] = min(vecnorm([x_reg,y_reg]-[x,y],2,2));
        if d_min < 50
            x_reg = x_reg(1:end~=i_rm);
            y_reg = y_reg(1:end~=i_rm);
        end
        close(figid);
        %create new figure
        figid = plot_profile(data); 
        title(sprintf('Select points for side %s:',side_name))
    end

    %plot selection boundary
    figure(figid); 
    plot(x_reg,y_reg,'k--o');
end

%handle special cases:
%   insufficient points
%   rectangular box
if length(x_reg) < 2
    error('Insufficient number of points')
elseif length(x_reg) == 2
    x_reg = [x_reg(1),x_reg(2),x_reg(2),x_reg(1)]';
    y_reg = [y_reg(1),y_reg(1),y_reg(2),y_reg(2)]';
end

%indicies of selected data
i_in = inpolygon(data(:,1),data(:,2),x_reg,y_reg);
side_idx = find(i_in);

%selected data
data_selected = data(i_in,:);

%plot closed polygon and selected points
figure(figid);
plot([x_reg;x_reg(1)],[y_reg;y_reg(1)],'k--o');
figid = plot_points_select(data_selected,figid);

end