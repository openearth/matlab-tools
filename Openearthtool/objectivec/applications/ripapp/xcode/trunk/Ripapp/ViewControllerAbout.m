//
//  ViewControllerAbout.m
//
//  Created by AltenPTS & Deltares
//

#import "ViewControllerAbout.h"

@interface ViewControllerAbout ()

@end

@implementation ViewControllerAbout

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:@"More info" style:UIBarButtonItemStyleDone target:self action:@selector(moreInfoClicked)];    
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void) viewWillAppear:(BOOL)animated
{    
    self.navigationItem.title = @"RipApp";
}

-(void) moreInfoClicked
{    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.muienradar.nl"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
