%Initial commands to reset/initialize everything
clear all;
close all;
clc;
fontSize = 14;
run = true;

%Create the webcam object
vid = webcam(1);
pause(2);

get_image;

while numberOfMeasurements > 1
    if exitCode ~= true
        display('Not a good image. Please try again.');
        waitfor(msgbox('Not a good image. Please try again.'));
        close all;
        get_image;
    else
        close all;
        clear vid;
        return
    end
end

boundingBox = measurements(1).BoundingBox;
croppedHand = imcrop(img, boundingBox);
binaryHand = imcrop(coloredObjectsMask, boundingBox);
imshow(binaryHand);

% mkdir('Images');
answer = inputdlg('What do you want to call this image?');
location = strcat('Images/', answer{1});
imwrite(binaryHand, location, 'jpg');

clear vid;