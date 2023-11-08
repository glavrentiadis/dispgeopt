function [disp_net,disp_horiz,disp_vert,apert_width,df_summary] = analysis_probabilistic(prof_name,fname_prof_main,data,dir_out,dir_fig)
% Perform probabilistic analysis determining slip diplacement

%sampling option
flag_samp = input_uncertainty_opt();

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
pause(1); close(figid);

%projection points sampling info
if flag_samp(1); samp_p = input_probsamp();
else             samp_p = [1,1];
end

%projection window size
if flag_samp(2)
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

%determine rupture location
[flag_rup_pt] = listdlg('ListString',{'Manual','Auto'}, ...
                        'PromptString','Determine rupture location:','Name','Rupture Location', ...
                        'SelectionMode','single','ListSize',[250,100]);
switch flag_rup_pt
    case 1 %manual
        [rup_loc_mean,rup_zone_lim,rup_ax,figid] = determine_rup_manual(data,prj1_data,prj2_data);
    case 2 %automatic
        [rup_loc_mean,rup_zone_lim,rup_ax,figid] = determine_rup_auto(data,prj1_data,prj2_data);
end
%plot rupture location
title('Rupture location')
saveas(figid,[dir_fig,fname_prof_main,'_rup_loc','.png'])
pause(1); close(figid);

%ruptue location uncertainty
if flag_samp(2); [rup_loc_std,rup_ax_ratio] = input_rupture_loc_unc(false)
end

%azimuth angle uncertainty
[rup_azmth_mean,rup_azmth_std] = input_rupture_azmth(flag_samp(6));

%principal rupture axis
rup_ax      = axis_rot(-deg2rad(rup_azmth_mean));
rup_ax(:,1) = rup_ax_ratio * rup_ax(:,1);
rup_ax      =  sqrt(2)/norm(rup_ax) * rup_ax;

%inialize data frames
%displacement values
disp_net   = nan(n_samp,1);
disp_horiz = nan(n_samp,1);
disp_vert  = nan(n_samp,1);
%point subset
i_s1 = cell(n_samp,1);
i_s2 = cell(n_samp,1);
%rupture point and azimuth
rup_pt_samp    = nan(n_samp,2);
rup_azmth_samp = nan(n_samp,1);
%projection points
prj1_pt = nan(n_samp,3);
prj2_pt = nan(n_samp,3);
%projection functions
prj1_fun = cell(n_samp,1);
prj2_fun = cell(n_samp,1);
%aperture width
apert_width  = nan(n_samp,1);
%aperture points
apert_pt  = nan(n_samp,4);

%uncertainty sampler
for j = 1:n_samp
    if ~mod(j,1000); fprintf('Processing iteration %i of %i ...\n',j,n_samp); end
    %sampling
    [prj1_samp, prj2_samp, rup_pt_samp(j,:), rup_azmth_samp(j), i_s1{j}, i_s2{j}]  = sample_unc_mc(flag_samp,prj1_data,prj2_data, ...
                                                                                                   rup_loc_mean,rup_loc_std, ...
                                                                                                   rup_azmth_mean,rup_azmth_std, ...
                                                                                                   samp_p,winsize_info);
    
    %compute projection;
    [prj1_c,prj1_v,~,~,prj1_fun{j}] = projection_fit(prj1_samp); 
    [prj2_c,prj2_v,~,~,prj2_fun{j}] = projection_fit(prj2_samp);
    %rotate second side projection if points in oposite direction
    if dot(prj1_v,prj2_v) < 0; prj2_v =-1*prj2_v; end
    %average projecton
    prj_c = mean([prj1_c,prj2_c],2);
    prj_v = mean([prj1_v,prj2_v],2); 

    %determine intersection points
    prj1_pt(j,:) = intersect_projection(prj1_c,prj1_v,rup_pt_samp(j,:)',rup_azmth_samp(j));
    prj2_pt(j,:) = intersect_projection(prj2_c,prj2_v,rup_pt_samp(j,:)',rup_azmth_samp(j));

    %compute displacements
    disp_net(j)   = norm(prj1_pt(j,:)-prj2_pt(j,:));
    disp_horiz(j) = norm(prj1_pt(j,1:2)-prj2_pt(j,1:2));
    disp_vert(j)  = abs(prj1_pt(j,3)-prj2_pt(j,3));

    %compute apature width
    [apert_width(j),apert_pt(j,1:2),apert_pt(j,3:4)] = calc_aperture(prj1_samp, prj2_samp,prj_v,prj_c,rup_azmth_samp(j));

    %representative figures
    if mod(j,1000) == 0
        fname_prof_iter = sprintf('%s_iter_%i',fname_prof_main,j);

        %plot displacement measurement
        figid = plot_profile(data);
        [figid,hl1] = plot_points_select(prj1_samp,figid);
        [figid,hl2] = plot_points_select(prj2_samp,figid);
        %plot projection points
        [figid,hl3] = plot_prj_line(prj1_fun{j},figid);
        [figid,hl4] = plot_prj_line(prj2_fun{j},figid);
        hl5 = plot([prj1_pt(j,1),prj2_pt(j,1)],[prj1_pt(j,2),prj2_pt(j,2)],'-','Color',"#D95319",'LineWidth',2);
        title(sprintf('%s: Slip Measurement (iter: %i)',prof_name,j))
        legend([hl5,hl1,hl3],{'Slip Measurement','Selected Points','Projection Lines'},'Location','northeast')
        anot_txt = sprintf('Net:    %.2fm\nHoriz: %.2fm\nVert:   %.2fm',disp_net(j),disp_horiz(j),disp_vert(j));
        % text(prj2_pt(j,1)+2,prj2_pt(j,2)+2,anot_txt,'FontSize',12)
        annotation('textbox',[0.15,0.05,0.15,0.2],'String',anot_txt,'FitBoxToText','on','FontSize',12,'BackgroundColor','w','FaceAlpha',1);
        saveas(figid,[dir_fig,fname_prof_iter,'_slip_measurement','.png'])
        close(figid);
    
        %plot displacement aperture
        figid = plot_profile(data);
        [figid,hl1] = plot_points_select(prj1_data,figid);
        [figid,hl2] = plot_points_select(prj2_data,figid);
        %plot projection points
        [figid,hl3] = plot_prj_line(prj1_fun{j},figid);
        [figid,hl4] = plot_prj_line(prj2_fun{j},figid);
        hl5 = plot([prj1_pt(j,1),prj2_pt(j,1)],[prj1_pt(j,2),prj2_pt(j,2)],'-','Color',"#D95319",'LineWidth',2);
        apert_win2plot = [apert_win(:,1:2);flipud(apert_win(:,3:4));apert_win(1,1:2)];
        hl6 = plot(apert_win2plot(:,1), apert_win2plot(:,2),  ':','Color',[0 0.5 0],'LineWidth',3);
        title(sprintf('%s: Slip & Aperture (iter: %i)',prof_name,j))
        legend([hl5,hl6,hl1,hl3],{'Slip Measurement','Aperture','Selected Points','Projection Lines'},'Location','northeast')
        anot_txt = sprintf('Net:    %.2fm\nHoriz: %.2fm\nVert:   %.2fm\nApert: %.2fm',disp_net(j),disp_horiz(j),disp_vert(j),apert_width(j));
        % text(prj2_pt(j,1)+2,prj2_pt(j,2)+2,anot_txt,'FontSize',12)
        annotation('textbox',[0.15,0.08,0.15,0.2],'String',anot_txt,'FitBoxToText','on','FontSize',12,'BackgroundColor','w','FaceAlpha',1);
        saveas(figid,[dir_fig,fname_prof_iter,'_slip_aperture','.png'])
        close(figid);
    end
end
fprintf('Sampling complete.\n')


end
