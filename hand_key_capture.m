%Initial commands to reset/initialize everything
clear all;
close all;
clc;
fontSize = 14;
count = 0;

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
preview(vid);

while (count ~= 200)
    display(count);
    
    img = snapshot(vid);
    %Wait for user to capture image
    % choice = questdlg('Press "capture" when you are ready to take a photo.', 'Take Picture', 'Capture', 'Cancel', 'Capture');
    % switch choice
    %     case 'Capture'
    %         img = snapshot(vid);
    %     case 'Cancel'
    %         return;
    % end

    %Break down original image into HSV values
    %and seperate hand usingthresholds
    hsvImage = rgb2hsv(img);
    hImage = hsvImage(:,:,1);
    sImage = hsvImage(:,:,2);
    vImage = hsvImage(:,:,3);
    hueMask = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
    saturationMask = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
    valueMask = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);

    %Putting it altogether into one image
    coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

    %Getting rid of excess pixels, smoothing borders, and filling regions
    smallestAcceptableArea = 100;
    coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
    structuringElement = strel('disk', 4);
    coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
    coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

    %Getting rectangle around hand region
    imshow(img);
    hold on;
    measurements = regionprops(coloredObjectsMask);
    numberOfRegions = size(measurements, 1);
    for k = 1 : numberOfRegions
        thisBox = measurements(k).BoundingBox;
        rectangle('position', thisBox(:), 'Edgecolor', 'r');
    end
    hold off;
    
    count = count + 1;
end



clear vid;