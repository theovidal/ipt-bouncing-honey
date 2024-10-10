clc;
clear;
close all;

% for i=11:20
%     strcat('eth',num2str(i))
%     plot_from_txt(strcat('eth',num2str(i)),'./data/',strcat('./courbes/etude ethanol-curves/'))
%     close all;
% end
% for i=11:20
%     strcat('masse',num2str(i))
%     plot_from_txt(strcat('masse',num2str(i)),'./data/',strcat('./courbes/etude masse-curves/'))
%     close all;
% end

for i=1:5
    strcat('t',num2str(i))
    plot_from_txt(strcat('t',num2str(i)),'./data/',strcat('./courbes/etude moules-curves/'))
    close all;
end
for i=1:2
    strcat('r',num2str(i))
    plot_from_txt(strcat('r',num2str(i)),'./data/',strcat('./courbes/etude moules-curves/'))
    close all;
end