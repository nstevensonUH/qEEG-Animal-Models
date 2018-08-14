

filename = 'test.eeg';

% Read in file header - for the file test.eeg this is a slighlty more
% complicated process as the header was ripped from an alternate file so
% some adjustments must be made

[fid, val1, val2] = read_header(filename);

val1(5) = 240; % delete this line when using real data.

% Do the processing in 1h blocks
fs = val1(1); % Sampling Frequency
fs = 500;
fs1 = 256; % Set all signals to this sampling frequency
ch_no = val1(4); % Number of EEG channels
N = val1(5)*val1(1)*60; % Number of hours in recording
ep = 3600*fs; % 1 hour primary epoch
elen = 60*fs; % 1 min secondary epoch
ep1 = 3600*fs1; % 1 hour primary epoch
elen1 = 60*fs1; % 1 min secondary epoch
block_no1 = floor(N/ep); % Only takes in full hours, will fix in next update.
fvec1 = []; fvec2 = []; % Initialise calculated qEEG features
load filters % design for specific fs and cutoffs will need to update

for jj = 1:block_no1;
tic  % tic and toc will tell you how fast it is running.
% Read in one hour of EEG data
dat = double(zeros(ep,val1(4))); 
for ii = 1:ep
    dat(ii,:) = double(fread(fid,  val1(4), 'short')').*val2;
end
dat = resample(dat, fs1, fs);

% Do filtering (50Hz notch, and 0.5Hz HPF at this stage) these only work if
% fs is 256
A = size(dat);
for ii = 1:A(2);
    dum = dat(:,ii);
    dum1 = filter(Num, Den, dum);
    dum2 = filter(Num_50, Den_50, dum1);
    dat(:,ii) = dum2;
end

% Estimate qEEG features from each channel of EEG in 1 minute signal
% segments (epochs)
fbnd = [0.5 2 ; 2 4 ; 4 8 ; 8 16 ; 16 32]; % Define frequency bands in Hz
block_no2 = floor(ep1/elen1); fv = zeros(block_no2, 10+length(fbnd));
for kk1 = 1:block_no2
    r1 = (kk1-1)*elen1+1; r2 = r1+elen1-1;
    fval1 = zeros(2, 3); fval2 = fval1; fval4 = fval1; fval5 = zeros(2,1); fval3 = zeros(2, length(fbnd));
    for kk2 = 1:ch_no
        dat1 = dat(r1:r2,kk2); % Segement EEG
        reeg = estimate_rEEG(dat1, fs1); % Estimate the rEEG signal
        fval1(kk2,:) = quantile(reeg, [0.1 0.5 0.9]);
        amp = abs(hilbert(dat1)); % Estimate the amplitude envelope
        fval2(kk2,:) = [mean(amp) std(amp) skewness(amp)];
        [Pxx, f] = pwelch(dat1, hamming(elen/8), elen/16, elen, fs1); % Estimate the PSD
        ap = zeros(1,length(fbnd));
        for kk3 = 1:length(fbnd)
            ref = find(f>fbnd(kk3, 1) & f<=fbnd(kk3,2));
            ap(kk3) = sum(Pxx(ref)); % Calculate absolute band powers
        end
        fval3(kk2,:) = ap./sum(ap);
        ife = diff(unwrap(angle(hilbert(dat1))))/(2*pi)*fs1; % Estimate the instantaneous frequency
        fval4(kk2,:) = quantile(ife, [0.25 0.5 0.75]);
       fval5(kk2) = Higuchi1Dn(resample(dat1, 64, fs1)); % resample for speed: Fractal dimension estimate
 %       fval6(kk2) = sample_entropy(resample(dat, 64, fs), 3, 1); % Sample
 %       entropy takes a long time to compute so include if you have the
 %       time
    end
    fv(kk1,:) = [mean(fval1) mean(fval2) mean(fval3) mean(fval4) mean(fval5)]; % mean(fval6)]; 
end
fvec1 = [fvec1 ; fv];

% Calculate cross-channel features ()only works with 2 channels at the
% moment
fv1 = zeros(block_no2, 3); fvec2 = [];
for kk1 = 1:block_no2
    r1 = (kk1-1)*elen1+1; r2 = r1+elen1-1;
    fval1 = zeros(2, 3); fval2 = fval1; fval4 = fval1; fval3 = zeros(2, length(fbnd));
    dat1 = dat(r1:r2,1);
    dat2 = dat(r1:r2,2);
    fv1(kk1, 1) = getASI([dat1 dat2], fs1); % Activation Synchrony Index
    fv1(kk1, 2) = corr(abs(hilbert(dat1)), abs(hilbert(dat2))); % Correlate amplitude envelopes
    fv1(kk1, 3) = rbsi(dat1', dat2', fs1); % revised brain symmtery calculations
  %  fv1(kk1, 4) = sample_entropy_x(resample(dat1, 64, fs), resample(dat2,
  %  64, fs), 3, 1); % Once again takes ages to calculate so only include
  %  if you have the time
end
fvec2 = [fvec2 ; fv1];


disp(['Processed hour ' num2str(jj)]) % update to command window that an hour has been analysed
toc
end
fclose(fid)
