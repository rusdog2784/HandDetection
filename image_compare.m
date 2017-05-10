img1 = im2bw(imread('Images/hand_key'));
img2 = croppedHand;

%Find greatest width
if size(img1, 1) > size(img2, 1)
    width = size(img1, 1);
else
    width = size(img2, 1);
end

%Find greatest height
if size(img1, 2) > size(img2, 2)
    height = size(img1, 2);
else
    height = size(img2, 2);
end

%Resize images using the greatest width and height
img1 = imresize(img1, [width height]);
img2 = imresize(img2, [width height]);

%Compare pixels
total_pixels = width * height;
pixel_count = 0;
for r = 1 : width
    for c = 1 : height
        if img1(r,c) == img2(r,c)
            pixel_count = pixel_count + 1;
        end
    end
end

percent_match = double((pixel_count / total_pixels) * 100);
display(percent_match);

% figure;
% subplot(1,2,1);
% imshow(img1);
% 
% subplot(1,2,2);
% imshow(img2);