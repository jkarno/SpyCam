//
//  JBKImageStore.m
//  Spycam
//
//  Created by Josh Karnofsky on 7/28/14.
//  Copyright (c) 2014 Josh Karnofsky. All rights reserved.
//

#import "JBKImageStore.h"

@interface JBKImageStore ()

@property (nonatomic, strong) NSMutableArray *imageNumberArray;
@property (nonatomic) NSUInteger nextNumber;

@end

@implementation JBKImageStore

@synthesize imageNumberArray = _imageNumberArray;
@synthesize nextNumber = _nextNumber;

+ (instancetype)sharedStore {
    
    static JBKImageStore *sharedStore = nil;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

- (NSMutableArray *)imageNumberArray {
    _imageNumberArray = (NSMutableArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"imageNumberArray"];
    
    if (!_imageNumberArray) {
        _imageNumberArray = [[NSMutableArray alloc] init];
        [[NSUserDefaults standardUserDefaults] setObject:_imageNumberArray forKey:@"imageNumberArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return _imageNumberArray;
}

- (void)setImageNumberArray:(NSMutableArray *)imageNumberArray {
    _imageNumberArray = imageNumberArray;
    NSLog(@"Array now has images at indices %@", _imageNumberArray);
    
    [[NSUserDefaults standardUserDefaults] setObject:_imageNumberArray forKey:@"imageNumberArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger)nextNumber {
    _nextNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"nextNumber"];
    
    if (!_nextNumber) {
        _nextNumber = 1;
        [[NSUserDefaults standardUserDefaults] setInteger:_nextNumber forKey:@"nextNumber"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return _nextNumber;
}

- (void)setNextNumber:(NSUInteger)nextNumber {
    _nextNumber = nextNumber;
    NSLog(@"Next number now %lu", (unsigned long)_nextNumber);
    
    [[NSUserDefaults standardUserDefaults] setInteger:_nextNumber forKey:@"nextNumber"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[JBKImageStore sharedStore]"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    
    if (self) {

    }
    
    return self;
}

- (void)addImage:(UIImage *)image
{
    NSUInteger indexNumber = self.nextNumber;
    NSString *imageName = [NSString stringWithFormat:@"spycamScreen%lu", (unsigned long)indexNumber];
    self.nextNumber ++;
    
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:imageName]; //Add the file name
    [data writeToFile:filePath atomically:YES]; // Write the file
    
    NSNumber *wrappedIndex = [NSNumber numberWithUnsignedInteger:indexNumber];
    
    NSMutableArray *imagesArray = [self.imageNumberArray mutableCopy];
    [imagesArray addObject:wrappedIndex];
    self.imageNumberArray = imagesArray;
    
    NSLog(@"Saved image with name %@", imageName);
}

- (UIImage *)imageAtIndex:(NSInteger)index
{
    if (index < 0 || index >= [self.imageNumberArray count]) {
        return nil;
    } else {
        NSString *imageName = [NSString stringWithFormat:@"spycamScreen%d", [self.imageNumberArray[index] intValue]];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        NSString *filePath = [documentsPath stringByAppendingPathComponent:imageName]; //Add the file name
        
        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
        UIImage *image = [UIImage imageWithData:imageData];
        
        NSLog(@"Getting image called %@", imageName);
        return image;
    }
}

- (void)deleteImageAtIndex:(NSInteger)index
{
    if (index < 0 || index >= [self.imageNumberArray count]) {
        return;
    } else {
        NSString *imageName = [NSString stringWithFormat:@"spycamScreen%d", [self.imageNumberArray[index] intValue]];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        NSString *filePath = [documentsPath stringByAppendingPathComponent:imageName]; //Add the file name
        
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                
        NSMutableArray *imagesArray = [self.imageNumberArray mutableCopy];
        [imagesArray removeObjectAtIndex:index];
        self.imageNumberArray = imagesArray;
    }
}


- (NSInteger)numberOfImages {
    NSLog(@"Images at indices %@", self.imageNumberArray);
    return [self.imageNumberArray count];
}


@end
