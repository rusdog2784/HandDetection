%Initial commands to reset/initialize everything
clear all;
close all;
clc;
fontSize = 14;
run = true;
try_again = true;
image_count = 1;

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
figure;
preview(vid);

while (try_again)
    choice = questdlg('Press start to begin hand key capture.', 'Hand Key Required', 'Start', 'Cancel', 'Start');
    switch choice
        case 'Start'
            img = snapshot(vid);
            imshow(img);
            h = waitbar(0, 'Get ready...');
            steps = 3;
            for step = 1 : steps
                pause(1);
                waitbar(step/steps);
            end
            close(h)
        case 'Cancel'
            return;
    end

    while (image_count <= 10)
        img = snapshot(vid);

        %Break down original image into HSV values and seperate hand usingthresholds
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
        smallestAcceptableArea = 5000;
        coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
        structuringElement = strel('disk', 4);
        coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
        coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');
        
        location = strcat('Images/hand', num2str(image_count));
        imwrite(coloredObjectsMask, location, 'jpg');
    %     X = ['Hand ', num2str(image_count), ' saved.'];
    %     disp(X);
        image_count = image_count + 1;

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
        pause(0.5);
    end

    merge_images;
    image_compare;

    if round(percent_match, 0) >= 82.0
        try_again = false;
        X = ['Congratulations, its a match'];
        disp(X);
    else
        try_again = true;
        waitfor(msgbox('Sorry, but that is not the correct hand signal. Please try again.'));
        image_count = 1;
    end
end
clear vid;