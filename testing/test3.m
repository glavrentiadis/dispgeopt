%test3
% evaluate tornado uncertainty

clear; clc; 
close all

addpath('./../src/')
addpath('./../src/sampling/')
addpath('./../ui/')
addpath('./../ui/plotting')


%load file
[data,prof_name] = open_profile();

%plot data
figid = plot_profile(data);
%select edge points
[prj1_data,figid] = select_points_side(data,'A',figid);
[prj2_data,figid] = select_points_side(data,'B',figid);

%select rupture point
disp('Select rupture center point (left-click to select).');
rup_loc_mean = zeros(2,1);
[rup_loc_mean(1), rup_loc_mean(2)] = ginput(1); % User selects the center point for Line 3
%azimuth angle and uncertainty
[rup_azmth_mean,rup_azmth_std,rup_loc_std] = input_rupture(true);
close(figid)

%number of samples
dlgtitle = 'Sampling info';
prompt = {'Number of samples:';'Sampling probability (side A):';'Sampling probability (side B):'};
dims = [1 35; 1 35; 1 35];
definput = {'10000';'0.8';'0.8'};
samp_info = inputdlg(prompt, dlgtitle, dims, definput);
samp_n = str2double(samp_info{1});
samp_p = cellfun(@(x) str2double(x), samp_info(2:3));

%sampling option
[flag_samp_cmp, names_samp_cmp] = input_uncertainty_opt();
%sample individual components
flag_samp_cmp = diag(flag_samp_cmp);
%reduce to invalid options
flag_samp_cmp = flag_samp_cmp(any(flag_samp_cmp,2) ,:);

%number of sampling components
n_samp_cmp = length(flag_samp_cmp);

%first level initialization
%displacement values
disp_net = cell(n_samp_cmp,1); disp_horiz = cell(n_samp_cmp,1); disp_vert = cell(n_samp_cmp,1);
%point subset
i_s1 = cell(n_samp_cmp,1); i_s2 = cell(n_samp_cmp,1);
%rupture point and azimuth
rup_pt_samp = cell(n_samp_cmp,1); rup_azmth_samp = cell(n_samp_cmp,1);
%projection points
prj1_pt = cell(n_samp_cmp,1); prj2_pt = cell(n_samp_cmp,3);
%projection functions
prj1_fun = cell(n_samp_cmp,1); prj2_fun = cell(n_samp_cmp,1);


%iterate sampling components
for c = 1:size(flag_samp_cmp,2)
    %sampling component
    flag_samp_c = flag_samp_cmp(c,:);
    %second level initialization
    %displacement values
    disp_net{c}   = nan(samp_n,1);
    disp_horiz{c} = nan(samp_n,1);
    disp_vert{c}  = nan(samp_n,1);
    %point subset
    i_s1{c} = cell(samp_n,1);
    i_s2{c} = cell(samp_n,1);
    %rupture point and azimuth
    rup_pt_samp{c}    = nan(samp_n,2);
    rup_azmth_samp{c} = nan(samp_n,1);
    %projection points
    prj1_pt{c} = nan(samp_n,3);
    prj2_pt{c} = nan(samp_n,3);
    %projection functions
    prj1_fun{c} = cell(samp_n,1);
    prj2_fun{c} = cell(samp_n,1);

    %iterate sampler
    fprintf('Start sampling for: %s uncertainty.\n',names_samp_cmp{c})
    for k = 1:samp_n
        if ~mod(k,1000); fprintf('Processing iteration %i of %i ...\n',k,samp_n); end
        %sampling
        [prj1_samp, prj2_samp, rup_pt_samp{c}(k,:), rup_azmth_samp{c}(k), i_s1{c}{k}, i_s2{c}{k}]  = sample_unc_mc(flag_samp_c,prj1_data,prj2_data, ...
                                                                                                                   rup_loc_mean,rup_azmth_mean,rup_loc_std, ...
                                                                                                                   rup_azmth_std,nan,samp_p);
        
        %compute projection;
        [prj1_c,prj1_v,prj1_tlim,prj1_fun{c}{k}] = projection_fit(prj1_samp); 
        [prj2_c,prj2_v,prj2_tlim,prj2_fun{c}{k}] = projection_fit(prj2_samp); 
        
        %determine intersection points
        prj1_pt{c}(k,:) = intersect_projection(prj1_c,prj1_v,rup_pt_samp{c}(k,:)',rup_azmth_samp{c}(k));
        prj2_pt{c}(k,:) = intersect_projection(prj2_c,prj2_v,rup_pt_samp{c}(k,:)',rup_azmth_samp{c}(k));
    
        %compute displacements
        disp_net{c}(k)   = norm(prj1_pt{c}(k,:)-prj2_pt{c}(k,:));
        disp_horiz{c}(k) = norm(prj1_pt{c}(k,1:2)-prj2_pt{c}(k,1:2));
        disp_vert{c}(k)  = abs(prj1_pt{c}(k,3)-prj2_pt{c}(k,3));
    end
    fprintf('Sampling complete for %s.\n',names_samp_cmp{c})

    %quantiles
    q = (1:length(disp_net{c}))'/length(disp_net{c});
    %displacement quantile indices
    [~, i_q] = sort(disp_net{c});
    %selected quantiles
    [~, i_q50] = min( abs(q-0.50) ); i_q50 = i_q(i_q50);

    % distribution comparision
    % - - - - - - -
    %net displacement
    fig_title = {[prof_name,': net displacement'],['sampling: ',names_samp_cmp{c}]};
    figid = plot_disp_distribution(disp_net{c},fig_title);
    %horizontal displacement
    fig_title = {[prof_name,': horizontal displacement'],['sampling: ',names_samp_cmp{c}]};
    figid = plot_disp_distribution(disp_horiz{c},fig_title);
    %vertical displacement
    fig_title = {[prof_name,': vertical displacement'],['sampling: ',names_samp_cmp{c}]};
    figid = plot_disp_distribution(disp_vert{c},fig_title);
    
    % projection sampling
    % - - - - - - - 
    %plot percentile range (filled)
    fig_title = {[prof_name,': projection range'],['sampling: ',names_samp_cmp{c}]};
    figid = plot_profile_disp_quantile_range(disp_net{c},data,prj1_data,prj2_data,i_s1{c},i_s2{c},prj1_fun{c},prj2_fun{c},prj1_pt{c},prj2_pt{c});
    title(fig_title)

    % rupture sampling
    % - - - - - - - 
    fig_title = {[prof_name,': rupture sampling'],['sampling: ',names_samp_cmp{c}]};
    figid = plot_profile_rupture_loc(data,rup_pt_samp{c},prj1_pt{c}(i_q50,:),prj2_pt{c}(i_q50,:), ...
                                     prj1_data,prj2_data,prj1_fun{c}{i_q50},prj2_fun{c}{i_q50});
    title(fig_title)
end

%tornado plot
figid = plot_disp_unc_tornado(disp_net,names_samp_cmp);
figid = plot_disp_unc_tornado2(disp_net,names_samp_cmp,[0.25,0.75],[0.02,0.25,0.75,0.98]);
