clc
clear;
%set(0,'defaultTextInterpreter','latex');
fichier = 'video test.mp4';
repert  = './assets/';
chemin = strcat(repert,fichier);
 Y1 = 200;
 Y2 = 350;
 X2 = 350;
 X1 = 200;
     R(1,1) = X1;
     R(1,2) = Y2;
     R(2,1) = X1;
     R(2,2) = Y1;
     R(3,1) = X2;
     R(3,2) = Y1;
     R(4,1) = X2;
     R(4,2) = Y2;
Naim=4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c(1,:) = [0.0 0.0 0.0]   % Noir = non attiré par un aimant
c(2,:) = [0 152/255 70/255] % Vert    : aimant 1
c(3,:) = [0.0 0.0 1.0]      % Bleu    : aimant 2
c(4,:) = [1.0 0.0 0.0]      % rouge   : aimant 3
c(5,:) = [1.0 0.0 1.0]      % magenta   : aimant 4
c(6,:) = [1.0 1.0 0.0]      % jaune   : aimant 5
c(7,:) = [1.0 0.0 1.0]      % magenta : aimant 6
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 v = VideoReader(chemin)
      vt = VideoWriter('toto.mp4');
      vt.Quality = 100;
      open(vt);
   N = floor(v.FrameRate*v.Duration) 
 
  variables_a_effacer = {'A','A_crop','Z','CC','S','Caracteristiques_objets'};
for II = 1:500
i=II+2000;
t=II/v.FrameRate;
ima = read(v,i);
A=ima(:,:,1);
A_crop = A(70:630,400:950);
Z = A_crop>50;
CC = bwconncomp(Z,8);
S  = regionprops(CC,'Centroid'); % détermine leurs centre
             numPixels = cellfun(@numel,CC.PixelIdxList); % détermine leurs nombre de pixels
             Caracteristiques_objets(1,:) = numPixels;
for j=1:CC.NumObjects 
             Caracteristiques_objets(2,j) = S(j).Centroid(1); % position du centre en hauteur
             Caracteristiques_objets(3,j) = S(j).Centroid(2); % position du centre en largeur
end
Caracteristiques_objets = sortrows(Caracteristiques_objets',[-1 -2 -3])'; %%% On les ordonne en fonction de leur surface
%%%%%%%%% Normalement le plus gros objet est le pendule... 
   x(II) = Caracteristiques_objets(2,1);
   y(II) = Caracteristiques_objets(3,1);
 plot(x,y,'k','LineWidth',2)
 set(gca, 'YDir','reverse')
 hold on ;
  for n=1:Naim
    scatter(R(n,1),R(n,2),400,'filled',...
        'MarkerEdgeColor',c(n+1,:),...
        'MarkerFaceColor',c(n+1,:),...
        'MarkerFaceAlpha',0.6)
  end
  ylabel('$y$ [cm]','FontSize',18,'FontWeight','bold','Color','k')
  xlabel('$x$  [cm]','FontSize',18,'FontWeight','bold','Color','k')
 axis([100 450 100 450]);
 texte = strcat('t = ',num2str(t),' s');
 text(110,430,texte,'Color','black','FontSize',20)
              frame = getframe;
              writeVideo(vt,frame);
              pause(0.1);
hold off
clf
clear(variables_a_effacer{:});
 end
 close(vt);