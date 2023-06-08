normColor = @(R)max(min((R-mean(R(:)))/std(R(:)),5),-5)/4+0.5;
PAN=double(imread('E:\matlab\clip\sv_28672_16384.tif'));
const=max(PAN(:));
PAN=PAN/const;PAN=rot90(PAN,3);
MS=double(imread('E:\matlab\clipmss\sv_7168_4096.tif'));
MS=MS/const;MS=rot90(MS,3);
MSband_show=[3 2 1];
MSdown= imresize(MS,1/4,'bilinear');
PANdown= imresize(PAN,1/4,'bilinear');
IMS=imresize(MSdown,4,'bilinear');  %%%'nearest'，'bicubic'最好'bilinear次好'
fused = shiRGFpansharpening(IMS,PANdown);
% % fused=MTF_GLP_ECB(IMS,PANdown,4,20,2.5,'none','none');
% % fused=MTF_GLP_CBD(IMS,PANdown,4,20,-Inf,'none','none');
% % fused=MTF_GLP(PANdown,IMS,4);
% % fused=HPF(IMS,PANdown,4);
% % fused=PRACS(IMS,PANdown,4);
ERGAS=IndexERGAS(fused,MS,4);
SAM=IndexSAM(fused,MS);
RMSE=RMSE1(fused,MS);
RASE=RASE1(fused,MS);
% CC=CC1(fused,MS);
Q=IndexQ(fused,MS);
disp(ERGAS)
disp(SAM)
disp(RMSE)
disp(RASE)
% disp(CC)
disp(Q)
