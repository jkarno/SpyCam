//
//  JBKImageStore.h
//  Spycam
//
//  Created by Josh Karnofsky on 7/28/14.
//  Copyright (c) 2014 Josh Karnofsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JBKImageStore : NSObject

+ (instancetype) sharedStore;

- (void)addImage:(UIImage *)image;
- (UIImage *)imageAtIndex:(NSInteger)index;
- (void)deleteImageAtIndex:(NSInteger)index;

- (NSInteger)numberOfImages;

@end
