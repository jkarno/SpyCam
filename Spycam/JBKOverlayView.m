//
//  JBKOverlayView.m
//  Spycam
//
//  Created by Josh Karnofsky on 7/25/14.
//  Copyright (c) 2014 Josh Karnofsky. All rights reserved.
//

#import "JBKOverlayView.h"

@implementation JBKOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSLog(@"Overlay");
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    self.layer.contents = (id)[image CGImage];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
