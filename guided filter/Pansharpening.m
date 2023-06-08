function HMS = Pansharpening( MS,Pan,lambda,gamma )

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
%%
%  Estimating the Primitive Detail Map
% for i=1:d
%     MS_low(:,:,i)=wlsFilter(normal_MS(:,:,i),lambda,0.8);
% end
% Pan_low=wlsFilter(normal_Pan,lambda,0.8);
r = 2; % try r=2, 4, or 8
eps = 0.1; % try eps=0.1^2, 0.2^2, 0.4^2
for i = 1 : d
    MS_low(:, :, i) = guidedFilter(normal_MS(:, :, i), normal_MS(:, :, i), r, eps);
end
Pan_low = guidedFilter(normal_Pan, normal_Pan, r, eps);    %%%PAN低频

for i=1:d
    MS_high(:,:,i)=normal_MS(:,:,i)-MS_low(:,:,i);     %%%MS高频
end
Pan_high = normal_Pan-Pan_low;                 %%%%PAN高频

temp = zeros(m*n,d);
for k = 1:d
    temp(:,k) = reshape(squeeze(MS_high(:,:,k)),[m*n,1]);
end

alpha = regress(Pan_high(:),temp);   %%%获取系数

I_high=(alpha(1)*MS_high(:,:,1)+alpha(2)*MS_high(:,:,2)+alpha(3)*MS_high(:,:,3)+alpha(4)*MS_high(:,:,4));  %%%强度分量
for i=1:d
    primitive_D(:,:,i)=(Pan_high-I_high);      %%细节图像
end
%
for i = 1 : 4
    extra(:,:,i) = guidedFilter(Pan_high, MS_high(:,:,i), r, eps);
    add(:,:,i) = MS_high(:,:,i) - extra(:,:,i) ;
    primitive_D(:,:,i)  = primitive_D(:,:,i) + add(:,:,i);
end

MSband_show1=[2 3 4];
normlColor = @(R)max(min((R-mean(R(:)))/std(R(:)),5),-5)/4+0.5;
figure(11);
 imshow(normlColor(extra(:,:,MSband_show1)));title('guidefilter,r=8,eps=0.4');
 figure(12);
 imshow(normlColor(add(:,:,MSband_show1)));title('addetail,r=8,eps=0.4');
for i = 1 : 4
    extra(:,:,i) = guidedFilter(Pan_high, add(:,:,i), r, eps);  
    add(:,:,i) = MS_high(:,:,i) - extra(:,:,i) ;
    primitive_D(:,:,i)  = primitive_D(:,:,i) + add(:,:,i);
end
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

