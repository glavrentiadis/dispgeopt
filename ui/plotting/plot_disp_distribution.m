function [figid] = plot_disp_distribution(disp_array,fig_title)
%Plot PDF and CDF of displacement distribution

%distribution fit
%normal distribution;
d_norm_fit = [mean(disp_array), std(disp_array)];
%gamma distribution
d_gamma_fit = gamfit(disp_array);

%empirical distribution
[e_cdf, e_x] = ecdf(disp_array);

%range
x = linspace(min(e_x),max(e_x), 500);

%plot uncertainty 
figid = figure;
%cdf comparison
subplot(1,2,2)
plot(e_x,e_cdf,  'LineWidth',3,'Color',"k"); hold on;
plot(x, normcdf(x,d_norm_fit(1),d_norm_fit(2)),  'LineWidth',2,'Color',"#0072BD")
plot(x, gamcdf(x,d_gamma_fit(1),d_gamma_fit(2)), 'LineWidth',2,'Color',"#D95319")
grid on
xlabel('Displacment (m)')
ylabel('CDF')
xlims = xlim();
if d_norm_fit(2) < 0.1; xlims = round(max(d_norm_fit(1) + [-.5, 0.5], 0), 1);
end
xlim(xlims)
%pdf comparison
subplot(1,2,1)
histogram(disp_array,'Normalization','pdf','FaceColor','k','FaceAlpha',0.1); hold on
plot(x, normpdf(x,d_norm_fit(1),d_norm_fit(2)),  'LineWidth',2,'Color',"#0072BD")
plot(x, gampdf(x,d_gamma_fit(1),d_gamma_fit(2)), 'LineWidth',2,'Color',"#D95319")
grid on
xlabel('Displacment (m)')
ylabel('PDF')
xlim(xlims);
%legend
subplot(1,2,2)
legend({'Empirical','Normal','Gamma'},'Location','southeast')
%main figure title
sgtitle(fig_title) 

end