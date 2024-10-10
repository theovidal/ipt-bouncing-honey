function [G,VP,VecP,MG]=point_2_inertia(V,fig)
%
% USE: [VecP,VP,G]=point_2_inertia(V,fig);
%
% GOAL: from a set of points in 2D or 3D (V) calculates the center of mass
% coordinates (G), the eigen values (VP) and the eigen vectors (VecP) of
% the inertia matrix MG
%
% INPUTS:
%  - V: a 2D or 3D set of points
%  - fig: a boolean set to numfig~=0 if figure is required
%
% OUTPUTS:
%  - G: the center of mass coordinates
%  - VP: the eigen values as a diagonal matrix
%  - VecP: a full matrix whose columns are the corresponding eigenvectors
%  - MG: the inertia matrix
%
% History of modifications:
% 111017: created by R. Monchaux for 3D data
% 120827: modified to support 2D and 3D data
%
G=mean(V);
if length(G)==3
    % V in center of mass referential:
    W=V-(G'*ones(length(V),1)')';
    % inertia matrix:
    A=sum(W(:,2).^2+W(:,3).^2);
    B=sum(W(:,1).^2+W(:,3).^2);
    C=sum(W(:,1).^2+W(:,2).^2);
    D=sum(W(:,2).*W(:,3));
    E=sum(W(:,1).*W(:,3));
    F=sum(W(:,1).*W(:,2));
    MG=[[A -F -E];[-F B -D];[-E -D C]];
    [VecP,VP] = eig(MG);
    %
    if fig
        VecP2=VecP*VP*0.1;
        figure(fig);hold on
        plot3(V(:,1),V(:,2),V(:,3),'*')
        axis equal
        axis(reshape(reshape([min(V); max(V)],3,2),6,1)')
        for i=1:3
            plot3([G(1) G(1)+VecP2(1,i)],[G(2) G(2)+VecP2(2,i)],[G(3) G(3)+VecP2(3,i)],'Color',[i/3 1-i/3 0])
        end
    end
elseif length(G)==2
    % V in center of mass referential:
    W=V-(G'*ones(length(V),1)')';
    % inertia matrix:
    A=sum(W(:,2).^2);
    B=sum(W(:,1).^2);
    F=sum(W(:,1).*W(:,2));
    MG=[[A -F];[-F B]];
    [VecP,VP] = eig(MG);
    %
    if fig
        VecP2=VecP*VP*0.1;
        figure(fig);hold on
        plot(V(:,1),V(:,2),'*')
        axis equal
        axis(reshape(reshape([min(V); max(V)],2,2),4,1)')
        for i=1:2
            plot([G(1) G(1)+VecP2(1,i)*10],[G(2) G(2)+VecP2(2,i)*10],'Color',[i/3 1-i/3 0])
        end
    end
end