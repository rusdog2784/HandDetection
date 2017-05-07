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
preview(vid);
figure;

while (run == true)
    
    img = snapshot(vid);

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
    
    measurements = regionprops(coloredObjectsMask);
    numberOfMeasurements = size(measurements, 1);
    if numberOfMeasurements == 1
        boundingBox = measurements(1).BoundingBox;
        croppedHand = uint8(imcrop(coloredObjectsMask, boundingBox));
        
        key_image = imread('Images/hand');
        
        %Comparing image to key
        %Find greatest width
        if size(key_image, 1) > size(croppedHand, 1)
            width = size(key_image, 1);
        else
            width = size(croppedHand, 1);
        end

        %Find greatest height
        if size(key_image, 2) > size(croppedHand, 2)
            height = size(key_image, 2);
        else
            height = size(croppedHand, 2);
        end

        %Resize images using the greatest width and height
        key_image = imresize(key_image, [width height]);
        croppedHand = imresize(croppedHand, [width height]);

        %Compare pixels
        total_pixels = width * height;
        pixel_count = 0;
        for r = 1 : width
            for c = 1 : height
                if key_image(r,c) == croppedHand(r,c)
                    pixel_count = pixel_count + 1;
                end
            end
        end

        percent_match = double((pixel_count / total_pixels) * 100);
        display(percent_match);
        if percent_match > 70.0
            run = false;
        end
        
        subplot(1,3,2);
        imshow(croppedHand, []);
        
        subplot(1,3,3);
        imshow(key_image, []);
    end

    %Getting rectangle around hand region
    subplot(1,3,1);
    imshow(img);
    hold on;
    measurements = regionprops(coloredObjectsMask);
    numberOfRegions = size(measurements, 1);
    for k = 1 : numberOfRegions
        thisBox = measurements(k).BoundingBox;
        rectangle('position', thisBox(:), 'Edgecolor', 'r');
    end
    hold off;
%     run = false;
end



clear vid;