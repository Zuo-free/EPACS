normColor = @(R)max(min((R-mean(R(:)))/std(R(:)),3),-3)/6+0.5;
PAN=double(imread('E:\matlab\clip\sv_28672_16384.tif'));
const=max(PAN(:));
PAN=PAN/const;PAN=rot90(PAN,3);
MS=double(imread('E:\matlab\clipmss\sv_7168_4096.tif'));
MS=MS/const;MS=rot90(MS,3);
MSband_show=[3,2,1];
IMS=imresize(MS,4,'bicubic');  %%%'nearest'，'bicubic'最好'bilinear次好'
% fused = PRACS(IMS,PAN,4);
% fused = GIHS(IMS,PAN);
fused = shiRGFpansharpening(IMS,PAN);
% fused=MTF_GLP_CBD(IMS,PAN,4,20,-Inf,'none','none');
% fused=MTF_GLP_ECB(IMS,PAN,4,20,2.5,'none','none');
% fused=MTF_GLP(PAN,IMS,4);
% fused=HPF(IMS,PAN,4);
% % fused=PRACS(IMS,PAN,4);
% fused=BDSD(IMS,PAN,4,128,'none');
% fused=GS(IMS,PAN);
% fused=PCA(IMS,PAN);
% fused=Brovey(IMS,PAN);
%降采样

% figure(1);
% imshow(MS(:,:,MSband_show));
% figure(2);
% imshow(PAN);
% figure(3);
% imshow(fused(:,:,MSband_show));

lamda=D_lambda(fused,IMS,16,1);
disp(lamda)
D_s=IndexD_s(fused,IMS,PAN,'none',4,4,1);
disp(D_s)
QNR=(1-lamda)*(1-D_s);
disp(QNR)