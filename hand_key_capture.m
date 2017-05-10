%Initial commands to reset/initialize everything
clear all;
close all;
clc;
fontSize = 14;
run = true;

%Thresholds for blue glove color
hueThresholdLow = 0.4;
hueThresholdHigh = 0.6;
saturationThresholdLow = 0.2;
saturationThresholdHigh = 0.7;
valueThresholdLow = 0.6;
valueThresholdHigh = 1.0;
%End

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
imwrite(binaryHand, 'Images/hand_key', 'jpg');

clear vid;