clear all;
close all;
clc;

%Thresholds for blue glove color
hueThresholdLow = 0.4;
hueThresholdHigh = 0.6;
saturationThresholdLow = 0.2;
saturationThresholdHigh = 0.7;
valueThresholdLow = 0.6;
valueThresholdHigh = 1.0;
%End

vid = webcam(1);
pause(2);

figure;

while (true)
    image_in = snapshot(vid);
    subplot(4,4,1);
    imshow(image_in);
    title('Live Feed', 'FontSize', 14);
    
    mask = [1.0 1.0 1.0; 1.0 1.0 1.0; 1.0 1.0 1.0];
    img = image_in;
    height = size(image_in,1);
    width = size(image_in,2);
    for j = 1 : height
        for k = 1 : width
            if (j == 1 || k == 1 || j == height || k == width)
                img(j,k) = image_in(j,k);
            else
                sum = 0.0;
                for m = 1 : size(mask,1)
                    for n = 1 : size(mask,2)
                        sum = sum + ((double)image_in(j+m-1, k+n-1))*mask(m,n)/9.0;
                    end
                    img(j,k) = uint8(sum);
                end
            end
        end
    end
    
    
    
    %Seperating image into HSV value images and displaying them
    hsvImage = rgb2hsv(img);
    hImage = hsvImage(:,:,1);
    sImage = hsvImage(:,:,2);
    vImage = hsvImage(:,:,3);
    
    subplot(4,4,2);
    imshow(hImage);
    title('Hue Image', 'FontSize', 14);
    subplot(4,4,3);
    imshow(sImage);
    title('Saturation Image', 'FontSize', 14);
    subplot(4,4,4);
    imshow(vImage);
    title('Value Image', 'FontSize', 14);
    
    %Hue histogram
    subplot(4,4,6);
    [hueCounts, hueBinValues] = imhist(hImage);
    area(hueBinValues, hueCounts, 'FaceColor', 'r');
    grid on;
    xlabel('Hue Value');
    ylabel('Pixel Count');
    title('Histogram of Hue Image', 'FontSize', 14);
    
    %Saturation histogram
    subplot(4,4,7);
    [satCounts, satBinValues] = imhist(hImage);
    area(satBinValues, satCounts, 'FaceColor', 'g');
    grid on;
    xlabel('Saturation Value');
    ylabel('Pixel Count');
    title('Histogram of Saturation Image', 'FontSize', 14);
    
    %Value histogram
    subplot(4,4,8);
    [valCounts, valBinValues] = imhist(hImage);
    area(valBinValues, valCounts, 'FaceColor', 'b');
    grid on;
    xlabel('Value Value');
    ylabel('Pixel Count');
    title('Histogram of Value Image', 'FontSize', 14);
    
    %Hue image thresholded and plotted
    hueMask = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
    subplot(4,4,10);
    imshow(hueMask);
    title('Hue Mask', 'FontSize', 14);
    
    %Saturation image thresholded and plotted
    satMask = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
    subplot(4,4,11);
    imshow(satMask);
    title('Saturation Mask', 'FontSize', 14);
    
    %Value image thresholded and plotted
    valMask = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);
    subplot(4,4,12);
    imshow(valMask);
    title('Value Mask', 'FontSize', 14);
    
    %Putting it all together
	coloredObjectsMask = uint8(hueMask & satMask & valMask);
    smallestAcceptableArea = 100;
    coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
    structuringElement = strel('disk', 5);
    coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
    coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');
    subplot(4,4,9);
    imshow(coloredObjectsMask, []);
    title('Altogether Mask', 'FontSize', 14);
end
