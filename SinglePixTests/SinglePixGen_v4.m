%Borramos todas las variables antes de empezar
clear all

%Cargo los paquetes que necesito
pkg load signal
pkg load instrument-control

%Leo una imagen. Solo un canal porque es blanco y negro.
Img = double(imread("./pic2.png")(:,:,1));
ImgSize = size(Img);
n=prod(ImgSize);

%Abro comunicacion por puerto serie con Arduino
s=serial("/dev/ttyACM0",115200,1);
sleep(3);
[data, count] = srl_read(s,10);
sleep(1)


%N = 450; %Numero de muestras
N = round(prod(ImgSize)*0.4);
Mask = zeros(N, prod(ImgSize));
MaskedImg = zeros(N, prod(ImgSize));
Intensity = zeros(N,1);
FakeIntensity = zeros(N,1);

figure(1);
h1=imshow(Img);
f2 = figure(2)
h2=imshow(Img);


for i=1:N
  A = double(rand(ImgSize(1), ImgSize(2))>0.6);
  Mask(i,:) = A(:);
  B = Img .* A;
  MaskedImg(i,:) = B(:);
  %figure(1)
  %imshow(B)
  set(h1, 'cdata', B)
  refresh()
  
  meanB = ones(size(B)) * round(mean(B(:)));
  meanB(1,1) = 0; meanB(1,2) = 255;
    %imshow(meanB/255)
    %pause(1)
  %Leer Arduino
  dato=0;
  for j = 1:3
    srl_write(s, "R");
    %pause(0.1);
    [data, count] = srl_read(s,20);
  endfor 
    dato = str2double(char(data));
  %dato /= 5;
  %Guardo el valor de intensidad en el vector Intensity
  Intensity(i) = dato;
  
    %Intensity(i) = round(mean(B(:)));
  FakeIntensity(i) = (mean(B(:)));
  
  tmpMask = Mask(1:i,:);
  tmpIntense = Intensity(1:i);
  Result = tmpMask \ tmpIntense;
  Result = Result + abs(min(Result(:)));
  Result = Result/max(Result(:));
  ImgResult = reshape(Result, ImgSize);
  %figure(2)
  set(h2, 'cdata', ImgResult)
  set(f2, 'name', num2str(i))
  %imshow(ImgResult)
  
  if( mod(i, 10) > 0 )
  Theta = zeros(i,n);
  for ii = 1:n
      ii;
      ek = zeros(1,n);
      ek(ii) = 1;
      psi = dct(ek)';
      Theta(:,ii) = tmpMask*psi;
  end

  %___l2 NORM SOLUTION___ s2 = Theta\y; %s2 = pinv(Theta)*y
  s2 = pinv(Theta)*tmpIntense;
  %___BP SOLUTION___
  s1 = l1eq_pd(s2,Theta,Theta',tmpIntense,5e-3,20); % L1-magic toolbox

  x1 = zeros(n,1);
  for ii = 1:n
      ii;
      ek = zeros(1,n);
      ek(ii) = 1;
      psi = idct(ek)';
      x1 = x1+psi*s1(ii);
  end
  endif
  x1=x1+abs(min(x1));
  x1=x1/max(x1);
  ImgResult = reshape(x1, ImgSize);
  figure(3)
  imshow(ImgResult)
endfor


fclose(s)


Result = Mask\Intensity;
Result = Result + abs(min(Result(:)));
Result = Result/max(Result(:));
ImgResult = reshape(Result, ImgSize);
figure(2)
imshow(ImgResult)


figure(4)
plot( FakeIntensity, Intensity, "*")
