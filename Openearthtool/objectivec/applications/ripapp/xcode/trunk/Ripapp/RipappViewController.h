//
//  Ripapp.h
//  Ripapp
//
//  Created by AltenPTS & Deltares

#import <UIKit/UIKit.h>
#import "AVFoundation/AVFoundation.h"
#import "ImageExtractor.h"

@interface RipappViewController : UIViewController
{
//    cv::VideoCapture *_videoCapture;
//    cv::Mat _currentFrame;
//    cv::Mat _prevFrame;
//    cv::Mat _sum[2]; // Keeps track of sum of the flows (2 arrays, UV , 32bit float)
//    int _n; // Keeps track of the number of obs (1 channel, ints)
    
}

@property (nonatomic, retain) IBOutlet UILabel *currentLabel;
@property (nonatomic, retain) IBOutlet UILabel *previousLabel;
@property (nonatomic, retain) IBOutlet UILabel *lineupLabel;

@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIImageView *previousImageView;
@property (nonatomic, retain) IBOutlet UIImageView *currentImageView;
@property (nonatomic, retain) IBOutlet UIButton *cameraButton;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;
@property (nonatomic, retain) IBOutlet UIButton *movieButton;


@property (nonatomic, retain) ImageExtractor* imageExtractor;
@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, retain) AVCaptureConnection *videoConnection;
@property (atomic,readonly) bool busyProcessing;
@property (atomic,readonly) bool busyRecording;

- (IBAction)playMovie:(id)sender;
- (IBAction)playVideo:(id)sender;
- (IBAction)stopClicked:(id)sender;

@end
