clc
close all
clear;
set(0,'defaultTextInterpreter','latex');
% load("mode1.mat");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 v = VideoReader('intermediaire_1.mp4')
 N = floor(v.FrameRate*v.Duration) 
 variables_a_effacer = {'A','A_crop','Z','closeZ','CC','S','Caracteristiques_objets'};
 k=1;
 
 vt = VideoWriter('toto.mp4');
      vt.Quality = 100;
      open(vt);
for II = 1000:1400
 t=II/v.FrameRate;
    ima = read(v,II);
    A = ima(:,:,:);
    A_crop = A(1200:1500,700:3000,1); %zoomer sur la région 
    Z = A_crop>120;
    CC = bwconncomp(Z,8);
    S  = regionprops(CC,'Centroid'); % détermine leurs centre
    numPixels = cellfun(@numel,CC.PixelIdxList); % détermine leurs nombre de pixel
    Caracteristiques_objets(1,:) = numPixels;
   for j=1:CC.NumObjects 
        Caracteristiques_objets(2,j) = S(j).Centroid(1); % position du centre en hauteur
        Caracteristiques_objets(3,j) = S(j).Centroid(2); % position du centre en largeur
    end
  Caracteristiques_objets = sortrows(Caracteristiques_objets',[-1 -2 -3])'; %%% On les ordonne en fonction de leur surface
   %%%%%%%%% Normalement le plus gros objet est le pendule... 
     surf(k) = Caracteristiques_objets(1,1);
     x(k) = Caracteristiques_objets(2,1);
     y(k) = Caracteristiques_objets(3,1);
     temps(k) = t;
     k=k+1;
     subplot(1,3,1)
     J = imrotate(Z,-90);
     imshow(J)
     subplot(1,3,2:3)
     plot(temps,surf,'r','LineWidth',2)
     ylabel('Area [pixels]','FontSize',18,'FontWeight','bold','Color','k')
     xlabel(  'Time  [sec]','FontSize',18,'FontWeight','bold','Color','k')
     title("Honey trickle dynamics")
     axis([16 24 0 9e4]);
     frame = getframe(gcf);
     writeVideo(vt,frame);
     pause(0.01);
     clear(variables_a_effacer{:});
end
%  close(vt);
