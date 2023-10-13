function [figid] = plot_prj_line_range(fun_prj1,fun_prj2,figid,color)
% Plot projection range

%default inputs
if nargin < 4; color="#D95319"; end

%projection trace
prj_trace1 = fun_prj1([-500,500]);
prj_trace2 = fun_prj2([-500,500]);
%projection polygon
prj_trace = [prj_trace1;flipud(prj_trace2);prj_trace1(1,:)];

%plot projection range
figure(figid);
fill(prj_trace(:,1),prj_trace(:,2),1,...
     'EdgeColor',color,'LineStyle','--','LineWidth',1.5,'FaceAlpha',0.3,'FaceColor',color)

end