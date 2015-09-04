//
//  JBKReviewGuideViewController.m
//  Spycam
//
//  Created by Josh Karnofsky on 8/6/14.
//  Copyright (c) 2014 Josh Karnofsky. All rights reserved.
//

#import "JBKReviewGuideViewController.h"

@interface JBKReviewGuideViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;

@end

@implementation JBKReviewGuideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)userPushedBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.scroller setScrollEnabled:YES];
    [self.scroller setContentSize:CGSizeMake(320, 1956)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
