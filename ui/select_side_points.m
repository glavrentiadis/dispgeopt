function [data_selected,figid] = select_side_points(data, side_name, figid)
%UI for selecting points for each side
%
% Input Arguments:
%   data (mat[n_select,5]): geolocated points 
%   figid (handle): figure handle for geolocated points 
%   side_name (string): name for side to select points
%
% Output Arguments:
%   data_selected (mat[n_select,5]): coordinates and uncertainty of selected points

%default input
if nargin < 2; side_name=''; end
if nargin < 3
    figid = plot_profile(data);
end


%prompt message
fprintf('Select points for side %s (enter to exit, rigth click to remove)\n',side_name)
%initalize coodinates
x_reg = [];
y_reg = [];
iter = 0;
%select region
while true
    %record point
    [x,y,button] = ginput(1);

    %button options
    if button == 1
        x_reg = [x_reg;x];
        y_reg = [y_reg;y];
        iter  = iter + 1;
    elseif button == 3;
        [d_min,i_rm] = min(vecnorm([x_reg,y_reg]-[x,y],2,2));
        if d_min < 50
            x_reg = x_reg(1:end~=i_rm);
            y_reg = y_reg(1:end~=i_rm);
        end
    elseif isempty(button)
        break
    end

    %plot selection boundary
    if iter > 2;
        figure(figid); 
        plot(x_reg,y_reg,'k--o');
    end
end

%handle special cases:
%   insufficient points
%   rectangular box
if length(x_reg) < 2
    error('Insufficient number of points')
elseif length(x_reg) == 2
    [x_reg,y_reg] = meshgrid(x_reg,y_reg);
    x_reg = reshape(x_reg,1,[]);
    y_reg = reshape(y_reg,1,[]);
end

%indicies of selected data
i_in = inpolygon(data(:,1),data(:,2),x_reg,y_reg);

%selected data
data_selected = data(i_in,:);

%plot closed polygon and selected points
figure(figid);
plot([x_reg;x_reg(1)],[y_reg;y_reg(1)],'k--o');
plot(data_selected(:,1),data_selected(:,2),'-o','Color',"#0072BD",'MarkerSize',15);


end