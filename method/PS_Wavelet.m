% Wavelet transformasyon metodu
% ��lem                         Yazar              Tarih
% Kod olu�turuldu             MS. Seyfioglu      05.01.2014
% G�ncelleme                  Ezgi San           23.05.2014
% Pan: Pan-kromatik G�r�nt�
% MSImage = Multispektral goruntu
% Pansharp: Pan keskinle�tirilmesi yap�lm�� g�r�nt�
% Referans http://www.math.ucla.edu/~wittman/pansharpening/
function Pansharp = PS_Wavelet( MSImage, Pan)
tic
%haar wavelet'in pansharp konusunda iyi sonuc verdigi yaziyordu bir
%paperda. istenirse baska bir metotla degistirilebilir.
waveletname = 'haar';
%wavelet level'�
level = 2;
%   [n m b] = size(MSImage);
% wavelet decomposition uygulaniyor pan image 'a
bandnum = size(MSImage,3);
[comp, s] = wavedec2(Pan,level,waveletname);
% aynisi ms image'a yapiliyor
for band = 1:bandnum
    newvec(:,band) = comp;
    low_part(:,band) = wavedec2(MSImage(:,:,band),level,waveletname);
end
clear level
%pan'in low res componenti ms'in kiyle degistiriliyor
for j = 1:s(1,1) * s(1,2)
    newvec(j,:) = low_part(j,:);
end
clear low_part
% ters wavelet transform alinip goruntu elde ediliyor.
for band = 1:bandnum
    Pansharp(:,:,band) = waverec2(newvec(:,band),s,waveletname);
end
disp('Wavelet=');
toc
end




