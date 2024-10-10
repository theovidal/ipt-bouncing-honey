
%function Object_Dynamic(fichier,repert,repert_curves,repert_data)
clc;
close all;
clear
%--------------------------------------------------------------------------
%                               OPEN VIDEO
%--------------------------------------------------------------------------

t1=datetime('now');
% 
fichier='r1';
repert  = './videos_cement/moules/';
repert_curves='./courbes/etude moules-curves/';
repert_data='./data/';

chemin = strcat(repert,fichier,'.mp4');
chemin_curves=strcat(repert_curves,fichier,'-curves/');

v = VideoReader(chemin);
%vt = VideoWriter('toto.mp4');
% vt.Quality = 100;
% open(vt);
N = floor(v.FrameRate*v.Duration)-10; 

%-------------------------------------------------------------------------
%                       PARAMETERS INITIALISATION
%-------------------------------------------------------------------------

ini=30;
fin=N;


%vecteur temporel
duree=fin-ini+1;
ini_t=ini/v.FrameRate;
fin_t=fin/v.FrameRate;
t=linspace(ini_t,fin_t,duree);
%t=linspace(1,v.Duration,N);
%t=ini:fin;

%mesured parameters
alpha_t=zeros(1,duree);
centroid_t=zeros(2,duree);
surface_t=zeros(1,duree);

%open export file
mkdir (chemin_curves);
file=fopen(strcat(chemin_curves,fichier,'-DATA.txt'),'w');
fprintf(file,'Parameters :');
fprintf(file,'Rotation cumulée (°) ; CentroidX (px) ; CentroidY (px) ; Surface (px) ; Temps (s) \n');

%--------------------------------------------------------------------------
%                           DETERMINE CROP
%--------------------------------------------------------------------------

%read image
ima = read(v,ini);
A=ima(:,:,3);

Z_crop=A>120;

%connexe areas
CC_crop = bwconncomp(Z_crop,8);
%get points
points_crop=regionprops(CC_crop,'PixelList');
%get bigger connexe area
sizes=ones(1,size(points_crop,1));
for j=1:size(points_crop,1)
    sizes(j)=size(points_crop(j).PixelList,1);
end
[M,i_crop]=max(sizes);
cristalisoir_points=points_crop(i_crop).PixelList;

%transform points into binary array
%POUR OBENTIR CROP
matrice_cristalisoire=zeros(1080,1920);
for k=1:size(cristalisoir_points,1)
    matrice_cristalisoire(cristalisoir_points(k,2),cristalisoir_points(k,1))=1;
end

%auto crop
crop=regionprops(matrice_cristalisoire,'BoundingBox').BoundingBox;
crop=floor(crop)+1;
matrice_cristalisoire=ones(1080,1920);
for k=1:size(cristalisoir_points,1)
    matrice_cristalisoire(cristalisoir_points(k,2),cristalisoir_points(k,1))=0;
end


%--------------------------------------------------------------------------
%                           LOOP INITIALISATION
%--------------------------------------------------------------------------

%binarisation image cristalisoire
if crop(4)+crop(2)>1080
    surplus=crop(4)+crop(2)-1080;
    crop(4)=crop(4)-surplus;
end
if crop(3)+crop(1)>1920
    surplus=crop(3)+crop(1);
    crop(3)=crop(3)-surplus;
end
Z = matrice_cristalisoire(crop(2):(crop(4)+crop(2)),crop(1):(crop(3)+crop(1)));
%connexe areas
CC = bwconncomp(Z,8);
%get points
points=regionprops(CC,'PixelList');
%get centroid
centroids=regionprops(CC,'Centroid');
%get surface
surfaces=regionprops(CC,'Area');

%get bigger connexe area which correspond to the cement droplet
sizes=ones(1,size(points,1));
for j=1:size(points,1)
    sizes(j)=size(points(j).PixelList,1);
end
%[M,i_cement]=max(sizes);
sizes_s=sort(sizes,'descend');
for j=1:size(points,1)
    if size(points(j).PixelList,1)==sizes_s(2)
        i_cement=j;
    end
end
cement_pixels=points(i_cement).PixelList;

centroid_t(1,1)=floor(centroids(i_cement).Centroid(1));
centroid_t(2,1)=floor(centroids(i_cement).Centroid(2));

surface_t(1)=surfaces(i_cement).Area;
 
%calculate inertia matrix with point_2_inertia file from Romain Monchaux
[G,VP,VecP,MG]=point_2_inertia(cement_pixels,0);
%For initialization, calculate angle with x axis
VecP_a=VecP;
refx=[1;0];
%get angle
alpha_t(1) = 0;

fprintf(file,'%f %d %d %d %f \n',alpha_t(1),centroid_t(1,1),centroid_t(2,1),surface_t(1),t(1));

%--------------------------------------------------------------------------
%                               LOOP
%--------------------------------------------------------------------------

inc=8;
increment=2;
for k=ini+1:fin
    if mod(k,inc)==0

    ima = read(v,k);
    A=ima(:,:,3);
    %A_crop = A(712:1333,349:873); %test 1
    A_crop=A(crop(2):(crop(4)+crop(2)),crop(1):(crop(3)+crop(1)));
    %A_crop = A(1:1501,191:774);
    %binarisation image, take black values in black&white image
    Z = A_crop<80;
    %imshow(Z)
    %connexe areas
    CC = bwconncomp(Z,8);
    %get points
    points=regionprops(CC,'PixelList');
    %get centroid
    centroids=regionprops(CC,'Centroid');
    %get surface
    surfaces=regionprops(CC,'Area');

    %get bigger connexe area
    sizes=ones(1,size(points,1));
    for j=1:size(points,1)
        sizes(j)=size(points(j).PixelList,1);
    end
    [M,i_cement]=max(sizes);

    cement_pixels=points(i_cement).PixelList;
    centroid_t(1,k-ini+1)=floor(centroids(i_cement).Centroid(1));
    centroid_t(2,k-ini+1)=floor(centroids(i_cement).Centroid(2));
    surface_t(k-ini+1)=surfaces(i_cement).Area;

    %calculate inertia matrix with point_2_inertia file from Romain
    %Monchaux
    [G,VP,VecP,MG]=point_2_inertia(cement_pixels,0);
    
    %prevents vectors from changing into the opposite vector which is a
    %symptome from point_2_intertia function
    VecP_clean=VecP;
    if dot(VecP(:,1),VecP_a(:,1))<0  
        VecP_clean(:,1)=-VecP(:,1);
    elseif dot(VecP(:,2),VecP_a(:,2))<0
        VecP_clean(:,2)=-VecP(:,2);
    
    end
%     VecP2=VecP_clean*VP*0.1;
%         figure(20);hold on
%         axis equal
%         for i=1:2
%             plot([0 VecP2(1,i)*10],[0 VecP2(2,i)*10],'Color',[i/3 1-i/3 0])
%         end
%     
    %get angle with previous vector VecP_a

    %alpha_t(k)=atan2(norm(cross([VecP(:,1);0],[refx;0])), dot([VecP(:,1);0],[refx;0]));
    %alpha_t(k-ini+1) = alpha_t(k-ini) + acos(dot(VecP_clean(:,1), VecP_a(:,1))/(norm(VecP_clean(:,1))*norm(VecP_a(:,1)))) *180/pi;
        alpha_t(increment) = alpha_t(increment-1) + acos(dot(VecP_clean(:,1), VecP_a(:,1))/(norm(VecP_clean(:,1))*norm(VecP_a(:,1)))) *180/pi;
    
    
    VecP_a=VecP_clean;
    
    %write in text file
    %fprintf(file,'%d %d %d %d %d \n',alpha_t(k-ini+1),centroid_t(1,k-ini+1),centroid_t(2,k-ini+1),surface_t(k-ini+1),t(k-ini+1));
    fprintf(file,'%d %d %d %d %d \n',alpha_t(increment),centroid_t(1,increment),centroid_t(2,increment),surface_t(increment),t(k-ini+1));
    increment=increment+1;

    end
end
%close(vt)
fclose(file);

copyfile(strcat(chemin_curves,fichier,'-DATA.txt'),"C:\Users\salad\Documents\etudes\Ing_1A\IPT\script_traitement_rotation\data");

t2=datetime('now');
simulation_duration=between(t1,t2)
%--------------------------------------------------------------------------
%                           PLOT
%--------------------------------------------------------------------------

plot_from_txt(fichier,repert_data,repert_curves)

