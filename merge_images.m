img1 = im2bw(imread('Images/hand1'));
img2 = im2bw(imread('Images/hand2'));
img3 = im2bw(imread('Images/hand3'));
img4 = im2bw(imread('Images/hand4'));
img5 = im2bw(imread('Images/hand5'));
img6 = im2bw(imread('Images/hand6'));
img7 = im2bw(imread('Images/hand7'));
img8 = im2bw(imread('Images/hand8'));
img9 = im2bw(imread('Images/hand9'));
img10 = im2bw(imread('Images/hand10'));

average = (img1 + img2 + img3 + img4 + img5 + img6 + img7 + img8 + img9 + img10) / 10;
threshold = 0.4;
final_image = (average >= threshold);

smallestAcceptableArea = 200;
final_image = uint8(bwareaopen(final_image, smallestAcceptableArea));
structuringElement = strel('disk', 5);
final_image = imclose(final_image, structuringElement);
final_image = imfill(logical(final_image), 'holes');
    
measurements = regionprops(final_image);
numberOfMeasurements = size(measurements, 1);
if numberOfMeasurements == 1
    boundingBox = measurements(1).BoundingBox;
    croppedHand = imcrop(final_image, boundingBox);
end