
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

%masses en mg des videos ethi.png (i un int). -1 correspond à une absence de données.
eth_masses=[60.7 -1 136.3 11.2 5.2 28.9 8.4 32.6 60.1 19.8 12.6 40.3 44.8 20.7 34.5 45.8 41.1 67.7 66.5 26.1];
%ethanol proportion en % pour eth7-20
prop=[17 17 17 17 17 17 -1 25 25 25 12.5 12.5 12.5 6.25 6.25 6.25 6.25 3 3 3];
prop_e=prop*0.01;
prop_w=1-prop_e;
%Température en K
T=23.4+273.15;
%tension surface eau et ethanol en N/m
sigma_w=72.15e3;
sigma_e=22.07e3;
%conversion en tension de surface du mix eau/ethanol
sigma=exp(prop_w*log(sigma_w)+prop_e*log(sigma_e)-488.012*(prop_w.*prop_e/T)-640.785*(prop_w.*prop_e.*(prop_w-prop_e)/T)-1073.310*(prop_w.*prop_e.*(prop_w-prop_e).^2)/T);


%Load variables from data files
for i=1:N
    cd(repert_data)
    files=ls;
    cd ..
    for j=3:size(files,1)
        [filepath,name,ext]=fileparts(files(j,:));
        if size(name)==size(strcat('eth',num2str(i),'-DATA'))
            if name==strcat('eth',num2str(i),'-DATA')
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
for i=8:N
    if i~=14
        alpha_ts=smooth(alpha_t{i});
    
        %PLOT ANGULAR DATA AND FITS
        %surface_m=mean(surface_t{i});
        n=size(alpha_ts,1);
        if n<ends
            plot(t{i}(marge:inc:n),alpha_ts(marge:inc:n,1),form(i),'Color',colors(i),'DisplayName',strcat('Prop eth',num2str(i)," ",num2str(prop(i)),' %'))
            %fit linéaire
            interpol{i}=polyfit(t{i}(1,marge:n),alpha_ts(marge:n,1),1);
            interpol_points=polyval(interpol{i},t{i}(1,marge:end));
            %plot fit
            plot(t{i}(1,marge:end-1),interpol_points(1,marge:end),'-','Color',colors(i),'DisplayName',strcat('Fit',num2str(i)))
        else
            plot(t{i}(marge:inc:ends),alpha_ts(marge:inc:ends,1),form(i),'Color',colors(i),'DisplayName',strcat('Prop eth',num2str(i)," ",num2str(prop(i)),' %'))
            %fit linéaire
            interpol{i}=polyfit(t{i}(1,marge:ends),alpha_ts(marge:ends,1),1);
            interpol_points=polyval(interpol{i},t{i}(1,marge:end));
            %plot fit
            plot(t{i}(1,marge:ends),interpol_points(1,marge:ends),'-','Color',colors(i),'DisplayName',strcat('Fit',num2str(i)))
        end
    end
end
hold off
legend
xlabel('Temps (s)')
ylabel('Rotation (°)')
title('Rotations en fonction du temps et fits linéaires pour différentes prop eth')
exportgraphics(figure(1),'./courbes/etude ethanol-curves/rotation pour différentes prop eth.png')
savefig(figure(1),'./courbes/etude ethanol-curves/rotation pour différentes prop eth')

%PLOT SPEED

figure(2)
cste=zeros(1,ends);
speeds=zeros(1,N);
hold on
for i=8:N
    if i~=14
        n=size(alpha_t{i},2);
        if n<ends
            cste(1,:)=interpol{i}(1);
            speeds(i)=interpol{i}(1);
            plot(t{i}(marge:inc:n),cste(1,marge:inc:n),form(i),'Color',colors(i),'DisplayName',strcat('Prop eth',num2str(i)," ",num2str(prop(i)),' %'))
        else
            cste(1,:)=interpol{i}(1);
            speeds(i)=interpol{i}(1);
            plot(t{i}(marge:inc:ends),cste(1,marge:inc:ends),form(i),'Color',colors(i),'DisplayName',strcat('Prop eth',num2str(i)," ",num2str(prop(i)),' %'))
        end
    end
end
hold off
legend
xlabel('Temps (s)')
ylabel('Vitesse (°/s)')
title('Vitesses angulaires en fonction du temps des fits linéaires différentes prop eth')
exportgraphics(figure(2),'./courbes/etude ethanol-curves/vitesse angulaire pour différentes prop eth.png')
savefig(figure(2),'./courbes/etude ethanol-curves/vitesse angulaire pour différentes prop eth')
%%
%PLOT SPEED FUNCTION OF prop eth
%clean speeds (remove aberrant points)
clean_speeds=[4.1333 12.4024 166.7763 176.9104 205.6245 406.2196 271.3846 715.6431 846.7836 810.3392];
clean_prop=[25 25 12.5 12.5 12.5 6.25 6.25 3 3 3];
clean_sigma=[2.7162 2.7162 3.4840 3.4840 3.4840 4.6300 4.6300 5.7006 5.7006 5.7006]*10^4;

figure(3)
plot(clean_sigma,clean_speeds,'blue+')
xlabel('Surface tension (N/m)')
ylabel('Angular speed (°/s)')
title('Angular speed function of surface tension')
exportgraphics(figure(3),'./courbes/etude ethanol-curves/vitesse angulaire en fonction de la prop eth.png')
savefig(figure(3),'./courbes/etude ethanol-curves/vitesse angulaire en fonction de la prop eth')


figure(4)
clean_prop_l=log(clean_sigma);
clean_speeds_l=log(clean_speeds);
hold on
plot(clean_prop_l,clean_speeds_l,'blue+','DisplayName','Data')
[interpol_log,S]=polyfit(clean_prop_l(1,3:end),clean_speeds_l(1,3:end),1);
interpol_points=polyval(interpol_log,clean_prop_l);
R2=1 - (S.normr/norm(clean_speeds_l(1,3:end) - mean(clean_speeds_l(1,3:end))))^2

plot(clean_prop_l,interpol_points,'r-','DisplayName',strcat("Fit linéaire pente : ",num2str(interpol_log(1))))
legend
xlabel('log(Surface tension (N/m))')
ylabel('log(Angular speed (°/s))')
title('Angular speed function of surface tension log scale')
exportgraphics(figure(4),'./courbes/etude ethanol-curves/vitesse angulaire en fonction de la prop eth log.png')
savefig(figure(4),'./courbes/etude ethanol-curves/vitesse angulaire en fonction de la prop eth log')

