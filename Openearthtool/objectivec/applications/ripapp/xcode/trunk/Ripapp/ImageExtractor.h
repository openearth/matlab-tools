//
//  ImageExtractor.h
//
//  Created by AltenPTS on 5/30/12.


#import "AVFoundation/AVFoundation.h"

@interface ImageExtractor : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

FOUNDATION_EXPORT NSString*const ImageProcessedTag;
FOUNDATION_EXPORT NSString*const AllImagesProcessedTag;

-(id) initWithSequenceLength:(int)sequenceLength;
-(void) startWithConnection:(AVCaptureConnection*) connection;
-(void) startFromResource:(NSString*) resource andWidth:(int)width andHeight:(int)height;
-(void) stop;

@property (nonatomic, retain) NSMutableArray *imageMutableArray;
@property (nonatomic) int SequenceLength;
@property (atomic) bool BusyProcessing;
@property (nonatomic) int Width;
@property (nonatomic) int Height;
@property (nonatomic) CFTimeInterval PreviousTime;

@property (nonatomic, retain) AVCaptureConnection* videoConnection;
@property (nonatomic, retain) NSTimer* __block timer;

@end
