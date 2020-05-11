%cd 'C:/Users/junior/Dropbox/mestrado/IA/Trabalho 3/pso_3/'
%run('C:\Users\junior\Dropbox\mestrado\IA\Trabalho 3\pso_3\pso.m')
%close all
clear
clc

im1=imread('quadrado.bmp');

im2=imread('Formas.bmp');

% converte para níveis de cinza
if size(im1,3)==3
    image1=rgb2gray(im1);
end
if size(im2,3)==3
    image2=rgb2gray(im2);
end

% check which one is target and which one is templete
if size(image1)>size(image2)
    Target=image1;
    Template=image2;
else
    Target=image2;
    Template=image1;
end

%Target = im2double(Target);
%Template = im2double(Template);

% read both images sizes
[l1,c1]=size(Target);
[l2,c2]=size(Template);

% mean of the template
%image22= Template - mean(mean(Template)); % Template menos o valor médio da imagem

swarm_size = 100;%floor(((l1*c1)/(l2*c2))/2);
iterations = 100; % calibrar depois
inertia = 0.9; % deve ser 
correction_factor = 2.5;% pag 77 c1 = c2 = 2
correction_factor2 = 2.5;% pag 77 c1 = c2 = 2

% geração das partículas aleatórias
for i = 1 : swarm_size  %tirar valores duplicados.
  swarm(i, 1, 1) = floor((l1-l2)*rand) + floor(l2/2) + 1; % x
  swarm(i, 1, 2) = floor((c1-c2)*rand) + floor(c2/2) + 1; % y
end

swarm(:, 4, 1) = 1000; % best value so far
swarm(:, 2, :) = 0;    % initial velocity

for iter = 1 : iterations
  
  %figure,
  for part = 1 : swarm_size
    % evolui a partícula
    % posição_x nova  =  posição_x atual   + velocidade 
    swarm(part, 1, 1) = swarm(part, 1, 1) + swarm(part, 2, 1); %update x position
    % posição_y nova  =  posição_y atual   + velocidade 
    swarm(part, 1, 2) = swarm(part, 1, 2) + swarm(part, 2, 2); %update y position
  
    % cálculo do fitness
    imagem_recorte=Target(swarm(part, 1, 1) - floor(l2/2) : swarm(part, 1, 1) + ceil(l2/2) - 1 , swarm(part, 1, 2) - floor(c2/2) : swarm(part, 1, 2) + ceil(c2/2) - 1); 
    fitness = 1 - corr2(imagem_recorte,Template);
        
    %subplot(ceil(sqrt(swarm_size)),ceil(sqrt(swarm_size)),part),imshow(imagem_recorte);title(fitness,'Color', 'b'); 
        
    % se o fintness é melhor atualiza pbest    
    if fitness < swarm(part, 4, 1)                % if new position is better
        swarm(part, 3, 1) = swarm(part, 1, 1);    % pbest x
        swarm(part, 3, 2) = swarm(part, 1, 2);    % pbest y
        swarm(part, 4, 1) = fitness;              % and best value
    end    
  end
  %subplot(ceil(sqrt(swarm_size)),ceil(sqrt(swarm_size)),part +1),imshow(Template);title((1-corr2(Template,Template)));    
  
  [temp, gbest] = min(swarm(:, 4, 1)); % global best position
  
  if temp == 0 % se o fitness é zero termina a execução
    break
  end

  %--- updating velocity vectors
  for i = 1 : swarm_size
    %                        velocidade atual  +  componente cognitivo                                  + componente social
    veloc_x = floor(inertia*swarm(i, 2, 1) + correction_factor*rand*(swarm(i, 3, 1) - swarm(i, 1, 1)) + correction_factor2*rand*(swarm(gbest, 3, 1) - swarm(i, 1, 1)));   %x velocity component
    veloc_y = floor(inertia*swarm(i, 2, 2) + correction_factor*rand*(swarm(i, 3, 2) - swarm(i, 1, 2)) + correction_factor2*rand*(swarm(gbest, 3, 2) - swarm(i, 1, 2)));   %y velocity component        
    
    % velocidade x
    %     menor ou igual ao limite superior     e    menor ou igual ao limite inferior
    if (swarm(i, 1, 1) + veloc_x <= l1 - l2/2) && (swarm(i, 1, 1) + veloc_x >= l2/2 + 1)
      swarm(i, 2, 1) = veloc_x;
    elseif (swarm(i, 1, 1) + veloc_x <= l1 - l2/2) % está menor que o limite inferior 
        swarm(i, 2, 1) = floor(l2/2) + 1 - swarm(i, 1, 1);% + floor(swarm(gbest, 3, 1)*rand-1);
      else % está maior que o limite superior 
        swarm(i, 2, 1) = l1 - floor(l2/2) - swarm(i, 1, 1);% - floor(swarm(gbest, 3, 1)*rand+1) ;
    end  

    % velocidade y
    %     menor ou igual ao limite superior     e    menor ou igual ao limite inferior
    if (swarm(i, 1, 2) + veloc_y <= c1 - c2/2) && (swarm(i, 1, 2) + veloc_y >= c2/2 + 1)
      swarm(i, 2, 2) = veloc_y;
    elseif (swarm(i, 1, 2) + veloc_y <= c1 - c2/2)% está menor que o limite inferior
        swarm(i, 2, 2) = floor(c2/2) + 1 - swarm(i, 1, 2);% + floor(swarm(gbest, 3, 2)*rand-1);
      else
        swarm(i, 2, 2) = c1 - floor(c2/2) - swarm(i, 1, 2);% - floor(swarm(gbest, 3, 2)*rand+1);
    end 

    %% Plotting the swarm
    %clf    
    %plot(swarm(:, 1, 1), swarm(:, 1, 2), 'x')   % drawing swarm movements
    %axis([-2 450 -2 450]);
    %pause(.01)    
  end    
   
end  

%imagem_escolhida=Target(swarm(gbest, 1, 1) - floor(l2/2) : swarm(gbest, 1, 1) + floor(l2/2) - 1 , swarm(gbest, 1, 2) - floor(c2/2) : swarm(gbest, 1, 2) + floor(c2/2) - 1); 
%figure,
%subplot(1,1,1),imshow(imagem_escolhida);title(temp,'Color', 'b'); 
disp(temp);

%swarm(:, 4, 1) % vetor de fitness
%swarm(:, 2, 1) % velocidade x
%swarm(:, 2, 2) % velocidade y
%swarm(:, 3, 1) % pbest x
%swarm(:, 3, 2) % pbest y