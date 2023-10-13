function [figid] = plot_points_select(data_select,figid,color,linestyle)
% Plot selected points

%default
if nargin < 2; figid     = plot_profile(data_select); end
if nargin < 3; color     = "#0072BD";                 end
if nargin < 4; linestyle = 'o';                       end

%plot closed polygon and selected points
figure(figid);
plot(data_select(:,1),data_select(:,2),linestyle,'Color',color,'MarkerSize',15,'LineWidth',2)

end