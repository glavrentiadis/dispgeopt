function [rup_azmth_mean,rup_azmth_std,rup_ax] = input_rupture_azmth(flag_unc)
% Dialog box of azimuth angle and uncertainty
%
% Input arguments:
%   flag_unc (bool): flag for rupture uncertainty
% 
% Output arguments:
%   rup_azmth_mean (double):   rupture azimuth (deg)
%   rup_azmth_std  (double):   rupture azimuth (deg)

%default input
if nargin < 1; flag_unc=False; end

%window name
dlgtitle = 'Azimuth Input';


switch flag_unc
    case 0 %azimuth angle w\ uncertainty
        prompt   = {'Enter rupture azimuth angle (deg):'};
        definput = {'45'};
        dims     = [1 45];
        inpt     = inputdlg(prompt, dlgtitle, dims, definput);
        rup_azmth_mean = str2double(inpt{1});
        rup_azmth_std  = nan;
    case 1 %azimuth angle w\o uncertainty
        prompt   = {'Enter rupture azimuth angle (deg):';
                    'Enter rupture azimuth uncertainty (deg):'};
        definput = {'45.0','2.5'};
        dims     = [1, 45; 1, 45];
        inpt     = inputdlg(prompt, dlgtitle, dims, definput);
        rup_azmth_mean = str2double(inpt{1});
        rup_azmth_std  = str2double(inpt{2});
end

end
