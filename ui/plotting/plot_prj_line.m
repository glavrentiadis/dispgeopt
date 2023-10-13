function [figid] = plot_prj_line(fun_prj,figid,color)
% Plot projection trace

%default inputs
if nargin < 3; color="#D95319"; end

%projection trace
prj_trace = fun_prj([-500,500]);
%plot points
figure(figid);
plot(prj_trace(:,1),prj_trace(:,2),'--','Color',color,'LineWidth',1.5);

end