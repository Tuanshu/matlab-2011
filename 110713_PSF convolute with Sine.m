clear all;
close all;
clc;

%% PSF generation

N_f=2^12;
N_t=N_f*4;

spectrumData=dlmread('D:\Ce.txt');

wavelength_old=spectrumData(:,1);
spectrumPower_old=spectrumData(:,2);

spectrumPower_old=spectrumPower_old-mean(spectrumPower_old(1:1000));

c=3E8;                     %m/sec
freq=c./(wavelength_old*1E-9);     %Hz orignal freq array
d_f=max(freq)/(N_f-1);
fx=0:d_f:max(freq);        %freq after interpolation
d_t=1/(d_f*(N_t-1));
%d_t=1/(d_f*2*N_f);
time=[-0.5*(N_t-1)*d_t:d_t:0.5*N_t*d_t]'/2;%/2是因為一來一回
%time=[-(N_f-1)*d_t:d_t:N_f*d_t]/2;  %/2是因為一來一回
space_FD=c*time; % 暫定只用array前1/100 (大約也有100 micron左右吧)
space_FD=(space_FD-space_FD(1))*1E6;                     % shift to zero & m to micron
%plot(lambda,inter,lambda2,inter);

%S0=inter;
%plot(lambda,S0/max(S0),lambda,inter/max(inter),lambda,ref/max(ref));
%S0=S0/max(S0);        %不先normal應該也沒差?
spectrumPower=interp1(freq,spectrumPower_old.*wavelength_old.^2,fx);
spectrumPower(isnan(spectrumPower))=0;


CS=fft(spectrumPower,N_t)';     %with minus time

CS=fftshift(CS);
%CS=real(fft(S_padded));     %with minus time
CS_normal=CS/max(abs(CS));
CS_envelope=abs(CS);             

[inter_peakvalue_FD inter_peakindex_FD]=max(CS_envelope);
inter_position_FD=space_FD(inter_peakindex_FD);
FWHM_FD_right=space_FD(find(CS_envelope>0.5*inter_peakvalue_FD, 1, 'last'));
FWHM_FD_left=space_FD(find(CS_envelope>0.5*inter_peakvalue_FD, 1, 'first'));
FWHM_inter_FD=FWHM_FD_right-FWHM_FD_left;
FWHM_FD=FWHM_inter_FD;

space_FD=space_FD-inter_position_FD;


%% Sine generation

period=50;   %micron

sinefunction=100*sin(2*pi*space_FD/period);

%test(1:length(space_FD))=0;

%test((round(length(space_FD)/2-10)):(round(length(space_FD)/2+10)))=1;

PSF=real(CS_normal((round(length(space_FD)/2-1000)):(round(length(space_FD)/2+1000))));



%PSF(1:100)=0;
%PSF(50)=1;

%result=convn(sinefunction,PSF,'same');
result=conv(PSF,sinefunction);

%result=convn(test,sinefunction,'same');
%plot(space_FD,test,space_FD,sinefunction,space_FD,result);

plot(result);
%plot(space_FD,sinefunction,space_FD,result);
%plot(space_FD,real(CS_normal),space_FD,sinefunction);
