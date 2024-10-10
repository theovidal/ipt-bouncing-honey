%function plot_from_txt(fichier,repert_data,repert_curves,Z)

clc
close all
clear

%arguments
repert_data='./data/';
fichier='cement long';
repert_curves='./courbes/';
chemin_curves=strcat(repert_curves,fichier,'-curves/');
file=fopen(strcat(repert_data,fichier,'-DATA.txt'),'r');

%count dimension of arrays
fgetl(file);
fgetl(file);
n=0;
while ischar(fgetl(file))
    n=n+1;
end
%cursor at the beginning af the file
frewind(file);
fgetl(file);
fgetl(file);

%vectors
alpha_t=zeros(1,n);
surface_t=zeros(1,n);
centroid_t=zeros(1,n);
t=zeros(1,n);

%extract data
for k=1:n
    line = strip(fgetl(file));
    line_data=regexp(line,' ','split');
    alpha_t(k)=str2double(line_data{1});
    centroid_t(1,k)=str2double(line_data{2})*60/470;
    centroid_t(2,k)=str2double(line_data{3})*60/470;
    surface_t(k)=str2double(line_data{4});
    t(k)=str2double(line_data{5});
end

fclose(file);

%--------------------------------------------------------------------------
%                                  Plot
%--------------------------------------------------------------------------

mkdir (chemin_curves);

%increment : on plot 1/(inc) image
inc=1;
%dernière image que l'on plot (pour les plots qui l'utilisent)
ends =14*60;
%première image que l'on plot (pour les plots qui l'utilisent)
marge=2;

%%
%smooth angular data
alpha_ts=smooth(alpha_t);

%PLOT ANGULAR DATA AND FITS

figure(1)
%plot(t(1,1+marge:inc:ends),alpha_t(1,1+marge:inc:ends),'blue+')
hold on

plot(t(marge:inc:ends),alpha_ts(marge:inc:ends,1),'b+','DisplayName','Rotation')

[interpol,S]=polyfit(t(1,marge:ends),alpha_ts(marge:ends,1),1);
interpol_points=polyval(interpol,t(1,marge:end));
R2=1 - (S.normr/norm(alpha_ts(marge:ends,1) - mean(alpha_ts(marge:ends,1))))^2
plot(t(1,marge:ends-1),interpol_points(1,marge:ends-1),'red-','DisplayName','Linear regression')

hold off
legend
xlabel('Time (s)')
ylabel('Rotation (°)')
title('Rotation function of time and linear regression')
exportgraphics(figure(1),strcat(chemin_curves,fichier,'-rotation et lin.png' ))
savefig(figure(1),strcat(chemin_curves,fichier,'-rotation et lin'))



%PLOT LOG ROTATION AND FIT

%autre première image que l'on plot (pour les plots qui l'utilisent)
% marge=60;
% 
% figure(11)
% %plot(log(t(1,marge:inc:ends)),log(alpha_t(1,marge:inc:ends)),'blue+')
% hold on
% plot(log(t(1,marge:inc:ends)),log(alpha_ts(marge:inc:ends,1)),'c+','DisplayName','Log rotation')
% 
% interpolLog=polyfit(log(t(marge+1000:ends)),log(alpha_ts(marge+1000:ends,1)),1);
% interpolLog_points=polyval(interpolLog,log(t(marge:end)));
% plot(log(t(marge:inc:ends)),interpolLog_points(marge:inc:ends),'red.','DisplayName','Linear regression')
% 
% hold off
% legend
% xlabel('log(Time (s))')
% ylabel('log(Rotation (°))')
% title('Log de Rotation en fonction de log du Time et Linear regression')
% exportgraphics(figure(11),strcat(chemin_curves,fichier,'-log rotation.png' ))
% savefig(figure(11),strcat(chemin_curves,fichier,'-log rotation'))



%PLOT FIT NON LINEAIRE

inc=2;
marge=2;

figure(12)
hold on
plot(t(1,marge:inc:end),alpha_ts(marge:inc:end,1),'b+','DisplayName','Rotation')

interpolCubique=polyfit(t(1,marge:end),alpha_ts(marge:end,1),3);
interpolCubique_points=polyval(interpolCubique,t(1,marge:end));
%plot(t(1,marge:inc:end),interpolCubique_points(1,marge:inc:end),'red.','DisplayName','Fit cubique')

interpolQuadratique=polyfit(t(1,marge:end),alpha_ts(marge:end,1),4);
interpolQuadratique_points=polyval(interpolQuadratique,t(1,marge:end));
%plot(t(1,marge:inc:end),interpolQuadratique_points(1,marge:inc:end),'green.','DisplayName','Fit quadratique')

hold off

legend
xlabel('Time (s)')   
ylabel('Rotation (°)')
title('Rotation function of Time')
exportgraphics(figure(12),strcat(chemin_curves,fichier,'-rotation.png' ))
savefig(figure(12),strcat(chemin_curves,fichier,'-rotation'))

%%
%PLOT ANGULAR SPEED AND FIT

inc=1;
marge=2;

%calculate dérivée
omega_t=diff(alpha_t)*60;
omega_ts=diff(alpha_ts)*60;

%calculate fits
interpol_d=diff(interpol_points)*60;
interpolCubique_d=diff(interpolCubique_points)*60;
interpolQuadratique_d=diff(interpolQuadratique_points)*60;

%plot
figure(2)
plot(t(1,1+marge:inc:end),omega_ts(marge:inc:end,1),'blue-','DisplayName','Angular speed')
hold on
% plot(t(1,1+marge:inc:end),interpol_d(1,marge:inc:end-1),'red-','DisplayName','Linear regression')
% plot(t(1,1+marge:inc:end),interpolQuadratique_d(1,marge:inc:end-1),'cyan-','DisplayName','Quadratic regression')
% plot(t(1,1+marge:inc:end),interpolCubique_d(1,marge:inc:end-1),'yellow-','DisplayName','Cubic regression')
hold off

legend
xlabel('Time (s)')
ylabel('Angular speed (°/s)')
title('Angular speed function of time')
exportgraphics(figure(2),strcat(chemin_curves,fichier,'-omega.png' ))
savefig(figure(2),strcat(chemin_curves,fichier,'-omega'))

%%
%PLOT TRANSLATION
inc=2;
figure(3)
%imshow(Z)
hold on
scatter(centroid_t(1,marge:inc:end),centroid_t(2,marge:inc:end),'+');
hold off
xlabel('x (mm)')
ylabel('y (mm)')
title('Overall deplacement')
exportgraphics(figure(3),strcat(chemin_curves,fichier,'-translation.png' ))
savefig(figure(3),strcat(chemin_curves,fichier,'-translation'))

%%
%PLOT TRANSLATION SPEED
inc=50;
%calculate dérivée
speed_tx=diff(centroid_t(1,:))*60;
speed_ty=diff(centroid_t(2,:))*60;
speed_t=sqrt(speed_tx.^2+speed_ty.^2);
figure(4)
plot(t(1,2+marge:inc:end),speed_t(1,marge:inc:end-1),'red-')
xlabel('Time (s)')
ylabel('Deplacement speed (mm/s)')
title('Deplacement speed function of Time')
exportgraphics(figure(4),strcat(chemin_curves,fichier,'-speed.png' ))
savefig(figure(4),strcat(chemin_curves,fichier,'-speed'))

%%
%PLOT SURFACE AND FIT
inc=50;
surface_ts=smooth(surface_t);

interpol2=polyfit(t(1,marge:ends),surface_ts(marge:ends,1),1);
interpol2_points=polyval(interpol2,t(1,marge:end));

figure(5)
%plot(t(1,marge:inc:ends),surface_t(1,marge:ends),'blue+','DisplayName','Surface')
hold on
plot(t(1,marge:inc:ends),surface_ts(marge:inc:ends,1),'blue+','DisplayName','Surface')
plot(t(1,marge:inc:ends),interpol2_points(1,marge:inc:ends),'red-','DisplayName','Linear regression')
hold off
legend
xlabel('Time (s)')
ylabel('Surface (pix2)')
title('Surface function of Time and linear regression')
exportgraphics(figure(5),strcat(chemin_curves,fichier,'-surface.png' ))
savefig(figure(5),strcat(chemin_curves,fichier,'-surface'))

%%
%PLOT SURFACE VARIATION AND FIT

%calculate dérivées
surface_var_ts=diff(surface_ts)*60;
interpol2_d=diff(interpol2_points)*60;
surface_var_moy=mean(surface_var_ts);
surface_var_moy=surface_var_moy*ones(1,n);

figure(6)
plot(t(1,1+marge:inc:ends),surface_var_ts(marge:inc:ends-1,1)*(60/470)^2,'blue+','DisplayName','Surface variation')
hold on
plot(t(1,1+marge:inc:ends),interpol2_d(1,marge:inc:ends-1)*(60/470)^2,'red-','DisplayName','Linear regression')
plot(t(1,1+marge:inc:ends),surface_var_moy(1,marge:inc:ends-1)*(60/470)^2,'green-','DisplayName',strcat('Surface variation mean (=',num2str(surface_var_moy(1),2),')'))

hold off
legend
xlabel('Time (s)')
ylabel('Surface variation (mm2/s)')
title('Surface variation function of Time and linear regressions')
exportgraphics(figure(6),strcat(chemin_curves,fichier,'-surface_variation.png' ))
savefig(figure(6),strcat(chemin_curves,fichier,'-surface_variation' ))




