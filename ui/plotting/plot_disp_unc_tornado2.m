function [figid] = plot_disp_unc_tornado2(disp_data,names_data,q4eval,q2plot,color)
% Tornado plot on given quantiles

%default inputs
if nargin < 3; q4eval = [0.16, 0.84]; end
if nargin < 4; q2plot = [0.02, 0.16, 0.84, 0.98]; end
if nargin < 5; color  = "#000000"; end %"#0072BD"

%check input for consistency
assert(length(q4eval)==2,'Error. Incorrect number of quantiles for ranking.')
q4eval = sort(q4eval);
assert(length(q2plot)==4,'Error. Incorrect number of quantiles for tronado plots.')
q2plot = sort(q2plot);

%initialize disp 
dmed   = nan(length(disp_data),1);
dmean  = nan(length(disp_data),1);
d2plot = nan(length(disp_data),length(q2plot));
%initialize disp range
dr4eval = nan(length(disp_data),1);

%number of diplacement sets
n_d = length(disp_data);

%iterate over datasets
for j = 1:n_d
    %displacement range
    dr4eval(j) = diff( quantile(disp_data{j},q4eval) );
    %displacement quantiles
    dmed(j)     = median(disp_data{j});
    dmean(j)    = mean(disp_data{j});
    d2plot(j,:) = quantile(disp_data{j}, q2plot);
end

%rank displacement range components
[~,i_rnk] = sort(dr4eval, 'ascend');

%displacement range to plot
dr2plot = abs(d2plot-dmed);

%initialize legend names
lg = {};
% tornado plot
figid = figure;
% q1-q4 range
lg{1} = sprintf('Percentile: %3.i - %3.i',100*q2plot(1),100*q2plot(4));
hl_r1   = errorbar(dmed(i_rnk),1:n_d,dr2plot(i_rnk,1),dr2plot(i_rnk,4),...
                   'horizontal','LineWidth',2,'CapSize',20,'LineStyle','none','Color',color); hold on
hl_r1.Bar.LineStyle = 'dashed';
% q2-q3 range
lg{2} = sprintf('Percentile: %3.i - %3.i',100*q2plot(2),100*q2plot(3));
hl_r2   = errorbar(dmed(i_rnk),1:n_d,dr2plot(i_rnk,2),dr2plot(i_rnk,3),...
                   'horizontal','LineWidth',2,'CapSize',40,'LineStyle','none','Color',color);
% median
lg{3} = 'Median';
hl_mean = plot(dmed(i_rnk),  1:n_d, 's','MarkerSize',12,'Color',color,'MarkerFaceColor',color);
% mean
lg{4} = 'Mean';
hl_med  = plot(dmean(i_rnk), 1:n_d, 'd','MarkerSize',15,'Color',color,'MarkerFaceColor',color);
grid on
% figure properties
legend([hl_mean,hl_med,hl_r2,hl_r1],fliplr(lg),'location','southeast')
yticks(1:n_d)
ylim([0,n_d+1])
yticklabels(names_data(i_rnk))
xlabel('Displacment (m)')

end