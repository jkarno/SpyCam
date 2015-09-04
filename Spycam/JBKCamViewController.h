//
//  JBKCamViewController.h
//  Spycam
//
//  Created by Josh Karnofsky on 7/13/14.
//  Copyright (c) 2014 Josh Karnofsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAIntroView.h"
#import "EAIntroPage.h"

@interface JBKCamViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, EAIntroDelegate>

- (void)showIntroView;

@end
