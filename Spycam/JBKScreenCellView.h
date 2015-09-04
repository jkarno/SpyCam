//
//  JBKScreenCellView.h
//  Spycam
//
//  Created by Josh Karnofsky on 7/31/14.
//  Copyright (c) 2014 Josh Karnofsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JBKScreenCellView : UICollectionViewCell

@property (strong, nonatomic) UILabel *selectedLabel;
@property (strong, nonatomic) UIImageView *imageView;

- (void)displayImage:(UIImage *)image;

@end
