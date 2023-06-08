%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: 
%           MTF_GLP fuses the upsampled MultiSpectral (MS) and PANchromatic (PAN) images by 
%           exploiting the Modulation Transfer Function - Generalized Laplacian Pyramid (MTF-GLP) algorithm. 
% 
% Interface:
%           I_Fus_MTF_GLP = MTF_GLP(I_PAN,I_MS,sensor,tag,ratio)
%
% Inputs:
%           I_PAN:              PAN image;
%           I_MS:               MS image upsampled at PAN scale;
%           sensor:             String for type of sensor (e.g. 'WV2','IKONOS');
%           tag:                Image tag. Often equal to the field sensor. It makes sense when sensor is 'none'. It indicates the band number
%                               in the latter case;
%           ratio:              Scale ratio between MS and PAN. Pre-condition: Integer value.
%
% Outputs:
%           I_Fus_MTF_GLP:      MTF_GLP pansharpened image.
% 
% References:
%           [Aiazzi02]          B. Aiazzi, L. Alparone, S. Baronti, and A. Garzelli, 揅ontext-driven fusion of high spatial and spectral resolution images based on
%                               oversampled multiresolution analysis,? IEEE Transactions on Geoscience and Remote Sensing, vol. 40, no. 10, pp. 2300?2312, October
%                               2002.
%           [Aiazzi06]          B. Aiazzi, L. Alparone, S. Baronti, A. Garzelli, and M. Selva, 揗TF-tailored multiscale fusion of high-resolution MS and Pan imagery,?
%                               Photogrammetric Engineering and Remote Sensing, vol. 72, no. 5, pp. 591?596, May 2006.
%           [Vivone14a]         G. Vivone, R. Restaino, M. Dalla Mura, G. Licciardi, and J. Chanussot, 揅ontrast and error-based fusion schemes for multispectral
%                               image pansharpening,? IEEE Geoscience and Remote Sensing Letters, vol. 11, no. 5, pp. 930?934, May 2014.
%           [Vivone14b]         G. Vivone, L. Alparone, J. Chanussot, M. Dalla Mura, A. Garzelli, G. Licciardi, R. Restaino, and L. Wald, 揂 Critical Comparison Among Pansharpening Algorithms?, 
%                               IEEE Transaction on Geoscience and Remote Sensing, 2014. (Accepted)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function I_Fus_MTF_GLP = MTF_GLP(I_PAN,I_MS,ratio)

imageHR = double(I_PAN);
I_MS = double(I_MS);

%%% Equalization
imageHR = repmat(imageHR,[1 1 size(I_MS,3)]);

for ii = 1 : size(I_MS,3)    
   imageHR(:,:,ii) = (imageHR(:,:,ii) - mean2(imageHR(:,:,ii))).*(std2(I_MS(:,:,ii))./std2(imageHR(:,:,ii))) + mean2(I_MS(:,:,ii));
end
weixing=[0.2,0.18,0.18,0.26]; %Band Order: B,G,R,NIR通道信息
%%% MTF
N = 41;
PAN_LP = zeros(size(I_MS));
nBands = size(I_MS,3);
fcut = 1/ratio;
PSF_G = zeros(N,N,nBands);

for ii = 1 : nBands
    alpha = sqrt((N*(fcut/2))^2/(-2*log(weixing(ii))));
    H = fspecial('gaussian', N, alpha);
    Hd = H./max(H(:));
    h = fwind1(Hd,kaiser(N));
    PSF_G(:,:,ii) = real(h);
    PAN_LP(:,:,ii) = imfilter(imageHR(:,:,ii),real(h),'replicate');
    t = imresize(PAN_LP(:,:,ii),1/ratio,'nearest');
    PAN_LP(:,:,ii) = interp23tap(t,ratio);
end

PAN_LP = double(PAN_LP);

I_Fus_MTF_GLP = I_MS + imageHR - PAN_LP;

end