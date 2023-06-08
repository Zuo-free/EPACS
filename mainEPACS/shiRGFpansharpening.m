function HMS = shiRGFpansharpening( MS,Pan,lambda,gamma )

MS=double(MS);
Pan=double(Pan);
original_MS=MS;
original_Pan=Pan;
[m,n,d]=size(MS);

if(~exist('lambda', 'var')),
    lambda = 0.8;
end
if(~exist('gamma', 'var')),
    gamma = 0.1;
end
%%
% Pretreatment 
for i=1:d
    MS_max(i)=max(max(MS(:,:,i)));
    normal_MS(:,:,i)=MS(:,:,i)/MS_max(i);
end
Pan_max=max(max(Pan));
normal_Pan=Pan/Pan_max;
%% RGF filter
%  Estimating the Primitive Detail Map
% for i=1:d
%     MS_low(:,:,i)=wlsFilter(normal_MS(:,:,i),lambda,0.8);
% end
% Pan_low=wlsFilter(normal_Pan,lambda,0.8);
r = 2; % try r=2, 4, or 8
eps = 0.1; % try eps=0.1^2, 0.2^2, 0.4^2
sigma_s = 3;%try2,6,4
sigma_r = 0.8; %try0.2,  0.4 ,0.6
iteration = 6;%try4,6,8
GaussianPrecision = 0.05;
ratio=2;
for i = 1 : d
    MS_low(:, :, i) = RollingGuidanceFilter(normal_MS(:, :, i), sigma_s, sigma_r, iteration, GaussianPrecision);
end
Pan_low = RollingGuidanceFilter(normal_Pan, sigma_s, sigma_r, iteration, GaussianPrecision);   %%%PAN低频

for i=1:d
    MS_high(:,:,i)=normal_MS(:,:,i)-MS_low(:,:,i);     %%%MS高频
end
Pan_high = normal_Pan-Pan_low;                 %%%%PAN高频
%% MTF filter
% aux= imresize(Pan_high,1/ratio,'bilinear');
% PAN= imresize(aux,ratio,'bilinear');
Nl = 41;
fcut = 1/ratio;
GNyq=0.7;  %0.7 %0.2  
alpha = sqrt((Nl*(fcut/2))^2/(-2*log(GNyq)));
H = fspecial('gaussian', Nl, alpha);
Hd = H./max(H(:));
h = fwind1(Hd,kaiser(Nl));
I_PAN_LP = imfilter(Pan_high,real(h),'replicate');
PAN= double(I_PAN_LP);
%%
% temp = zeros(m*n,d);
% for k = 1:d
%     temp(:,k) = reshape(squeeze(MS_high(:,:,k)),[m*n,1]);
% end
% 
% alpha = regress(Pan_high(:),temp);   %%%获取系数
% alpha=[0.0040,0.0447,0.0117,1.4195,-0.9175];
%% I estimate
bb = zeros(n*m,d);
for k = 1:d
    bb(:,k) = reshape(squeeze(MS_high(:,:,k)),[n*m,1]);
end
bb = [ones(n*m,1),bb];
alpha = regress(PAN(:),bb); 
aux = bb * alpha;
I_high = reshape(aux,[m,n]);
% disp(alpha)
%%
% I_high=(alpha(1)*MS_high(:,:,1)+alpha(2)*MS_high(:,:,2)+alpha(3)*MS_high(:,:,3)+alpha(4)*MS_high(:,:,4));  %%%强度分量
for i=1:d
    primitive_D(:,:,i)=(Pan_high-I_high);      %%细节图像
end
%%
g = ones(1,1,d);
for ii = 1 : d
    h = MS_high(:,:,ii);
    c = cov(I_high(:),h(:));
    g(1,1,ii+1) = c(1,2)/var(I_high(:));
end
% disp(g)
for i = 1:d
    primitive_D(:,:,i)=g(i)*primitive_D(:,:,i);
end
%%
for i = 1 : 4
    extra(:,:,i) = guidedFilter(Pan_high, MS_high(:,:,i), r, eps);
    add(:,:,i) = MS_high(:,:,i) - extra(:,:,i) ;
    primitive_D(:,:,i)  = primitive_D(:,:,i) + add(:,:,i);
end
for i = 1 : 4
    extra(:,:,i) = guidedFilter(Pan_high, add(:,:,i), r, eps);
    add(:,:,i) = MS_high(:,:,i) - extra(:,:,i) ;
    primitive_D(:,:,i)  = primitive_D(:,:,i) + add(:,:,i);
end
%%
% Refining the Primitive Detail Map
% final_D=sdm(MS_high,Pan_high,alpha,primitive_D,gamma);
% r = 8;
% eps = 10^-2;
% s = 4;

% extra = fastguidedfilter(Pan_high, MS_high(:,:,i), r, eps, s);
%
% Obtain the HMS image
for i=1:d
    HMS(:,:,i)=original_MS(:,:,i)+primitive_D(:,:,i)*MS_max(i);
%     HMS(:,:,i)=original_MS(:,:,i)+final_D(:,:,i)*MS_max(i);

end

end

