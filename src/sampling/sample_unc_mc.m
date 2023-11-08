function [side1_data,side2_data,rup_pt,azmth_angle,i_s1,i_s2] = sample_unc_mc(flag_samp,side1_data,side2_data, ...
                                                                              rup_pt_mean,rup_pt_unc, ...
                                                                              azmth_angle_mean,azmth_angle_unc, ...
                                                                              samp_pt_p, ...
                                                                              winsize_info, ...
                                                                              rup_ax,rup_lim)
% Sample input parameter uncertainty through monte carlo
%
% Input arguments:
%   flag_samp:                  flag for uncertainty component samling
%   side1_data (mat[n_s1,6]):   coordinates and uncertainty for points of side A 
%   side2_data  (mat[n_s2,6]):  coordinates and uncertainty for points of side B 
%   rup_pt_mean (array[2]):     mean of rupture location
%   rup_pt_unc (array[2]):      ucertainty for rupture location
%   azmth_angle_mean (double):  mean azimuth angle
%   azmth_angle_unc (doulbe):   uncertainty of azimuth angle
%   samp_pt_p (array[2]):       projection points' sampling probability
%   winsize_info (array[2]):    projection window size
%   rup_ax (mat[2,2]):          principal rupture axes
%   rup_lim (mag[n_r,2]):       rupture zone
%
% Output arguments:
%   side1_data (mat[n_s1',6]):  selected sides for side A
%   side2_data (mat[n_s2',6]):  selected sides for side A
%   rup_pt (array[2]):          rupture location
%   azmth_angle  (double):      rupture angle
%   i_s1 (array[n_s1']):        indices of side A selected points
%   i_s2 (array[n_s2']):        indices of side B selected points

% flag sampling positions
%   1: projection points
%   2: projection window
%   3: horizontal location
%   4: vertical location
%   5: rupture location
%   6: rupture azimuth

%default input
if nargin < 6;  rup_pt_unc      = 2.5;       end
if nargin < 7;  azmth_angle_unc = 5;         end
if nargin < 8;  samp_pt_p       = [0.5,0.5]; end
if nargin < 9;  samp_pt_p       = [0.5,0.5]; end
if nargin < 10; rup_ax          = eye(2);    end
if nargin < 11; rup_lim         = nan;       end

%confirm sampling specifications
assert(length(flag_samp)==6,'Invalid number of sampling options')

%sample data point populations
if flag_samp(1)
    while true
        %window size
        wsize = normrnd(winsize_info(1),winsize_info(2));
        wsize = max(wsize, 0);
    
        %window position (side A)
        s1_mp = max(side1_data(:,6)) * rand();
        s1_ws = s1_mp - wsize/2;
        s1_we = s1_mp + wsize/2;
        %window position (side A)
        s2_mp = max(side2_data(:,6)) * rand();
        s2_ws = s2_mp - wsize/2;
        s2_we = s2_mp + wsize/2;

        %points
        i_s1 = and(s1_ws >= side1_data(:,6), side1_data(:,6) <= s1_we);
        i_s2 = and(s2_ws >= side2_data(:,6), side2_data(:,6) <= s2_we);
        if length(i_s1)>=4 && length(i_s2)>=4; break; end
    end
else
    i_s1 = (1:size(side1_data,1))';
    i_s2 = (1:size(side2_data,1))';
end

%sample data point populations
if flag_samp(2)
    %data points to select
    while true
        i_s1 = find( binornd(true,samp_pt_p(1)*ones(size(side1_data,1),1)) );
        if length(i_s1)>=4; break; end
    end
    while true
        i_s2 = find( binornd(true,samp_pt_p(2)*ones(size(side2_data,1),1)) );
        if length(i_s2)>=4; break; end
    end
else
    i_s1 = (1:size(side1_data,1))';
    i_s2 = (1:size(side2_data,1))';
end
%data downsampling
side1_data = side1_data(i_s1,:);
side2_data = side2_data(i_s2,:);

%sample horizontal uncertainty
if flag_samp(3)
    %side 1
    side1_data(:,1) = normrnd(side1_data(:,1),side1_data(:,4));
    side1_data(:,2) = normrnd(side1_data(:,2),side1_data(:,4));
    %side 2
    side2_data(:,1) = normrnd(side2_data(:,1),side2_data(:,4));
    side2_data(:,2) = normrnd(side2_data(:,2),side2_data(:,4));
end

%sample verical uncertainty
if flag_samp(4)
    %side 1
    side1_data(:,3) = normrnd(side1_data(:,3),side1_data(:,5));
    %side 2
    side2_data(:,3) = normrnd(side2_data(:,3),side2_data(:,5));
end

%extract projection location
side1_data = side1_data(:,1:3);
side2_data = side2_data(:,1:3);

%sample rupture location
if flag_samp(5)
    while true
        %random variability
        rup_pt = normrnd([0;0],rup_pt_unc);
        %shift and rotation rupture point
        rup_pt = rup_pt_mean + rup_ax * rup_pt;
        %exit if inside polygon
        if all(isnan(rup_lim),'all') || all( inpolygon(rup_pt(1),rup_pt(2),rup_lim(:,1),rup_lim(:,2)) ); break; end
    end
else
    rup_pt = rup_pt_mean;
end

%sample azimuth uncertainty
if flag_samp(6)
    azmth_angle = normrnd(azmth_angle_mean,azmth_angle_unc);
else
    azmth_angle = azmth_angle_mean;
end

end
