//
//  JBKCamViewController.m
//  Spycam
//
//  Created by Josh Karnofsky on 7/13/14.
//  Copyright (c) 2014 Josh Karnofsky. All rights reserved.
//

#import "JBKCamViewController.h"
#import "JBKCustomCameraViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "JBKOverlayView.h"
#import "SettingsViewController.h"
#import "JBKImageStore.h"
#import "Chameleon.h"
#import "ProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface JBKCamViewController ()

@property (nonatomic, strong) JBKCustomCameraViewController *picker;
@property (nonatomic, getter = isRecording) bool recording;
@property (nonatomic, getter = isCameraReady) bool cameraReady;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, strong) JBKOverlayView *overlayView;

@end

@implementation JBKCamViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"Launched before, the app has %ld screens", (long)[[JBKImageStore sharedStore] numberOfImages]);
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        // app already launched
        [self introDidFinish:nil];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"spycamIndicators"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"spycamVibrate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // This is the first launch ever
        NSLog(@"First time launching");
        [self showIntroView];
    }
}

- (void)introDidFinish:(EAIntroView *)introView {
    
    // Checking if allowed photos
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photo Access Denied" message:@"Spycam requires access to your device's Photos library in order to store recordings.\n\nPlease enable Photo access for this app in Settings / Privacy / Photos" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    
    // Checking if allowed microphone
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            // the user doesn't have permission
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Microphone Access Denied"
                                            message:@"Spycam requires access to your device's Microphone in order to record audio.\n\nPlease enable Microphone access for this app in Settings / Privacy / Microphone"
                                           delegate:nil
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:nil] show];
            });
        }
    }];

    
    NSLog(@"Allocating picker");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.picker = [[JBKCustomCameraViewController alloc] init];
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        self.picker.showsCameraControls = NO;
        self.picker.delegate = self;
        self.picker.navigationBarHidden = YES;
        self.picker.allowsEditing = NO;
        self.picker.toolbarHidden = YES;
        self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        self.picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
        
        // Overlay
        UIView *enhancementOverlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.picker.cameraOverlayView = enhancementOverlay;
        
        self.overlayView = [[JBKOverlayView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self setUpGesturesWithView:self.overlayView];
        self.overlayView.backgroundColor = [UIColor blackColor];
        
        //        self.picker.cameraOverlayView = overlayView;
        [self.picker.view addSubview:self.overlayView];
        [self presentViewController:self.picker animated:NO completion:nil];
        
        // Set notification for camera ready
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cameraIsReady)
                                                     name:AVCaptureSessionDidStartRunningNotification object:nil];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"It appears that you do not have a camera to use." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)setUpGesturesWithView:(JBKOverlayView *)view {
    view.multipleTouchEnabled = YES;
    
    UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerTap)];
    [oneFingerTap setNumberOfTouchesRequired:1];
    
    [view addGestureRecognizer:oneFingerTap];
    
    UITapGestureRecognizer *threeFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(threeFingerTap)];
    [threeFingerTap setNumberOfTouchesRequired:3];
    
    [view addGestureRecognizer:threeFingerTap];
    
    UISwipeGestureRecognizer *twoFingerSwipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerSwipeDown)];
    [twoFingerSwipeDown setNumberOfTouchesRequired:2];
    [twoFingerSwipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    
    [view addGestureRecognizer:twoFingerSwipeDown];
    
    UISwipeGestureRecognizer *twoFingerSwipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerSwipeUp)];
    [twoFingerSwipeUp setNumberOfTouchesRequired:2];
    [twoFingerSwipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    
    [view addGestureRecognizer:twoFingerSwipeUp];
    
    UISwipeGestureRecognizer *twoFingerSwipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerSwipeRight)];
    [twoFingerSwipeRight setNumberOfTouchesRequired:2];
    [twoFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [view addGestureRecognizer:twoFingerSwipeRight];
    
    UISwipeGestureRecognizer *twoFingerSwipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerSwipeLeft)];
    [twoFingerSwipeLeft setNumberOfTouchesRequired:2];
    [twoFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    [view addGestureRecognizer:twoFingerSwipeLeft];
}

- (void)cameraIsReady {
    NSLog(@"Camera is ready");
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"spycamIndicators"]) {
        [ProgressHUD dismiss];
    }
    self.cameraReady = YES;
}

#pragma mark Gesture Controls

- (void)oneFingerTap {
    if (self.isCameraReady) {
        if (self.picker.cameraCaptureMode == UIImagePickerControllerCameraCaptureModePhoto) {
            [self.picker takePicture];
        } else {
            if (self.isRecording) {
                [self.picker stopVideoCapture];
                self.recording = NO;
            } else {
                [self.picker startVideoCapture];
                self.recording = YES;
            }
        }
    } else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"spycamIndicators"]) {
            // Show indicator couldn't switch
            [ProgressHUD showError:@"Camera still switching modes!"];
        }
    }
}

- (void)threeFingerTap {
    NSLog(@"Switched modes");
    if (self.isCameraReady) {
        if (self.isRecording) {
            [self.picker stopVideoCapture];
            self.recording = NO;
        }
        if (self.picker.cameraCaptureMode == UIImagePickerControllerCameraCaptureModePhoto) {
            [self.picker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"spycamIndicators"]) {
                [ProgressHUD showSuccess:@"Switching to video mode"];
            }
        } else {
            [self.picker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"spycamIndicators"]) {
                [ProgressHUD showSuccess:@"Switching to photo mode"];
            }
        }
        self.cameraReady = NO;
        [self performSelector:@selector(cameraIsReady) withObject:self afterDelay:1.5];
    } else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"spycamIndicators"]) {
            // Show indicator couldn't switch
            [ProgressHUD showError:@"Camera still switching modes!"];
        }
    }
}

- (void)twoFingerSwipeDown {
    NSLog(@"You swiped down with two fingers");
    SettingsViewController *svc = [[SettingsViewController alloc] init];
    [self.picker presentViewController:svc animated:YES completion:nil];
    self.currentIndex = -1;
}

- (void)twoFingerSwipeUp {
    NSLog(@"You swiped up with two fingers");
    if (self.isCameraReady) {
        if (self.isRecording) {
            [self.picker stopVideoCapture];
            self.recording = NO;
        }
        if (self.picker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
            [self.picker setCameraDevice:UIImagePickerControllerCameraDeviceRear];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"spycamIndicators"]) {
                [ProgressHUD showSuccess:@"Switching to rear camera"];
            }
            self.cameraReady = NO;
            [self performSelector:@selector(cameraIsReady) withObject:self afterDelay:1.5];
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            [self.picker setCameraDevice:UIImagePickerControllerCameraDeviceFront];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"spycamIndicators"]) {
                [ProgressHUD showSuccess:@"Switching to front camera"];
            }
            self.cameraReady = NO;
            [self performSelector:@selector(cameraIsReady) withObject:self afterDelay:1.5];
        } else {
            [ProgressHUD showError:@"Sorry, it looks like you don't have a front camera."];
        }
    } else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"spycamIndicators"]) {
            // Show indicator couldn't switch
            [ProgressHUD showError:@"Camera still switching modes!"];
        }
    }
}

- (void)twoFingerSwipeRight {
    NSLog(@"You swiped right with two fingers");
    
    if (self.currentIndex > -1) {
        NSLog(@"Switched background");
        self.currentIndex --;
    }
}

- (void)twoFingerSwipeLeft {
    NSLog(@"You swiped left with two fingers");
    
    UIImage *image = [[JBKImageStore sharedStore] imageAtIndex:(self.currentIndex+1)];
    
    if (image) {
        NSLog(@"Switched background");
        self.currentIndex++;
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    
    if (currentIndex == -1) {
        [self.overlayView setImage:nil];
    } else {
        UIImage *image = [[JBKImageStore sharedStore] imageAtIndex:(self.currentIndex)];
        [self.overlayView setImage:image];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.movie"]) {
        NSLog(@"Caught video");
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *videoPath = [videoURL path];
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath,nil,nil,nil);
        
        self.cameraReady = NO;
        [self performSelector:@selector(cameraIsReady) withObject:self afterDelay:0.5];
        
    } else if ([mediaType isEqualToString:@"public.image"]) {
        NSLog(@"Caught picture");
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"spycamVibrate"]) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize bools
    self.recording = NO;
    self.cameraReady = NO;
    
    // Do any additional setup after loading the view.
    self.currentIndex = -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Intro

- (void)showIntroView {
    EAIntroPage *page1 = [EAIntroPage page];
    page1.bgImage = [UIImage imageNamed:@"introSpy"];
    page1.title = @"Welcome Super Sleuth";
    page1.desc = @"Congratulations! \nYou have just taken the first step \nto becoming a world class spy!\n\nThe following guide will explain how to use Spycam.";
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.bgImage = [UIImage imageNamed:@"oneFinger"];
    page2.desc = @"A one finger tap takes a picture \nor begins/finishes recording video \ndepending on your chosen \ncamera mode.";
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.bgImage = [UIImage imageNamed:@"threeFinger"];
    page3.title = @"A three finger tap changes between camera and video modes.";
    page3.desc = @"\n\nNote that the mode takes about one second to switch, so be sure to set the mode in advance!";
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.bgImage = [UIImage imageNamed:@"twoFingerUp"];
    page4.title = @"A two finger swipe upwards will switch between the front and rear cameras.";
    page4.desc = @"\n\n\nNote that this takes time as well, and cannot be changed in the middle of a recording.";
    
    EAIntroPage *page5 = [EAIntroPage page];
    page5.bgImage = [UIImage imageNamed:@"twoFingerDown"];
    page5.title = @"A two finger swipe downwards will open the settings panel.";
    page5.desc = @"\n\nTip: The settings panel will allow you to review this guide again at any time.";
    
    EAIntroPage *page6 = [EAIntroPage page];
    page6.bgImage = [UIImage imageNamed:@"settingsImage"];
    page6.title = @"Within the settings, you can add screenshots to disguise the application. You can remove them using the manage button.";
    page6.desc = @"\n\n\n\nTip: We recommend taking screenshots with your own phone so that the size matches your screen.";
    page6.titlePositionY = 250;
    page6.descPositionY = 230;
    
    EAIntroPage *page7 = [EAIntroPage page];
    page7.bgImage = [UIImage imageNamed:@"twoFingerLeftRight"];
    page7.title = @"At the end of this guide, Spycam will start in camera mode with a default black screen.";
    page7.desc = @"\n\nOnce you have added your own screens, a two finger swipe to the left or right from the camera will allow you to switch between available screens.";
    
    EAIntroPage *page8 = [EAIntroPage page];
    page8.bgImage = [UIImage imageNamed:@"introSpy"];
    page8.title = @"Congrats again! You made it through the boring stuff.";
    page8.desc = @"\n\nNow get to sleuthing!";
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:[[UIScreen mainScreen] bounds] andPages:@[page1,page2,page3,page4,page5,page6,page7,page8]];
    [intro setDelegate:self];

    intro.titleViewY = 90;
    intro.showSkipButtonOnlyOnLastPage = YES;

    intro.backgroundColor = [UIColor colorWithRed:0.188f green:0.2f blue:0.239 alpha:1.0f];
    
    [intro showInView:self.view animateDuration:0.3];
}

@end
