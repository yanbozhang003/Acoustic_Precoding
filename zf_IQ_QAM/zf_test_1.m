clear all;
close all;
clc

N = 10000;
info = random_binary(N);
N1 = 3; N2=5;   % equalizer sum_(-N1)^(N2)
L1 = 1; L2 = 3;  % isi sum_(-L1)^(N2)
info = [info zeros(1, L1 + N1)];
actual_isi = [0.19+0.56j, 0.45-1.28j, -0.14-.53j, -0.19+.23j, 0.33+.51j];
length_equalizer = N1 + N2 + 1; 
length_actual_isi = length(actual_isi);

%%- - - ZF Precoding - - -%%
matrix_isi = convmtx(actual_isi.', length_equalizer);
destina_matrix = zeros(L1 + L2 + N1 + N2 + 1, 1);
destina_matrix(L1 + N1 + 1) = 1;
matrix_zf = ((matrix_isi' * matrix_isi) \ (matrix_isi')) * destina_matrix; % (P^HP)^(-1)P^H

coded_info = filter(matrix_zf, 1, info);
coded_info = coded_info(L1 + N1 + 1 : end);

Rx_zf_info = filter(actual_isi, 1, coded_info);
Rx_zf_info(find(Rx_zf_info < 0)) = -1;
Rx_zf_info(find(Rx_zf_info > 0)) = 1;
zf_error = find(Rx_zf_info ~= info(1:N));
if isempty(zf_error)
    zf_error_per = 0;
else
    zf_error_per = length(zf_error) / N;
end

% Rx_info = filter(actual_isi, 1, info);
% Rx_info(Rx_info < 0) = -1;
% Rx_info(Rx_info > 0) = 1;
% Rx_error = find(Rx_info ~= info);
% Rx_error_per = length(Rx_error) / N;

h1 = freqz(actual_isi);
h2 = freqz(matrix_zf);
h_toal = h1.*h2;

figure(1)
subplot(2, 1, 1)
stem(-L1 : L2, abs(actual_isi), 'b', 'LineWidth', 1.3);
legend('ISI Channel');
title('Absolute values of impulse responses'); % Absolute values of channel impulse response
subplot(2,1,2)
stem(-N1-L1 : N2+L2, abs(conv(actual_isi, matrix_zf)), 'LineWidth', 1.3); 
legend('ISIS Channel + ZF Precoding');
title('Absolute values of impulse responses'); % Absolute values of channel impulse response


figure(2)
plot(20*log10(abs(h1)), 'LineWidth', 1.3);
hold on;
plot(20*log10(abs(h2)),'LineWidth', 1.3);
hold on;
plot(20*log10(abs(h_toal)), 'LineWidth', 1.3);
legend('ISI Channel', 'Precoding', 'Precoded Channel');
title('Frequency Responses');
figloc

