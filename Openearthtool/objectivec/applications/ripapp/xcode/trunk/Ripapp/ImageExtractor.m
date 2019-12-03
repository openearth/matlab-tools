//
//  ImageExtractor.m
//
//  Created by AltenPTS on 5/30/12.
//

#import "ImageExtractor.h"
#import "ImageIO/CGImageProperties.h"

@implementation ImageExtractor

@synthesize imageMutableArray;
@synthesize SequenceLength;
@synthesize BusyProcessing;
@synthesize Width;
@synthesize Height;
@synthesize PreviousTime;

NSString*const ImageProcessedTag = @"IMAGE_READY";
NSString*const AllImagesProcessedTag = @"ALL_IMAGES_READY";

@synthesize videoConnection;
@synthesize timer;

-(id) initWithSequenceLength:(int)sequenceLength 
{
    self = [super init];
    if(self==nil)
    {
        return nil;
    }
    
    SequenceLength = sequenceLength;    
    return self;
}

-(void) startWithConnection:(AVCaptureConnection*) connection
{
    if(!BusyProcessing)
    {
        BusyProcessing = YES;
        
        videoConnection = connection;        
        if(imageMutableArray!=nil)
        {
            [imageMutableArray release];
        }
        imageMutableArray = [[NSMutableArray alloc] init ];
        
        PreviousTime = CACurrentMediaTime();
        timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(takeSnapShot:) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

-(void)takeSnapShot:(NSTimer*)aTimer
{
    if(CACurrentMediaTime()>=PreviousTime+1)
    {
        PreviousTime = CACurrentMediaTime();
        
        NSLog(@"about to request a capture from: %@", videoConnection.output);
        [(AVCaptureStillImageOutput*)videoConnection.output captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
         {
             if(imageSampleBuffer==NULL)
             {
                 NSLog(@"SampleBugger == null !!!");
                 return ;
             }         
             if(imageMutableArray.count<SequenceLength)
             {                 
                 CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                 if (exifAttachments)
                 {
                     // Do something with the attachments.
                     NSLog(@"attachements: %@", exifAttachments);
                 }
                 else
                     NSLog(@"no attachments");
                 
                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                 UIImage *image = [[UIImage alloc] initWithData:imageData];
                 
                 [imageMutableArray addObject:image];
                 
                 [self notifyImageExtracted:image];
                 
                 if(imageMutableArray.count>=SequenceLength)
                 {
                     [timer invalidate];
                     timer = nil;
                     BusyProcessing = NO;
                     
                     NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                     
                     [queue setMaxConcurrentOperationCount:1];
                     
                     NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                             selector:@selector(notifyFinished) object:nil];
                     [queue addOperation:operation];
                     [operation release];
                 }
             }
         }];  
    }
    
}

-(void)stop
{
    if(timer!=nil && [timer isValid])
    {
        [timer invalidate];
    };    
    timer = nil;
}


-(void) startFromResource:(NSString*) resource andWidth:(int)width andHeight:(int)height
{
    if(!BusyProcessing)
    {
        Width = width;
        Height = height;

        BusyProcessing = YES;
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        [queue setMaxConcurrentOperationCount:1];
        
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(extractor:) object:resource];
        [queue addOperation:operation];
        [operation release];
    }
}

- (void)notifyImageExtracted:(UIImage *)image
{
    NSNumber* progressNumber = [NSNumber numberWithFloat:(((float)imageMutableArray.count)/((float)SequenceLength))];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ImageProcessedTag object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:image,@"image",progressNumber,@"progressNumber", nil]];
}

- (void)notifyFinished
{
//    if(imageMutableArray.count>=SequenceLength)
//    {
//        [self stop];
//    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AllImagesProcessedTag object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:imageMutableArray,@"images", nil]];
}

-(void)extractor:(id)resourceID
{
    NSString* resource = (NSString*)resourceID;
    NSLog(@"extractor started");
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", 
                      [[NSBundle mainBundle] resourcePath], 
                      resource];
    NSLog(@"Path of video file: %@", path);
    
    NSURL *url = [NSURL fileURLWithPath:path];      
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;   
    imageGenerator.maximumSize = CGSizeMake(Width, Height); 
    
    if(imageMutableArray!=nil)
    {
        [imageMutableArray release];
    }
    imageMutableArray = [[NSMutableArray alloc] init ];
    
    NSLog(@"imageMutableArray created");
    
    for(int i=0 ; i<SequenceLength ; i++)
    {
        NSLog(@"Capturing image %u", i);
        CMTime thumbTime = CMTimeMakeWithSeconds(i,1); 
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbTime actualTime:NULL error:NULL];
        UIImage *image = [UIImage imageWithCGImage:imageRef];  
        [imageMutableArray addObject:image];
        NSLog(@"added image %u", i);            
        
        [self notifyImageExtracted:image];
    }    
    
    [self notifyFinished];
    
    BusyProcessing = NO;
}

//-(void)startTimerOnUIThread:(id) data
//{
//    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
//}

//int imageIndex = 0;
//-(void) timerFired:(NSTimer*)timer
//{
//    NSLog(@"Deleyaed message");
//}


@end
