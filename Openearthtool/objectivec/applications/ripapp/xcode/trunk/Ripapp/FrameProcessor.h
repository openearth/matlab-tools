//
//  FrameProcessor.h
//
//  Created by Deltares & AltenPTS on 6/5/12.
//

#import <UIKit/UIKit.h>

@interface FrameProcessor : NSObject
{
    
}

-(id)init;
-(void)processFrame:(UIImage*)currentFrame withPreviousFrame:(UIImage*)previousFrame forResultUIImage:(UIImage**) resultImag;


@end
