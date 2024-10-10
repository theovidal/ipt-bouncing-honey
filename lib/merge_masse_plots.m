%%
clc;
clear;
close all;

repert_data='./data/';

%nombre d'expérience à traiter
N=20;
%cells des variables pour chaque expérience
alpha_t=cell(1,N);
surface_t=cell(1,N);
centroid_t=cell(1,N);
t=cell(1,N);

%masses en mg des videos massei.png (i un int). -1 correspond à une absence de données.
masses=[-1 21.5 -1 63.7 48.4 72.3 95.7 176.5 22.7 153.8 62.0 29.4 -1 218.0 118.1 99.1 48.0 28.3 66.8 22.9];

%Load variables from data files
for i=1:N
    cd(repert_data)
    files=ls;
    cd ..
    for j=3:size(files,1)
        [filepath,name,ext]=fileparts(files(j,:));
        if size(name)==size(strcat('masse',num2str(i),'-DATA'))
            if name==strcat('masse',num2str(i),'-DATA')
                file=fopen(strcat(repert_data,name,'.txt'),'r');
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
                alpha_t{i}=zeros(1,n);
                surface_t{i}=zeros(1,n);
                centroid_t{i}=zeros(1,n);
                t{i}=zeros(1,n);
                
                %extract data
                for k=1:n
                    line = strip(fgetl(file));
                    line_data=regexp(line,' ','split');
                    alpha_t{i}(k)=str2double(line_data{1});
                    centroid_t{i}(1,k)=str2double(line_data{2});
                    centroid_t{i}(2,k)=str2double(line_data{3});
                    surface_t{i}(k)=str2double(line_data{4});
                    t{i}(k)=str2double(line_data{5});
                end
                
                fclose(file);
            end
        end
    end
    
end
%%

%PLOT PARAMETERS

ends=20*60;
inc=50;
marge=2;
colors=["r" "g" "b" "c" "m" "y" "k" "#0072BD" "#D95319" "#A2142F" "#EDB120" "#7E2F8E" "#77AC30" "#4DBEEE" "r" "g" "b" "c" "m" "y"];
form=["+" "*" "o" "-" "x" "." "square" "diamond" "^" "v" "pentagram" "hexagram" "<" ">" "-." ":" "|" "_" "--" "o"];
%%
close all
%PLOT ROTATION

%interpolation linéaire
interpol=cell(1,N);

figure(1)
hold on
for i=1:N
    alpha_ts=smooth(alpha_t{i});

    %PLOT ANGULAR DATA AND FITS
    %surface_m=mean(surface_t{i});
    plot(t{i}(marge:inc:ends),alpha_ts(marge:inc:ends,1),form(i),'Color',colors(i),'DisplayName',strcat('Masse',num2str(i)," ",num2str(masses(i)),' mg'))
    
    %fit linéaire
    interpol{i}=polyfit(t{i}(1,marge:ends),alpha_ts(marge:ends,1),1);
    interpol_points=polyval(interpol{i},t{i}(1,marge:end));
    %plot fit
    plot(t{i}(1,marge:ends),interpol_points(1,marge:ends),'-','Color',colors(i),'DisplayName',strcat('Fit',num2str(i)))
end
hold off
legend
xlabel('Temps (s)')
ylabel('Rotation (°)')
title('Rotations en fonction du temps et fits linéaires pour différentes masses')
exportgraphics(figure(1),'./courbes/etude masse-curves/rotation pour 20 masses.png')
savefig(figure(1),'./courbes/etude masse-curves/rotation pour 20 masses')

%PLOT SPEED

figure(2)
cste=zeros(1,ends);
hold on
for i=1:N
    
    cste(1,:)=interpol{i}(1);
    plot(t{i}(marge:inc:ends),cste(1,marge:inc:ends),form(i),'Color',colors(i),'DisplayName',strcat('Masse',num2str(i)," ",num2str(masses(i)),' mg'))
end
hold off
legend
xlabel('Temps (s)')
ylabel('Vitesse (°/s)')
title('Vitesses angulaires en fonction du temps des fits linéaires pour différentes masses')
exportgraphics(figure(2),'./courbes/etude masse-curves/vitesse angulaire pour 20 masses.png')
savefig(figure(2),'./courbes/etude masse-curves/vitesse angulaire pour 20 masses')

%PLOT SPEED FUNCTION OF MASS

%clean order (see 'analyse rotations 20 masses.txt')
clean_masses=[22.7 28.3 22.9 29.4 62 99.1 72.3 176.5 118.1 95.7 218 153.8];
speeds=[1722 1338 1165 1067 949 855 660 607 498 487 407 367];

figure(3)
plot(clean_masses,speeds,'blue+')
xlabel('Masse (mg)')
ylabel('Vitesse angulaire (°/s)')
title('Vitesse angulaire des fits linéaires en fonction de la masse')
exportgraphics(figure(3),'./courbes/etude masse-curves/vitesse angulaire en fonction de la masse.png')
savefig(figure(3),'./courbes/etude masse-curves/vitesse angulaire en fonction de la masse')


figure(4)
clean_masses_l=log(clean_masses);
speeds_l=log(speeds);
hold on
plot(clean_masses_l,speeds_l,'blue+','DisplayName','Data')
[interpol_log,S]=polyfit(clean_masses_l,speeds_l(1,:),1);
interpol_points=polyval(interpol_log,clean_masses_l);
R2=1 - (S.normr/norm(speeds_l(1,:) - mean(speeds_l(1,:))))^2

plot(clean_masses_l,interpol_points,'r-','DisplayName',strcat("Fit linéaire pente : ",num2str(interpol_log(1))))
legend
xlabel('log(Mass (mg))')
ylabel('log(Angular speed (°/s))')
title('Angular speed function of mass in log scale')
exportgraphics(figure(4),'./courbes/etude masse-curves/vitesse angulaire en fonction de la masse log.png')
savefig(figure(4),'./courbes/etude masse-curves/vitesse angulaire en fonction de la masse log')

%%
close all

%PLOT SURFACE THAT DIMINISHES


%interpolation linéaire
interpol_surf=cell(1,N);

figure(5)
hold on
for i=[2 3 4 6 7 11 12 15 16 19 20]
    surface_ts=smooth(surface_t{i});
    %convert px to mm2
    surface_tsc=surface_ts*(60/470)^2;

    %PLOT ANGULAR DATA AND FITS
    %surface_m=mean(surface_t{i});
    plot(t{i}(marge:inc:ends),surface_tsc(marge:inc:ends,1),form(i),'Color',colors(i),'DisplayName',strcat('Masse',num2str(i)," ",num2str(masses(i)),' mg'))
    
    %fit linéaire en mm2
    interpol_surf{i}=polyfit(t{i}(1,marge:ends),surface_tsc(marge:ends,1),1);
    interpol_points=polyval(interpol_surf{i},t{i}(1,marge:end));
    %plot fit
    plot(t{i}(1,marge:ends),interpol_points(1,marge:ends),'-','Color',colors(i),'DisplayName',strcat('Fit',num2str(i)))
end
hold off
legend
xlabel('Temps (s)')
ylabel('Surface (mm2)')
title('Surface en fonction du temps et fits linéaires pour différentes masses')
exportgraphics(figure(5),'./courbes/etude masse-curves/surface pour 20 masses.png')
savefig(figure(5),'./courbes/etude masse-curves/surface pour 20 masses')

%PLOT SURFACE VARIATION ONLY IF VARIATION IS negative

figure(6)
cste=zeros(1,ends);
surface_speed=zeros(1,N);
hold on
for i=[2 3 4 6 7 11 12 15 16 19 20]
    cste(1,:)=interpol_surf{i}(1);
    surface_speed(i)=interpol_surf{i}(1);
    plot(t{i}(marge:inc:ends),cste(1,marge:inc:ends),form(i),'Color',colors(i),'DisplayName',strcat('Masse',num2str(i)," ",num2str(masses(i)),' mg'))

end
hold off
legend
xlabel('Temps (s)')
ylabel('Variation (mm2/s)')
title('Variation temporelle de la surface des fits linéaires pour différentes masses')
exportgraphics(figure(6),'./courbes/etude masse-curves/variation surface pour 20 masses.png')
savefig(figure(6),'./courbes/etude masse-curves/variation surface pour 20 masses')

figure(7)
plot(masses,surface_speed,'blue+')
xlabel('Mass (mg)')
ylabel('Surface variation (mm2/s)')
title('Surface variation function of mass')
exportgraphics(figure(7),'./courbes/etude masse-curves/vitesse surface en fonction de la masse.png')
savefig(figure(7),'./courbes/etude masse-curves/vitesse surface en fonction de la masse')


