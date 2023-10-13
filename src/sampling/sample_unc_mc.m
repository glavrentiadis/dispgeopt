function [side1_data,side2_data,rup_pt,azmth_angle,i_s1,i_s2] = sample_unc_mc(flag_samp,side1_data,side2_data,rup_pt,azmth_angle,rup_pt_unc,azmth_angle_unc,rup_lim,samp_pt_p)
% Sample input parameter uncertainty through monte carlo
%
% Input arguments:
%   flag_samp
%   side1_data
%   side2_data
%   rup_pt
%   azmth_angle
%   samp_pt_p
%   rup_pt_unc
%   azmth_angle_unc
%   rup_lim
%
% Output arguments:
%   side1_data
%   side2_data
%   rup_pt
%   azmth_angle
%   i_s1
%   i_s2


%default input
if nargin < 6; rup_pt_unc      = 2.5;       end
if nargin < 7; azmth_angle_unc = 5;         end
if nargin < 8; rup_lim         = nan;       end
if nargin < 9; samp_pt_p       = [0.8,0.8]; end

%confirm sampling specifications
assert(length(flag_samp)==5,'Invalid number of sampling options')

%sample data point populations
if flag_samp(1)
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
if flag_samp(2)
    %side 1
    side1_data(:,1) = normrnd(side1_data(:,1),side1_data(:,4));
    side1_data(:,2) = normrnd(side1_data(:,2),side1_data(:,4));
    %side 2
    side2_data(:,1) = normrnd(side2_data(:,1),side2_data(:,4));
    side2_data(:,2) = normrnd(side2_data(:,2),side2_data(:,4));
end

%sample verical uncertainty
if flag_samp(3)
    %side 1
    side1_data(:,3) = normrnd(side1_data(:,3),side1_data(:,5));
    %side 2
    side2_data(:,3) = normrnd(side2_data(:,3),side2_data(:,5));
end

%extract projection location
side1_data = side1_data(:,1:3);
side2_data = side2_data(:,1:3);

%sample rupture location
if flag_samp(4)
    while true
        %random
        rup_pt = normrnd(rup_pt,rup_pt_unc);
        %exit if inside polygon
        if isnan(rup_lim) || ~isempty( inpolygon(rup_pt(1),rup_pt(2),rup_lim(:,1),rup_lim(:,2)) ); break; end
    end
end

%sample azimuth uncertainty
if flag_samp(5)
    azmth_angle = normrnd(azmth_angle,azmth_angle_unc);
end

end
