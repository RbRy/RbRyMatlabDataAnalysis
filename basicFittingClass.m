classdef basicFittingClass < handle
    %Superclass for all fitting subclasses, should not be used directly but
    %serves as a framework for someone wanting to make their own fitting
    %class
    
    %Define some general properties here that are general to all fitting
    %classes
    properties
        processedImage = 0;
    end
    
    %And some methods which should be general to all fitting classes
    methods
        %Set the processed image of our object to that passed in the method
        function setProcessedImage(self,procImageIn)
            self.processedImage = procImageIn;
        end
        %Do a contour plot of the processed image
        function plotProcessedImage(self)
            contour(self.processedImage);
        end
        %Get the processed image
        function procImageOut = getProcessedImage(self)
            procImageOut = self.processedImage;
        end
    end
    
end

