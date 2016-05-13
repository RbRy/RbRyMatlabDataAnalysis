classdef absGaussFit < basicFittingClass
    %Class for an absorption imaging gaussian cloud fit
    
    properties
        %Perhaps should find some other way to set pixel size that is more
        %appropriate
        pixSize=3.69;
        centreX=0;
        centreY=0;
        xCoffs=[0,1,900,300];
        yCoffs=[0,1,500,300];
        %Define the gaussian fitting function
        gauss = @(coffs,x) transpose(coffs(1)-coffs(2).*exp(-(x-coffs(3)).^2/(2*coffs(4).^2)));
        opts = optimset('Display','off');
    end
    
    methods
        %Function to load a .h5 file up and extract the processed image
        function loadFromFile(self,filename)
            %Grab the images from file
            absorption = double(h5read(filename,'/Images/Absorption'));
            probe = double(h5read(filename,'/Images/Probe'));
            background = double(h5read(filename,'/Images/Background'));
            %From the absorption, probe and background images get the processed OD
            %image
            self.setProcessedImage(real(log((absorption-background)./(probe-background))));
        end
        %Manually set the coordinates to the cloud centre
        function setCentreCoordinates(self,centreXIn,centreYIn)
            %Set location of the centre of the cloud
            self.centreX = centreXIn;
            self.centreY = centreYIn;
        end
        %Automagically find the centre of the cloud
        function findCentreCoordinates(self)
            %Sum over the columns and rows respectively to collapse the processed
            %image down into a a vector
            summedCols = sum(self.getProcessedImage,1);
            summedRows = sum(self.getProcessedImage,2);
            %Determine the minimum of this collapsed vector for both columns and
            %rows to find the approximate middle of the cloud.
            [~,minCol] = min(summedRows);
            [~,minRow] = min(summedCols);
            self.centreX = minCol;
            self.centreY = minRow;
        end
        %Fit the cloud in the X direction
        function runXFit(self)
            processedImage = self.getProcessedImage();
            xVec = sum(processedImage(:,self.centreY-10:self.centreY+10),2)/21;
            xPix = [1:length(xVec)];
            self.xCoffs = lsqcurvefit(self.gauss,self.xCoffs,xPix,xVec,[],[],self.opts);
        end
        %Fit the cloud in the Y direction
        function runYFit(self)
            processedImage = self.getProcessedImage();
            yVec = sum(processedImage(self.centreX-10:self.centreX+10,:),1)/21;
            yPix = transpose([1:length(yVec)]);
            self.yCoffs = lsqcurvefit(self.gauss,self.yCoffs,yPix,yVec,[],[],self.opts);
        end
        %Plot the x directional slice of the cloud with its fit
        function plotX(self)
            processedImage = self.getProcessedImage();
            xVec = sum(processedImage(:,self.centreY-10:self.centreY+10),2)/21;
            spatialVec = self.pixSize * [1:length(xVec)]- self.pixSize * self.centreX;
            plot(spatialVec,xVec,'.')
            hold all
            plot(spatialVec,self.gauss(self.xCoffs,[1:length(xVec)]))
            hold off
            xlabel('Distance in X direction (\mum)')
            ylabel('OD')
        end
        %Plot the y directional slice of the cloud with its fit
        function plotY(self)
            processedImage = self.getProcessedImage();
            yVec = sum(processedImage(self.centreX-10:self.centreX+10,:),1)/21;
            spatialVec = self.pixSize * [1:length(yVec)]- self.pixSize * self.centreY;
            plot(spatialVec,yVec,'.')
            hold all
            plot(spatialVec,self.gauss(self.yCoffs,[1:length(yVec)]))
            hold off
            xlabel('Distance in Y direction (\mum)')
            ylabel('OD')
        end
        %Return centre coordinates
        function [centreX, centreY] = getCentreCoordinates(self)
            centreX = self.centreX;
            centreY = self.centreY;
        end
    end
    
end