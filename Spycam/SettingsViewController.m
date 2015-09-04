//
//  JBKSettingViewController.m
//  Spycam
//
//  Created by Josh Karnofsky on 7/28/14.
//  Copyright (c) 2014 Josh Karnofsky. All rights reserved.
//

#import "SettingsViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "JBKImageStore.h"
#import "JBKCamViewController.h"
#import "Chameleon.h"
#import "ProgressHUD.h"
#import "JBKFakeScreenCollectionViewController.h"
#import "JBKReviewGuideViewController.h"

@interface SettingsViewController ()

@property (nonatomic, strong) IBOutlet UISwitch *showIndicatorsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *vibrateSwitch;

@end

@implementation SettingsViewController

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
    // Do any additional setup after loading the view.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.showIndicatorsSwitch setOn:[defaults boolForKey:@"spycamIndicators"]];
    [self.vibrateSwitch setOn:[defaults boolForKey:@"spycamVibrate"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)userDidChangeIndicators:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:sender.isOn forKey:@"spycamIndicators"];
    [defaults synchronize];
}

- (IBAction)userDidChangeVibrate:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:sender.isOn forKey:@"spycamVibrate"];
    [defaults synchronize];
}

- (IBAction)clickedAddFakeScreens:(UIButton *)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"Got image");
    [[JBKImageStore sharedStore] addImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self performSelector:@selector(addScreenShowSuccess) withObject:self afterDelay:0.5];
}

- (void)addScreenShowSuccess {
    [ProgressHUD showSuccess:@"Added new screen!"];
}

- (IBAction)clickedManageFakeScreens:(UIButton *)sender {
    // Make a view showing thumbnails of fake screens
    JBKFakeScreenCollectionViewController *fsvc = [[JBKFakeScreenCollectionViewController alloc] init];
    [self presentViewController:fsvc animated:YES completion:nil];
}

- (IBAction)clickedReviewGuide:(UIButton *)sender {
    // Show the intro view page
    JBKReviewGuideViewController *rgc = [[JBKReviewGuideViewController alloc] init];
    rgc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:rgc animated:YES completion:nil];
}

- (IBAction)clickedBackButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
