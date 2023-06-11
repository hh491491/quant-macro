
clc
clear all
close all

% load the data
startdate = '01/01/1998';
enddate = '10/01/2022';
f = fred
Y_tr = fetch(f,'NGDPRSAXDCTRQ',startdate,enddate)
Y_jp = fetch(f,'JPNRGDPEXP',startdate,enddate)
y_tr = log(Y_tr.Data(:,2));
y_jp = log(Y_jp.Data(:,2));
q = Y_tr.Data(:,1);

T = size(y_tr,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauTRGDP = A\y_tr;
tauJPGDP = A\y_jp;

% detrended GDP
ytilde_tr = y_tr-tauTRGDP;
ytilde_jp = y_jp-tauJPGDP;

% plot detrended GDP
dates = 1998:1/4:2022.4/4;
figure
title('Detrended log(real GDP) 1998Q1-2022Q4'); hold on
plot(q, ytilde_tr,'b', q, ytilde_jp,'r')
legend('Turkey', 'Japan', 'Location', 'southwest')
datetick('x', 'yyyy-qq')

% compute sd(y_tr), sd(y_jp), rho(y_tr), rho(y_jp), corr(y_tr,y_jp) (from detrended series)
ysd_tr = std(ytilde_tr)*100;
ysd_jp = std(ytilde_jp)*100;
corr_tr_jp = corrcoef(ytilde_tr(1:T),ytilde_jp(1:T));
corr_tr_jp = corr_tr_jp(1,2);

disp(['Percent standard deviation of detrended log real GDP for Turkey: ', num2str(ysd_tr),'.']); disp(' ')
disp(['Percent standard deviation of detrended log real GDP for Japan: ', num2str(ysd_jp),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real GDP in Turkey and Japan: ', num2str(corr_tr_jp),'.']);
