function [H,rmse,cor2,cor1] = COFSM_Match(image_11,image_22)

sigma_s=5;                 % The main parameters of co-occurrence filtering: filter initial window size [3, 5, 10]
sigma_1=1.6;              % Scale of the first layer: 1.6
ratio=2^(1/3);             % scale ratio
Mmax=4;                    % the number of layers in the scale space
first_layer=1;               % extreme point detection start layer number
d_SH=500;                % Feature point extraction threshold size [500, 1000, 1300, 1500, 2000]
change_form='Similarity'; % 'Similarity'£¬'Affine';

[CoOcurscale_space_1]=Create_CoOcurScale_space(image_11,sigma_1,Mmax,ratio,sigma_s);
[CoOcurscale_space_2]=Create_CoOcurScale_space(image_22,sigma_1,Mmax,ratio,sigma_s);

%% 4 Feature point extraction and matching
[H,rmse,cor2,cor1] =CoFSM(CoOcurscale_space_1,CoOcurscale_space_2,d_SH,sigma_1,ratio,first_layer,change_form);                                    
