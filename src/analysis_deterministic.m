function [disp_net,disp_horiz,disp_vert,df_summary] = analysis_deterministic(prof_name,fname_prof_main,data,dir_out,dir_fig)
% 

%number of iterations
prompt = {'Number of iterations:'};
dlgtitle = 'Deterministic Iterations';
dims = [1 35];
definput = {'1'}; % Default iterations
n_iter = inputdlg(prompt, dlgtitle, dims, definput);
n_iter = str2double(n_iter{1});

%initialize arrays
%displacement measurement
disp_net   = nan(n_iter,1);
disp_horiz = nan(n_iter,1);
disp_vert  = nan(n_iter,1);
%point subset
side1_idx = cell(n_iter,1);
side2_idx = cell(n_iter,1);
%rupture point and azimuth
rup_loc   = nan(n_iter,2);
rup_azmth = nan(n_iter,1);
%projection points
prj1_pt = nan(n_iter,3);
prj2_pt = nan(n_iter,3);

%iterate analyses
for j = 1:n_iter
    fprintf('%s: iteration %i of %i\n',prof_name,j,n_iter)
    fname_prof_iter = sprintf('%s_iter_%i',fname_prof_main,j);

    %select projection points
    [prj1_data,side1_idx{j},figid] = select_points_side(data,'A');
    pause(1); close(figid);
    [prj2_data,side2_idx{j},figid] = select_points_side(data,'B');
    pause(); close(figid);

    %figure selected points projections
    figid = plot_profile(data);
    [figid, hl1] = plot_points_select(prj1_data,figid,"#0072BD");
    [figid, hl2] = plot_points_select(prj2_data,figid,"#D95319");
    title(sprintf('%s: Selected projection points',prof_name))
    legend([hl1,hl2],{'Side A','Side B'},'Location','northeast')
    saveas(figid,[dir_fig,fname_prof_iter,'_select_points','.png'])
    pause(); close(figid);

    %select rupture point
    %method
    [flag_rup_pt] = listdlg('ListString',{'Manual','Auto'}, ...
                            'PromptString','Determine rupture location:','Name','Rupture Location', ...
                            'SelectionMode','single','ListSize',[250,100]);
    switch flag_rup_pt
        case 1 %manual
            [rup_loc(j,:),rup_zone_lim,rup_ax,figid] = determine_rup_manual(data,prj1_data,prj2_data);
        case 2 %automatic
            [rup_loc(j,:),rup_zone_lim,rup_ax,figid] = determine_rup_auto(data,prj1_data,prj2_data);
    end
    %plot rupture location
    title('Rupture location')
    saveas(figid,[dir_fig,fname_prof_iter,'_rup_loc','.png'])
    pause(); close(figid);

    %azimuth angle
    prompt = {'Enter rupture azimuth angle:'};
    dlgtitle = 'Azimuth Input';
    dims = [1 35];
    definput = {'45'}; % Default value for azimuth angle
    azimuth_input = inputdlg(prompt, dlgtitle, dims, definput);
    rup_azmth(j) = str2double(azimuth_input{1});

    %compute projection;
    [prj1_c,prj1_v,prj1_tlim,prj1_fun] = projection_fit(prj1_data(:,1:3)); 
    [prj2_c,prj2_v,prj2_tlim,prj2_fun] = projection_fit(prj2_data(:,1:3)); 
    
    %determine intersection points
    prj1_pt(j,:) = intersect_projection(prj1_c,prj1_v,rup_loc(j,:)',rup_azmth(j));
    prj2_pt(j,:) = intersect_projection(prj2_c,prj2_v,rup_loc(j,:)',rup_azmth(j));

    %compute slip
    disp_net(j)   = norm(prj1_pt(j,:)   - prj2_pt(j,:));
    disp_horiz(j) = norm(prj1_pt(j,1:2) - prj2_pt(j,1:2));
    disp_vert(j)  = norm(prj1_pt(j,3)   - prj2_pt(j,3));

    %plot displacement measurement
    figid = plot_profile(data);
    [figid,hl1] = plot_points_select(prj1_data,figid);
    [figid,hl2] = plot_points_select(prj2_data,figid);
    %plot projection points
    [figid,hl3] = plot_prj_line(prj1_fun,figid);
    [figid,hl4] = plot_prj_line(prj2_fun,figid);
    hl5 = plot([prj1_pt(j,1),prj2_pt(j,1)],[prj1_pt(j,2),prj2_pt(j,2)],'-','Color',"#D95319",'LineWidth',2);
    title(sprintf('%s: Slip Measurement',prof_name))
    legend([hl5,hl1,hl3],{'Slip Measurement','Selected Points','Projection Lines'},'Location','northeast')
    saveas(figid,[dir_fig,fname_prof_iter,'_slip_measurement','.png'])
    pause(); close(figid);
end

%displacement measurement summary
df_summary = array2table([disp_net,disp_horiz,disp_vert,rup_loc,rup_azmth,prj1_pt,prj2_pt], ...
                         'VariableNames', ...
                         {'disp_net','disp_horiz','disp_vert', ...
                          'rup_loc_X','rup_loc_Y','rup_azmth', ...
                          'prj1_pt_X','prj1_pt_Y','prj1_pt_Z',...
                          'prj2_pt_X','prj2_pt_Y','prj2_pt_Z'});
writetable(df_summary,[dir_out,fname_prof_main,'_summary_iterations','.csv'])


end