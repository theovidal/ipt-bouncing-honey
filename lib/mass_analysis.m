clc;
clear;
close all;

repert_data='./data/';
folders={'./moules/'};
cd 'videos_cement'
for i=1:size(folders,1)
    cd(folders{i,:})
    files=ls;
    cd ..
    for k=3:size(files,1)
        files(k,:)
        [filepath,name,ext]=fileparts(files(k,:));
        if size(ext)~=0 
            if ext(1:4)=='.mp4' 
                Object_Dynamic(name,strcat(folders{i,:},'/'),strcat('./courbes/',folders{i,:},'-curves/'));
            end
        end
    end
    
end
cd ..