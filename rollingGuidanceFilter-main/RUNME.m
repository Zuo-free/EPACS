clear;
close all;

str = 'C:\Users\×ó\Desktop\matlab code\rollingGuidanceFilter-main\rollingGuidanceFilter-main\dataset\pic5.jpeg';
I = im2double(imread(str));
figure,imshow(I);title('original Img');drawnow;
%% parameters setting
w = 10; %iter num
sigma_s = 3;
sigma_r = 0.05;

%% rolling guidance filtering
tic;
res = RollingGuidanceFilter(I,sigma_s,sigma_r,w);
toc;
figure(1),imshow(res);title('RG filtering result');drawnow;
% imwrite(res,'result/iter/10.png');

%% texture seperation

texture = I - res;

figure(2), imshow(texture);title('original texture');drawnow;
% imwrite(texture,'result/iter/10texture.png');

th = 0.1;
texture(texture>th) = 1;
texture(texture<=th) = 0;
texture = rgb2gray(texture);

figure(3),imshow(texture);title('binarized texture');drawnow;
imwrite(texture,'result/iter/10wenli.png');

% %% image abstraction
% 
% img = im2double(imread(str));
% cartoonImage = cartoonify(res);
% figure(4);imshow(cartoonImage);title('Img Abstraction result');drawnow;
% %imwrite(cartoonImage,'result/imgAbstraction/imgAbstraction_4.png');
% 
% %% detail enhancement
% 
% fine=detailenhance( I, res, texture, 12, 1 );
% figure(5);imshow(fine);title('Detail Enhancement result');
% %imwrite(fine,'result/detailEnhancement/detailEnhancement_4.png');
