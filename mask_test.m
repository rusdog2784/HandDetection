clear all;
close all;
clc;

vid = webcam(1);
pause(2);
preview(vid);

choice = questdlg('Press "capture" when you are ready to take a photo.', 'Take Picture', 'Capture', 'Cancel', 'Capture');
switch choice
    case 'Capture'
        image_in = snapshot(vid);
    case 'Cancel'
        return;
end

sigma = 1;
halfwid = 3 * sigma;
[xx, yy] = meshgrid(-halfwid:halfwid, -halfwid:halfwid);
gau = exp(-1/(2 * sigma^2) * (xx.^2 + yy.^2));

img = imfilter(image_in, gau);

imshowpair(image_in, img, 'montage');

clear vid;