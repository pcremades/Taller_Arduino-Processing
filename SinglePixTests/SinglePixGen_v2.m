%Borramos todas las variables antes de empezar
clear all

%Cargo los paquetes que necesito
pkg load signal
pkg load instrument-control

%Leo una imagen. Solo un canal porque es blanco y negro.
Img = double(imread("./pic2.png")(:,:,1));
ImgSize = size(Img);

%Abro comunicacion por puerto serie con Arduino
s=serial("/dev/ttyACM0",115200,1);
sleep(3);
[data, count] = srl_read(s,10);
sleep(1)


N = 550; %Numero de muestras
Mask = zeros(N, prod(ImgSize));
Intensity = zeros(N,1);
FakeIntensity = zeros(N,1);

figure(1);
h1=imshow(Img);
f2 = figure(2)
h2=imshow(Img);


for i=1:N
  A = double(rand(ImgSize(1), ImgSize(2))>0.5);
  Mask(i,:) = A(:);
  B = Img .* A;
  %figure(1)
  %imshow(B)
  set(h1, 'cdata', B)
  
  meanB = ones(size(B)) * round(mean(B(:)));
  meanB(1,1) = 0; meanB(1,2) = 255;
    %imshow(meanB/255)
  
  refresh()
  %pause(1)
  %Leer Arduino
  srl_write(s, "R");
  [data, count] = srl_read(s,20);
  srl_write(s, "R");
  [data, count] = srl_read(s,20);
  srl_write(s, "R");
  pause(0.3);
  [data, count] = srl_read(s,20);
  dato = str2double(char(data));
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
endfor


fclose(s)

Result = Mask\Intensity;
Result = Result + abs(min(Result(:)));
Result = Result/max(Result(:));
ImgResult = reshape(Result, ImgSize);
figure(2)
imshow(ImgResult)

figure(3)
plot( FakeIntensity, Intensity, "*")
