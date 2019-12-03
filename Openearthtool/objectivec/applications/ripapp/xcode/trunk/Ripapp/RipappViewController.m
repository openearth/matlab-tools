//
//  RipappViewController.m

//
//  Created by Deltares & AltenPTS

#import "RipappViewController.h"
#import "FrameProcessor.h"
#import "ImageExtractor.h"

@implementation RipappViewController


@synthesize currentLabel;
@synthesize previousLabel;
@synthesize lineupLabel;
@synthesize stopButton;
@synthesize movieButton;
@synthesize cameraButton;
@synthesize progressView;
@synthesize activityIndicator;
@synthesize previousImageView;
@synthesize currentImageView;
@synthesize imageView;
@synthesize imageExtractor;
@synthesize session;
@synthesize captureVideoPreviewLayer;
@synthesize videoConnection;

@synthesize busyProcessing;
@synthesize busyRecording;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareCameraView:imageView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(destroyView) name:@"applicationDidEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reinitView) name:@"applicationWillEnterForeground" object:nil];
    
    [self setOutputViewsHidden];
    
    self.progressView.progress = 0;
}

- (void)viewDidUnload
{
    self.imageView = nil;
    self.currentLabel= nil;
    self.lineupLabel = nil;
    self.previousLabel= nil;
    self.stopButton= nil;
    self.movieButton= nil;
    self.cameraButton= nil;
    self.progressView= nil;
    self.activityIndicator= nil;
    self.previousImageView= nil;
    self.currentImageView= nil;
    self.imageView= nil;
    self.imageExtractor= nil;
    self.session= nil;
    self.captureVideoPreviewLayer= nil;
    self.videoConnection= nil;
    
    [super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated]; 
}

-(void) viewWillDisappear:(BOOL)animated
{    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void)reinitView 
{    
    [self performSelectorOnMainThread:@selector(updateActivityIndicator:) withObject:[NSNumber numberWithBool:busyProcessing] waitUntilDone:NO]; 
}

-(void) destroyView
{
    [self destroyView:busyRecording];
    busyRecording = NO;
}

-(void) destroyView:(bool)overwriteBusyRecording
{
    if (overwriteBusyRecording)
    {
        if(imageExtractor!=nil)
        {
            [imageExtractor stop];
            self.imageExtractor = nil;
        }
        
        [self performSelectorOnMainThread:@selector(setOutputViewsHidden) withObject:nil waitUntilDone:NO]; 
        [self performSelectorOnMainThread:@selector(updateProgressView:) withObject:[NSNumber numberWithFloat:0.0] waitUntilDone:NO]; 
        [self performSelectorOnMainThread:@selector(updateButtonVisability:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO]; 
    }
}

-(void)setOutputViewsHidden
{
    [self setOutputViewsHidden:YES];
}

-(void)setOutputViewsVisable
{
    [self setOutputViewsHidden:NO];
}

-(void)setOutputViewsHidden:(bool)hidden
{
    currentLabel.hidden = hidden;
    previousLabel.hidden = hidden;
    lineupLabel.hidden = !hidden;
    currentImageView.hidden = hidden;
    previousImageView.hidden = hidden;
    
    if(hidden)
    {
        [activityIndicator stopAnimating];
    }
    else 
    {
        [activityIndicator startAnimating];
    }
}

- (void)prepareCameraView:(UIView *)window
{
    self.session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
    CALayer *viewLayer = window.layer;
    viewLayer.name = @"videolayer";
    NSLog(@"viewLayer = %@", viewLayer);
    
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] 
                                                            initWithSession:session];

    CGRect landscapeRight = CGRectMake(0, 0, window.bounds.size.height, window.bounds.size.width);
    captureVideoPreviewLayer.frame = landscapeRight;
    captureVideoPreviewLayer.orientation = AVCaptureVideoOrientationLandscapeRight;
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [window.layer addSublayer:captureVideoPreviewLayer];    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                                            
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) 
    {
        NSLog(@"ERROR : trying to open camera : %@", error);
    }
    
    [session addInput:input]; 
    
    AVCaptureStillImageOutput * stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    
    self.videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                self.videoConnection = connection;
                videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            }
        }
        if (videoConnection) { break; }
    }
                                
    [session startRunning];
}

- (IBAction)playMovie:(id)sender
{    
    NSLog(@"playMovie");
    
    if(!busyRecording && !busyProcessing)
    {
        busyRecording = YES;  
        [self updateButtonVisability:[NSNumber numberWithBool:NO]];
        
        self.imageExtractor = [[ImageExtractor alloc] initWithSequenceLength:15 ];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageExtracted:) name:ImageProcessedTag object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allImageExtracted:) name:AllImagesProcessedTag object:nil];
        [imageExtractor startFromResource:@"ripcurrent.mp4" andWidth:480 andHeight:640];
        NSLog(@"operation started");
        
        //[imageExtractor release];
    }
}

- (IBAction)playVideo:(id)sender
{      
    if(!busyRecording && !busyProcessing)
    {
        busyRecording = YES;
        [self updateButtonVisability:[NSNumber numberWithBool:NO]];
        
        NSArray* sublayers = [imageView.layer sublayers];
        if(sublayers.count==0)
        {
            [imageView.layer addSublayer:captureVideoPreviewLayer];    
        } 
        
        self.imageExtractor = [[ImageExtractor alloc] initWithSequenceLength:15 ];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageExtracted:) name:ImageProcessedTag object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allImageExtracted:) name:AllImagesProcessedTag object:nil];
        [imageExtractor startWithConnection:videoConnection];
        
        //[imageExtractor release];
    }
}


- (IBAction)stopClicked:(id)sender
{    
    // Functionality not yet completed.. 
    
    /*
    busyProcessing = NO;
    busyRecording = NO;
    [self destroyView:YES];
    [self setOutputViewsHidden];    
    [self updateButtonVisability:[NSNumber numberWithBool:YES]];
    self.progressView.progress = 0;
    
    NSArray* sublayers = [imageView.layer sublayers];
    if(sublayers.count==0)
    {
        [imageView.layer addSublayer:captureVideoPreviewLayer];    
    } */
}

-(void) updateButtonVisability:(NSNumber*)visableNumber
{
    //stopButton.hidden = visableNumber.boolValue;
    cameraButton.enabled = visableNumber.boolValue;
    movieButton.enabled = visableNumber.boolValue;
    
    float alpha;
    
    if(visableNumber.boolValue)
    {
        alpha = 1;
    }
    else 
    {   
        alpha = 0.6;
    }
    cameraButton.alpha = alpha;
    movieButton.alpha = alpha;
}

-(void)allImageExtracted:(NSNotification*)notification
{    
    busyProcessing = YES;
    busyRecording = NO;
    
    [self performSelectorOnMainThread:@selector(setOutputViewsVisable) withObject:nil waitUntilDone:NO]; 
    
    
    NSLog(@"allImageExtracted");
    
    NSMutableArray* images = [[[notification userInfo] objectForKey:@"images"] autorelease]; 
    
    if(images.count>=1)
    {
        [self performSelectorOnMainThread:@selector(updateImageView:) withObject:[images objectAtIndex:0] waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(removeCameraFrame) withObject:nil waitUntilDone:NO];
    }   
    
    NSLog(@"restarting mean calculation");
    // Initialize counts and sums
        
    FrameProcessor* frameProcessor = [[[FrameProcessor alloc] init] autorelease];
    for(int i=1 ; i<images.count && busyProcessing ; i++)
    {
        [self performSelectorOnMainThread:@selector(updatePreviousImageView:) withObject:[images objectAtIndex:i-1] waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(updateCurrentImageView:) withObject:[images objectAtIndex:i] waitUntilDone:YES];
        
        UIImage* resultImage;
        [frameProcessor processFrame:[images objectAtIndex:i] 
                   withPreviousFrame:[images objectAtIndex:i-1] 
                    forResultUIImage:&resultImage];
        
        if(!busyProcessing)
        {
            break;
        }
        
        [self performSelectorOnMainThread:@selector(updateImageView:) withObject:resultImage waitUntilDone:NO];
    }
    
    [self performSelectorOnMainThread:@selector(setOutputViewsHidden) withObject:nil waitUntilDone:NO];
    
    if(!busyRecording)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    if(busyProcessing)
    {
        [self performSelectorOnMainThread:@selector(updateButtonVisability:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];        
    }
    
    busyProcessing = NO;    
}

-(void)imageExtracted:(NSNotification*)notification
{
    NSLog(@"imageExtracted");  
    
    NSNumber* progressNumber = [[notification userInfo] objectForKey:@"progressNumber"];
    [self performSelectorOnMainThread:@selector(updateProgressView:) withObject:progressNumber waitUntilDone:NO];
}

-(void)removeCameraFrame
{
    NSArray* sublayers = [imageView.layer sublayers];
    for (int i=0 ; i<sublayers.count; i++) 
    {
        [[sublayers objectAtIndex:i] removeFromSuperlayer];
    }   
}

-(void)updateActivityIndicator:(NSNumber*) animatingNumber
{
    bool animating = animatingNumber.boolValue;
    
    if(animating)
    {
        [activityIndicator startAnimating];
    }
    else
    {
        [activityIndicator stopAnimating];
    }
}

-(void)updateProgressView:(NSNumber*)progressNumber
{
    self.progressView.progress = progressNumber.floatValue;
}

-(void)updateImageView:(UIImage*)image
{
    self.imageView.image = image;
}

-(void)updatePreviousImageView:(UIImage*)image
{
    self.previousImageView.image = image;
}

-(void)updateCurrentImageView:(UIImage*)image
{
    self.currentImageView.image = image;
}


@end
