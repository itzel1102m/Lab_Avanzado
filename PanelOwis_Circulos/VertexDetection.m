function res = VertexDetection(Im)
Im2 = imread(Im);
grayImage = rgb2gray(Im2);                           % Converson to binary
BW = imbinarize(grayImage);


[m,n] = size(BW);

A = false(m,n);

R = regionprops(BW,'PixelIdxList');
Nv = numel(R);                                       %number of vertebrae

corners = cell(1,Nv);
cornersRounded = cell(1,Nv);

imshow(BW)


for i = 1 : Nv
    
   B = A;
   B(R(i).PixelIdxList) = 1;
   
   corners{i} = pgonCorners(B,4,100);
   cornersRounded{i} = round(corners{i}./5)*5;
   
   hold on
   
   plot( corners{i}(:,2),corners{i}(:,1),'yo','MarkerFaceColor','r','MarkerSize',5);
   
   hold off

end

heights = cellfun(@(c) mean(c(:,1)),corners);

[heights,idx] = sort(heights);
 corners = corners(idx);

res = cornersRounded;
end





