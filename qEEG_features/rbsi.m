function rbsidx = rbsi(dat_left, dat_right, fs);
% This function estimates the symmtery between hemispheres of the brain.
%
%
%
% Nathan Stevenson
% Neonatal Brain Research Group
% June 2009

a = size(dat_left);
N = length(dat_left(1,:));
k = 0:fs/N:fs-1/N;
ref_lo = find(k>=0.5,1);
ref_hi = find(k>=30,1);
X1 = zeros(1,N); X2 = X1;
for ii = 1:a(1)
    X1 = X1+abs(fft(dat_left(ii,:))).^2;
    X2 = X2+abs(fft(dat_right(ii,:))).^2;   
end
rbsidx = abs(mean((X1(ref_lo:ref_hi)-X2(ref_lo:ref_hi))./(X1(ref_lo:ref_hi)+X2(ref_lo:ref_hi))));




