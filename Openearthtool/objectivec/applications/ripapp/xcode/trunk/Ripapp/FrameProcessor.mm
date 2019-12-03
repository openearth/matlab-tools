//
//  FrameProcessor.m
//
//  Created by Deltares & AltenPTS on 6/5/12.
//
//

#import "FrameProcessor.h"
#import "UIImage+OpenCV.h"



@implementation FrameProcessor

cv::Mat _sum[2]; // Keeps track of sum of the flows (2 arrays, UV , 32bit float)
int _n; // Keeps track of the number of obs (1 channel, ints)

-(id)init
{
    self = [super init];
    if(self==nil)
    {
        return nil;
    }
    
    _n=-1;  
    
    return self;
}


// Perform image processing on the last captured frame and display the results
-(void)processFrame:(UIImage*)currentFrameImage withPreviousFrame:(UIImage*)previousFrameImage forResultUIImage:(UIImage**) resultImage
{
    cv::Mat previousFrame = [UIImage cvMatWithImage:currentFrameImage];
    cv::Mat currentFrame = [UIImage cvMatWithImage:previousFrameImage];
    
    if(_n<0)
    {
        _sum[0].create(previousFrame.rows, previousFrame.cols,CV_32F);
        _sum[1].create(previousFrame.rows, previousFrame.cols,CV_32F);
        _sum[0].setTo(0.0);
        _sum[1].setTo(0.0);
        _n=0;  
    }
    
    if(previousFrame.empty())
    {
        previousFrame = currentFrame;
        return;
    }
    
    double t = (double)cv::getTickCount();
    
    cv::Mat grayCurrentFrame, grayPrevFrame, flow, blended;
    // Convert captured frame to grayscale
    
    if ( currentFrame.rows != previousFrame.rows  || currentFrame.cols != previousFrame.cols) {
        NSLog(@"Not processing because images are not of equal size, returning currentFrame");
        (*resultImage) = [UIImage imageWithCVMat:currentFrame];
        return;
    }
    
    // Assume that there are is a currentFrame and a previousFrame
    // Convert them both to grayscale for analysis
    cv::cvtColor(currentFrame, grayCurrentFrame, cv::COLOR_RGB2GRAY);
    cv::cvtColor(previousFrame, grayPrevFrame, cv::COLOR_RGB2GRAY);
    
    // Timing to show performance
    
    // Double check if size is equal, otherwise the algorithm throws an error
    if (grayPrevFrame.size() != grayCurrentFrame.size())
    {
        NSLog(@"Got incompatible frame types! Skipping flow calculation.");
        NSLog(@"Got prev img of size %d x %d, current of %d x %d", grayPrevFrame.rows, grayPrevFrame.cols, grayCurrentFrame.rows, grayCurrentFrame.cols);
        return;
    }
    // Run the algorithm for flow detection
    NSLog(@"Got prev img of size %d x %d, current of %d x %d", grayPrevFrame.rows, grayPrevFrame.cols, grayCurrentFrame.rows, grayCurrentFrame.cols);
    NSLog(@"Got prev img of %d channels, current of %d channels", grayPrevFrame.channels(), grayCurrentFrame.channels());
	cv::calcOpticalFlowFarneback(grayPrevFrame, grayCurrentFrame, flow, 0.5, 5, 10, 3, 5, 1.2, 0);
	
    // Some properties of the flow
    NSLog(@"Got flow of size %d x %d", flow.size[0], flow.size[1]);
    NSLog(@"Got flow of type %@", (flow.type() == CV_32FC2) ? @"32FC2" : @"other");
    NSLog(@"Got flow with number of channels: %d", flow.channels());
    
    
    // Convert to array of 2 matrices
    cv::Mat UV[2]; // U, V components
    cv::split(flow, UV);
    cv::accumulate(-UV[0], _sum[0]);
    cv::accumulate(-UV[1], _sum[1]);
    _n +=1;
    
    // Visualization part
    // Now we're converting the flow image (magnitude + angle) -> hsv merged with the previousFrame
    
    //calculate angle and magnitude
    cv::Mat magnitude, angle;
    // Optional multiply UV[1] (V) by a factor, of say 3, to increase the greennes/redness 
    // V => y direction (rows), first index
    cv::cartToPolar((_sum[0]/_n), (_sum[1]/_n), magnitude, angle, false);
    
    
    cv::Mat mask;
    // Is the angle greater than 2/3pi
    cv::compare(angle, 2.f/3.f*M_PI, mask, cv::CMP_GE);
    // TODO, on mask: angle = pi + (angle - 2/3pi)/((1+1/3)pi) * pi 
    // on smaller angle = 0 + angle/(2/3pi) 
    
    // Per pixel algorithm. TODO replace with something more smart...
    // I'm not sure what angle is now green
    
    float rotate= 0*M_PI;
    float a;
    for (int i=0; i<angle.rows; i++) {
        for (int j=0; j<angle.cols; j++) {
            
            a = angle.at<float>(i,j);
            if (a  >= M_PI)
            {
                // scale 2/3 pi <-> 2pi over range PI<->2*PI
                angle.at<float>(i,j) = (float) (M_PI + M_PI*(a-(2/3.0)*M_PI)/((1+1/3.0)*M_PI));
                angle.at<float>(i,j) = (float) (a-1.5*M_PI);

                //scale pi <-> 2 pi to -4/3pi <-> 1/3pi
                if (a < 1.5*M_PI) {
                    // scale pi <-> 1.5pi to -2/3pi <-> 0.0;
                    angle.at<float>(i,j) = -2/3.0*M_PI + 2/3.0*M_PI*(a-M_PI)/(0.5*M_PI);
                }
                else {
                    // scale 1.5pi <-> 2pi to 0.0 <-> 1/3pi;
                    angle.at<float>(i,j) = (1/3.0)*M_PI*(a-1.5*M_PI)/(0.5*M_PI);
                }
                               
            }
            else {

                // scale 0<->2/3 pi over range 0<->PI
                angle.at<float>(i,j) =  (float) (M_PI*a/((2/3.0)*M_PI));
                angle.at<float>(i,j) = M_PI*2/3.0;
                // scale 0 <-> PI over range 1/3PI <-> 2/3PI
                if (a < 0.5*M_PI) {
                    angle.at<float>(i,j) = 1/3.0*M_PI + 1/3.0*M_PI*(a)/(0.5*M_PI);
                }
                else {
                    angle.at<float>(i,j) = 2/3.0*M_PI + 2/3.0*M_PI*(a-0.5*M_PI)/(0.5*M_PI);
                    
                }

                
            }
        }
    }
    
    //translate magnitude to range [0;1], angle to range [0;360]
    double minVal;
    double maxVal;
    cv::Point minLoc;
    cv::Point maxLoc;
    // Check some statistics
    // Look up min and max angle. 
    cv::minMaxLoc(angle, &minVal, &maxVal, &minLoc, &maxLoc);
    NSLog(@"Angle varied between %f and %f", minVal, maxVal);
    angle.convertTo(angle, -1, (float)360/(2*M_PI));
    cv::minMaxLoc(angle, &minVal, &maxVal, &minLoc, &maxLoc);
    NSLog(@"Angle now varies between %f and %f", minVal, maxVal);
    
    // Lookup min and max
    cv::minMaxLoc(magnitude, &minVal, &maxVal, &minLoc, &maxLoc);
    NSLog(@"magnitude varied between %f and %f", minVal, maxVal);
    magnitude.convertTo(magnitude, -1, 1.0/maxVal);
    cv::minMaxLoc(magnitude, &minVal, &maxVal, &minLoc, &maxLoc);
    NSLog(@"magnitude now varies between %f and %f", minVal, maxVal);
    
    //build hsv image
    cv::Mat hsv_array[3];
    cv::Mat hsv;
    hsv_array[0] = angle;
    hsv_array[1] = cv::Mat::ones(angle.size(), CV_32F);
    hsv_array[2] = magnitude; // cv::Mat::ones(angle.size(), CV_32F); //magnitude; This should be magnitude, but let's fix the angles first...
    cv::merge(hsv_array, 3, hsv);
    
    //convert to RGB, with/without alpha channel (+a), with/without unsigned ints (+u).
    cv::Mat rgb, rgbu, rgba, rgbau;//CV_32FC3 matrix
    cv::cvtColor(hsv, rgb, cv::COLOR_HSV2RGB);
    cv::Mat rgb_array[3];
    cv::split(rgb, rgb_array);
    cv::minMaxLoc(rgb_array[0], &minVal, &maxVal, &minLoc, &maxLoc);
    NSLog(@"R varied between %f and %f", minVal, maxVal);
    cv::minMaxLoc(rgb_array[1], &minVal, &maxVal, &minLoc, &maxLoc);
    NSLog(@"G varied between %f and %f", minVal, maxVal);
    cv::minMaxLoc(rgb_array[2], &minVal, &maxVal, &minLoc, &maxLoc);
    NSLog(@"B varied between %f and %f", minVal, maxVal);
    
    // Add alpha channel
    cv::cvtColor(rgb, rgba, cv::COLOR_RGB2RGBA);
    // Convert to unsigned ints
    rgb.convertTo(rgbu, CV_8UC3, 255);
    rgba.convertTo(rgbau, CV_8UC4, 255);
    
    // We now have an hsv image showing the vectors in HSV. 
    
    // For performance checks
    t = 1000 * ((double)cv::getTickCount() - t) / cv::getTickFrequency();
    
    // Add blend frame + converted image...
    if (currentFrame.channels() == 4) {
        NSLog(@"Got 4 channel current");
        cv::addWeighted(previousFrame, 0.5, rgbau, 0.5, 0.0, blended);
    }
    else if (currentFrame.channels()==3) {
        NSLog(@"Got 3 channel current");
        cv::addWeighted(previousFrame, 0.5, rgbu, 0.5, 0.0, blended);
    }
    
    // Scale up blended
    int scaleup = 3;
    cv::Size size ;
    size.height = blended.rows*scaleup;
    size.width = blended.cols*scaleup;
    cv::Mat blendedbig;
    cv::resize(blended, blendedbig, size );
    
    //TODO Scale up blended before drawing arrows
    int step=16;
    for (int i=0;i<blended.rows;i+=step) {
        for (int j=0;j<blended.cols;j+=step) {
            cv::Point p1, p2;
            p1.y = (i*scaleup)+0.5;
            p1.x = (j*scaleup)+0.5;
            p2.y = (i*scaleup)+0.5 + -UV[1].at<float>(i,j);
            p2.x = (j*scaleup)+0.5 + -UV[0].at<float>(i,j);
            cv::line(blendedbig, p1, p2, CV_RGB(200,200,200));
            cv::circle(blendedbig, p1, 3, CV_RGB(200,200,200),-1);
        }
    }
    
// Plot mean flow with green arrows
//    for (int i=0;i<blended.rows;i+=step) {
//        for (int j=0;j<blended.cols;j+=step) {
//            cv::Point p1, p2;
//            p1.y = (i*scaleup)+0.5;
//            p1.x = (j*scaleup)+0.5;
//            p2.y = (i*scaleup)+0.5 + _sum[1].at<float>(i,j);
//            p2.x = (j*scaleup)+0.5 + _sum[0].at<float>(i,j);
//            cv::line(blendedbig, p1, p2, CV_RGB(100,255,100));
//            cv::circle(blendedbig, p1, 3, CV_RGB(100,255,100),-1);
//        }
//    }
//
    
    // Show the worst and best place to swim.
    // TODO extract middle band of _sum[1]
    cv::Mat cropped;
    cv::Rect rect;
    rect.x = 0;
    rect.y = 100;
    rect.width = _sum[1].cols;
    rect.height = _sum[1].rows-200;
    // Look up min and max val over 100px in;
    cropped = _sum[1](rect);
    cv::minMaxLoc(cropped, &minVal, &maxVal, &minLoc, &maxLoc);
    
    char buffer[12];
    sprintf(buffer, "<-(X) Unsafe, probably"); 
    
    // Scale and move to fit in blendedbig.
    minLoc.x = (minLoc.x + rect.x) * scaleup;
    minLoc.y = (minLoc.y + rect.y) * scaleup;
    
    cv::putText(blendedbig, buffer, minLoc, cv::FONT_HERSHEY_PLAIN, 1.0, 255.0);

    sprintf(buffer, "<-(+) Maybe safe to swim here"); 
    
    // Scale and move to fit in blendedbig.
    maxLoc.x = (maxLoc.x + rect.x) * scaleup;
    maxLoc.y = (maxLoc.y + rect.y) * scaleup;
    cv::putText(blendedbig, buffer, maxLoc, cv::FONT_HERSHEY_PLAIN, 1.0, CV_RGB(100,255,100));
    

    // Display result  
    //    self.elapsedTimeLabel.text = [NSString stringWithFormat:@"%dx%d: %.1fms/%.1fms", currentFrame.rows, currentFrame.cols, ti, t - ti];
    
    (*resultImage) = [UIImage imageWithCVMat:blendedbig];
}

@end
