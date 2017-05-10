preview(vid);

%Thresholds for blue glove color
hueThresholdLow = 0.4;
hueThresholdHigh = 0.6;
saturationThresholdLow = 0.2;
saturationThresholdHigh = 0.7;
valueThresholdLow = 0.6;
valueThresholdHigh = 1.0;
%End

% get image sub function
choice = questdlg('Press "capture" when you are ready to take a photo.', 'Take Picture', 'Capture', 'Cancel', 'Capture');
switch choice
    case 'Capture'
        img = snapshot(vid);
        exitCode = false;
    case 'Cancel'
        exitCode = true;
end

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
imshow(coloredObjectsMask, []);
%Getting rid of excess pixels, smoothing borders, and filling regions
smallestAcceptableArea = 100;
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
structuringElement = strel('disk', 5);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');
    
measurements = regionprops(coloredObjectsMask);
numberOfMeasurements = size(measurements, 1);
