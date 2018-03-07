function [se, A, B] = sample_entropy(u, m, nr);

N = length(u); 
% N = 1000;
% u = rand(1,N);
% m=3;
r  = nr*std(u);

% Sample Entropy
% Bm = zeros(1,N-m);
% for ii = 1:N-m
%     d  = zeros(1,N-m);
%     for jj = 1:N-m
%         u1 = u(ii:ii+m-1);
%         u2 = u(jj:jj+m-1);
%         d(jj) = max(abs(u1-u2));
%     end
%     Bm(ii) = (length(find(d<r))-1)/(N-m-1); 
% end
% B = sum(Bm)/(N-m);

% FASTER
d = r*ones(N-m,N-m);
for ii = 1:N-m
    for jj = ii+1:N-m
        u1 = u(ii:ii+m-1);
        u2 = u(jj:jj+m-1);
        d(ii,jj) = max(abs(u1-u2));
    end
end
B = 2*length(find(d<r))/(N-m-1)/(N-m);

% Am = zeros(1,N-(m+1));
% for ii = 1:N-(m+1)
%     d  = zeros(1,N-(m+1));
%     for jj = 1:N-(m+1)
%         u1 = u(ii:ii+(m+1)-1);
%         u2 = u(jj:jj+(m+1)-1);
%         d(jj) = max(abs(u1-u2));
%     end
%     Am(ii) = (length(find(d<r))-1)/(N-m-1); 
% end
% A = sum(Am)/(N-m);

% FASTER
d = r*ones(N-(m+1),N-(m+1));
for ii = 1:N-(m+1)
    for jj = ii+1:N-(m+1)
        u1 = u(ii:ii+(m+1)-1);
        u2 = u(jj:jj+(m+1)-1);
        d(ii,jj) = max(abs(u1-u2));
    end
end
A = 2*length(find(d<r))/(N-m-1)/(N-m);

se = -log(A/B);
%SampEnmax = log(N-m)+log(N-m-1)-log(2);


