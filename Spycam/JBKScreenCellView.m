//
//  JBKScreenCellView.m
//  Spycam
//
//  Created by Josh Karnofsky on 7/31/14.
//  Copyright (c) 2014 Josh Karnofsky. All rights reserved.
//

#import "JBKScreenCellView.h"
#import "JBKImageStore.h"

@interface JBKScreenCellView ()

@end

@implementation JBKScreenCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSLog(@"Loaded a cell");
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 146, 256)];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)displayImage:(UIImage *)image {
    NSLog(@"Setting image for cell");
    [self.imageView setImage:image];
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
