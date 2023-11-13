function [names_samp,disp_net,disp_horiz,disp_vert,apert_width,df_summary,fname_prof_main,rank_unc_idx] = ...
            analysis_uncrtquantification(prof_name,fname_prof_main,data,dir_out,dir_fig)
% Perform component uncertainty analysis

%profile and analysis name
fname_prof_main = sprintf('%s_analysis_uq',fname_prof_main);

%sampling option
[flag_samp, names_samp, names_samp_all] = input_uncertainty_opt();
%sample individual components
flag_samp_cmp = diag(flag_samp);
%reduce to invalid options
flag_samp_cmp = flag_samp_cmp(any(flag_samp_cmp,2) ,:);

%number of sampling components
n_samp_cmp = length(flag_samp_cmp);
%number of samples
n_samp = input_nsamples();

%select projection points
[prj1_data,side1_idx,figid] = select_points_side(data,'A');
pause(1); close(figid);
[prj2_data,side2_idx,figid] = select_points_side(data,'B');
pause(1); close(figid);
%figure selected points projections
figid = plot_profile(data);
[figid, hl1] = plot_points_select(prj1_data,figid,"#0072BD");
[figid, hl2] = plot_points_select(prj2_data,figid,"#D95319");
title(sprintf('%s: Selected projection points',prof_name))
legend([hl1,hl2],{'Side A','Side B'},'Location','northeast')
saveas(figid,[dir_fig,fname_prof_main,'_select_points','.png'])
savefig(figid,[dir_fig,fname_prof_main,'_select_points','.fig'])
pause(1); close(figid);

%projection window size
if flag_samp(1)
    winsize_info = input_prjwinsize();
    %compute along projection distance
    [~,~,t1_array,~,~] = projection_fit(prj1_data(:,1:2));
    [~,~,t2_array,~,~] = projection_fit(prj2_data(:,1:2));
    prj1_data(:,6) = t1_array - min(t1_array);
    prj2_data(:,6) = t2_array - min(t2_array);
else
    winsize_info = [inf, 0];
    prj1_data(:,6) = nan;
    prj2_data(:,6) = nan;
end

%projection points sampling info
if flag_samp(2); samp_p = input_probsamp();
else             samp_p = [1,1];
end

%azimuth angle uncertainty
[rup_azmth_mean,rup_azmth_std] = input_rupture_azmth(flag_samp(6));

 %select rupture location
[rup_loc_mean,rup_zone_lim,rup_ax,figid] = select_rup(data,prj1_data,prj2_data,rup_azmth_mean);
%plot rupture location
title(sprintf('%s: Rupture location (mean)',prof_name))
saveas(figid,[dir_fig,fname_prof_main,'_rup_loc','.png'])
savefig(figid,[dir_fig,fname_prof_main,'_rup_loc','.fig'])
pause(1); close(figid);

%ruptue location uncertainty
if flag_samp(5); [rup_loc_std,rup_ax_ratio] = input_rupture_loc_unc(false);
else;              rup_loc_std=nan; rup_ax_ratio=1;
end

%principal rupture axis
rup_ax      = axis_rot(-deg2rad(rup_azmth_mean));
rup_ax(:,1) = rup_ax_ratio * rup_ax(:,1);
rup_ax      =  sqrt(2)/norm(rup_ax) * rup_ax;

%inialize data frames (lower level)
%displacement values
disp_net = cell(n_samp_cmp,1); disp_horiz = cell(n_samp_cmp,1); disp_vert = cell(n_samp_cmp,1);
%point subset
i_s1 = cell(n_samp_cmp,1); i_s2 = cell(n_samp_cmp,1);
%rupture point and azimuth
rup_pt_samp = cell(n_samp_cmp,1); rup_azmth_samp = cell(n_samp_cmp,1);
%sampled geolocated points
prj1_samp = cell(n_samp_cmp,1); prj2_samp = cell(n_samp_cmp,1);
%projection points
prj1_pt = cell(n_samp_cmp,1); prj2_pt = cell(n_samp_cmp,3);
%projection functions
prj1_fun = cell(n_samp_cmp,1); prj2_fun = cell(n_samp_cmp,1);
%aperture width
apert_width  = cell(n_samp_cmp,1); apert1_width = cell(n_samp_cmp,1); apert2_width = cell(n_samp_cmp,1);
%aperture points
apert_pt  = cell(n_samp_cmp,1); apert1_pt = cell(n_samp_cmp,1); apert2_pt = cell(n_samp_cmp,1);

%displacement sumamry dataframes
df_summary = cell(n_samp_cmp,1);

%iterate sampling components
for c = 1:size(flag_samp_cmp,2)
    %sampling component
    flag_samp_c = flag_samp_cmp(c,:);
    %second level initialization
    %displacement values
    disp_net{c}   = nan(n_samp,1);
    disp_horiz{c} = nan(n_samp,1);
    disp_vert{c}  = nan(n_samp,1);
    %point subset
    i_s1{c} = cell(n_samp,1);
    i_s2{c} = cell(n_samp,1);
    %rupture point and azimuth
    rup_pt_samp{c}    = nan(n_samp,2);
    rup_azmth_samp{c} = nan(n_samp,1);
    %sampled geolocated points
    prj1_samp{c} = cell(n_samp,1);
    prj2_samp{c} = cell(n_samp,1);
    %projection points
    prj1_pt{c} = nan(n_samp,3);
    prj2_pt{c} = nan(n_samp,3);
    %projection functions
    prj1_fun{c} = cell(n_samp,1);
    prj2_fun{c} = cell(n_samp,1);
    %aperture width
    apert_width{c}  = nan(n_samp,1);
    apert1_width{c} = nan(n_samp,1);
    apert2_width{c} = nan(n_samp,1);
    %aperture points
    apert_pt{c}  = nan(n_samp,4);
    apert1_pt{c} = nan(n_samp,4);
    apert2_pt{c} = nan(n_samp,4);

    %iterate sampler
    fprintf('Start sampling for: %s uncertainty.\n',names_samp{c})
    %filename sampler
    fname_prof_samp = sprintf('%s_samp_%s',fname_prof_main,strrep( lower(names_samp{c}), ' ', '_') );
    title_samp = sprintf('Sampling: %s',names_samp{c});
    %uncertainty sampler
    jj = 1;
    for j = 1:n_samp
        if ~mod(j,1000); fprintf('Processing iteration %i of %i ...\n',j,n_samp); end
        %sampling
        [prj1_samp{c}{j}, prj2_samp{c}{j}, rup_pt_samp{c}(j,:), rup_azmth_samp{c}(j), i_s1{c}{j}, i_s2{c}{j}]  = sample_unc_mc(flag_samp_c,prj1_data,prj2_data, ...
                                                                                                                               rup_loc_mean,rup_loc_std, ...
                                                                                                                               rup_azmth_mean,rup_azmth_std, ...
                                                                                                                               samp_p,winsize_info, ...
                                                                                                                               rup_ax,rup_zone_lim);
    
        %compute projection;
        [prj1_c,prj1_v,~,~,prj1_fun{c}{j}] = projection_fit(prj1_samp{c}{j}); 
        [prj2_c,prj2_v,~,~,prj2_fun{c}{j}] = projection_fit(prj2_samp{c}{j});
        %rotate second side projection if points in oposite direction
        if dot(prj1_v,prj2_v) < 0; prj2_v =-1*prj2_v; end
        %average projecton
        prj_c = mean([prj1_c,prj2_c],2);
        prj_v = mean([prj1_v,prj2_v],2); 

        %determine intersection points
        prj1_pt{c}(j,:) = intersect_projection(prj1_c,prj1_v,rup_pt_samp{c}(j,:)',rup_azmth_samp{c}(j));
        prj2_pt{c}(j,:) = intersect_projection(prj2_c,prj2_v,rup_pt_samp{c}(j,:)',rup_azmth_samp{c}(j));

        %compute displacements
        disp_net{c}(j)   = norm(prj1_pt{c}(j,:)-prj2_pt{c}(j,:));
        disp_horiz{c}(j) = norm(prj1_pt{c}(j,1:2)-prj2_pt{c}(j,1:2));
        disp_vert{c}(j)  = abs(prj1_pt{c}(j,3)-prj2_pt{c}(j,3));

        %compute apature width
        [apert_width{c}(j),apert_pt{c}(j,1:2),apert_pt{c}(j,3:4)]    = calc_aperture(prj1_samp{c}{j},prj2_samp{c}{j},prj_v,prj_c,rup_azmth_samp{c}(j));
        [apert1_width{c}(j),apert1_pt{c}(j,1:2),apert1_pt{c}(j,3:4)] = calc_aperture(prj1_samp{c}{j},prj2_samp{c}{j},prj1_v,prj1_c,rup_azmth_samp{c}(j));
        [apert2_width{c}(j),apert2_pt{c}(j,1:2),apert2_pt{c}(j,3:4)] = calc_aperture(prj1_samp{c}{j},prj2_samp{c}{j},prj2_v,prj2_c,rup_azmth_samp{c}(j));
        apert_win = [apert1_pt{c}(j,:);apert_pt{c}(j,:);apert2_pt{c}(j,:)];

        %representative figures
        if mod(j,10^round(log10(n_samp/10))) == 0
            jj = jj + 1;
            fname_prof_iter = sprintf('%s_iter_%i',fname_prof_samp,jj);
    
            %plot displacement measurement
            figid = plot_profile(data);
            [figid,hl1] = plot_points_select(prj1_samp{c}{j},figid);
            [figid,hl2] = plot_points_select(prj2_samp{c}{j},figid);
            %plot projection points
            [figid,hl3] = plot_prj_line(prj1_fun{c}{j},figid);
            [figid,hl4] = plot_prj_line(prj2_fun{c}{j},figid);
            hl5 = plot([prj1_pt{c}(j,1),prj2_pt{c}(j,1)],[prj1_pt{c}(j,2),prj2_pt{c}(j,2)],'-','Color',"#D95319",'LineWidth',2);
            title({sprintf('%s: Slip Measurement (iter: %i)',prof_name,j),title_samp})
            legend([hl5,hl1,hl3],{'Slip Measurement','Selected Points','Projection Lines'},'Location','northeast')
            anot_txt = sprintf('Net:    %.2fm\nHoriz: %.2fm\nVert:   %.2fm',disp_net{c}(j),disp_horiz{c}(j),disp_vert{c}(j));
            % text(prj2_pt(j,1)+2,prj2_pt(j,2)+2,anot_txt,'FontSize',12)
            annotation('textbox',[0.15,0.05,0.15,0.2],'String',anot_txt,'FitBoxToText','on','FontSize',12,'BackgroundColor','w','FaceAlpha',1);
            saveas(figid,[dir_fig,fname_prof_iter,'_slip_measurement','.png'])
            savefig(figid,[dir_fig,fname_prof_iter,'_slip_measurement','.fig'])
            close(figid);
        
            %plot displacement aperture
            figid = plot_profile(data);
            [figid,hl1] = plot_points_select(prj1_samp{c}{j},figid);
            [figid,hl2] = plot_points_select(prj2_samp{c}{j},figid);
            %plot projection points
            [figid,hl3] = plot_prj_line(prj1_fun{c}{j},figid);
            [figid,hl4] = plot_prj_line(prj2_fun{c}{j},figid);
            hl5 = plot([prj1_pt{c}(j,1),prj2_pt{c}(j,1)],[prj1_pt{c}(j,2),prj2_pt{c}(j,2)],'-','Color',"#D95319",'LineWidth',2);
            apert_win2plot = [apert_win(:,1:2);flipud(apert_win(:,3:4));apert_win(1,1:2)];
            hl6 = plot(apert_win2plot(:,1), apert_win2plot(:,2),  ':','Color',[0 0.5 0],'LineWidth',3);
            title({sprintf('%s: Slip & Aperture (iter: %i)',prof_name,j),title_samp})
            legend([hl5,hl6,hl1,hl3],{'Slip Measurement','Aperture','Selected Points','Projection Lines'},'Location','northeast')
            anot_txt = sprintf('Net:    %.2fm\nHoriz: %.2fm\nVert:   %.2fm\nApert: %.2fm',disp_net{c}(j),disp_horiz{c}(j),disp_vert{c}(j),apert_width{c}(j));
            % text(prj2_pt(j,1)+2,prj2_pt(j,2)+2,anot_txt,'FontSize',12)
            annotation('textbox',[0.15,0.08,0.15,0.2],'String',anot_txt,'FitBoxToText','on','FontSize',12,'BackgroundColor','w','FaceAlpha',1);
            saveas(figid,[dir_fig,fname_prof_iter,'_slip_aperture','.png'])
            savefig(figid,[dir_fig,fname_prof_iter,'_slip_aperture','.fig'])
            close(figid);
        end
    end

    %quantiles (net displacement)
    q = (1:length(disp_net{c}))'/length(disp_net{c});
    [~, i_q] = sort(disp_net{c});
    %selected quantiles
    [~, i_q50] = min( abs(q-0.50) ); i_q50 = i_q(i_q50);

    %plot percentile range 
    quantiles = {[0.02,0.98],0.50};
    color     = {"#77AC30","#0072BD"}; 
    [figid,hl1,hl2] = plot_profile_disp_quantile_range(disp_net{c},data,prj1_fun{c},prj2_fun{c},prj1_pt{c},prj2_pt{c},quantiles,color);
    legend(fliplr(hl1),{'Median Net Displacement','2-98% Percentile Net Displacement'})
    title({sprintf('%s: Uncertainty Range',prof_name),title_samp})
    saveas(figid,[dir_fig,fname_prof_samp,'_qantile_samp','.png'])
    savefig(figid,[dir_fig,fname_prof_samp,'_qantile_samp','.fig'])
    pause(1); close(figid);
    
    %plot rupture location sampling
    [figid,hl1] = plot_profile_rupture_loc(data,rup_pt_samp{c},prj1_pt{c}(i_q50,:),prj2_pt{c}(i_q50,:), ...
                                           prj1_data,prj2_data,prj1_fun{c}{i_q50},prj2_fun{c}{i_q50});
    if isempty(rup_zone_lim)
        legend([hl1],{'Rupture Location Samples'})
    else
        hl2 = plot(rup_zone_lim(:,1),rup_zone_lim(:,2),':','LineWidth',3);
        legend([hl1,hl2],{'Rupture Location Samples','Rupture Zone'})
    end
    title({sprintf('%s: Rupture Location Uncertainty',prof_name),title_samp})
    saveas(figid,[dir_fig,fname_prof_samp,'_rup_loc_samp','.png'])
    savefig(figid,[dir_fig,fname_prof_samp,'_rup_loc_samp','.fig'])
    pause(1); close(figid);
    
    %plot projection point sampling
    [figid,hl1,~] = plot_profile_samp_pt_loc(data,prj1_samp{c},prj2_samp{c},prj1_pt{c}(i_q50,:),prj2_pt{c}(i_q50,:), ...
                                           prj1_data,prj2_data,prj1_fun{c}{i_q50},prj2_fun{c}{i_q50});
    legend(hl1,{'Projection Points Location Samples'})
    title({sprintf('%s: Projection Points Location Uncertainty',prof_name),title_samp})
    saveas(figid,[dir_fig,fname_prof_samp,'_prj_pt_samp','.png'])
    savefig(figid,[dir_fig,fname_prof_samp,'_prj_pt_samp','.fig'])
    pause(1); close(figid);

    %displacement measurement summary
    df_summary{c} = array2table([(1:n_samp)', ...
                                disp_net{c},disp_horiz{c},disp_vert{c},...
                                apert_width{c},apert1_width{c},apert2_width{c}, ...
                                rup_pt_samp{c},rup_azmth_samp{c},prj1_pt{c},prj2_pt{c}], ...
                                'VariableNames', ...
                                {'samp', ...
                                 'disp_net','disp_horiz','disp_vert', ...
                                 'apert_width_cent','apert_width_sideA','apert_width_sideB', ...
                                 'rup_loc_X','rup_loc_Y','rup_azmth', ...
                                 'prj_pt_sideA_X','prj_pt_sideA_Y','prj_pt_sideA_Z',...
                                 'prj_pt_sideB_X','prj_pt_sideB_Y','prj_pt_sideB_Z'});
    writetable(df_summary{c},[dir_out,fname_prof_samp,'_summary_iterations','.csv'])
end


%tornado plots
%net displacements
figid = plot_disp_unc_tornado(disp_net,names_samp);
title({sprintf('%s: %s',prof_name,'Net Displacement'),'Compnent Sensitivity'})
saveas(figid,[dir_fig,fname_prof_main,'_slip_sensitivity_tornado','_net_disp','.png'])
savefig(figid,[dir_fig,fname_prof_main,'_slip_sensitivity_tornado','_net_disp','.fig'])
pause(2); close(figid);

[figid,rank_unc_idx] = plot_disp_unc_tornado2(disp_net,names_samp,[0.25,0.75],[0.02,0.25,0.75,0.98]);
title({sprintf('%s: %s',prof_name,'Net Displacement'),'Compnent Sensitivity'})
saveas(figid,[dir_fig,fname_prof_main,'_slip_sensitivity_tornado2','_net_disp','.png'])
savefig(figid,[dir_fig,fname_prof_main,'_slip_sensitivity_tornado2','_net_disp','.fig'])
pause(2); close(figid);

%horizontal displacements
figid = plot_disp_unc_tornado(disp_net,names_samp);
title({sprintf('%s: %s',prof_name,'Horizontal Displacement'),'Compnent Sensitivity'})
saveas(figid,[dir_fig,fname_prof_main,'_slip_sensitivity_tornado','_horiz_disp','.png'])
savefig(figid,[dir_fig,fname_prof_main,'_slip_sensitivity_tornado','_horiz_disp','.fig'])
pause(2); close(figid);

figid = plot_disp_unc_tornado2(disp_net,names_samp,[0.25,0.75],[0.02,0.25,0.75,0.98]);
title({sprintf('%s: %s',prof_name,'Horizontal Displacement'),'Compnent Sensitivity'})
saveas(figid,[dir_fig,fname_prof_main,'_slip_sensitivity_tornado2','_horiz_disp','.png'])
savefig(figid,[dir_fig,fname_prof_main,'_slip_sensitivity_tornado2','_horiz_disp','.fig'])
pause(2); close(figid);

%summary input
df_inpt = array2table([samp_p',winsize_info',rup_azmth_mean,rup_azmth_std,rup_loc_std,rup_ax_ratio], ...
                      'VariableNames', ...
                      {'p_samp_sideA','p_samp_sideB','win_size_mean','win_size_std',...
                      'rup_azmth_mean','rup_azmth_std','rup_loc_std','rup_ax_ratio'});
%add component uncertainty information
names_samp_all = strrep(lower(names_samp_all),' ','_');
df_inpt{1,names_samp_all} = flag_samp;
writetable(df_inpt,[dir_out,fname_prof_main,'_summary_input_param','.csv'])

end
