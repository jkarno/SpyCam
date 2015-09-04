//
//  JBKFakeScreenCollectionViewController.m
//  Spycam
//
//  Created by Josh Karnofsky on 7/31/14.
//  Copyright (c) 2014 Josh Karnofsky. All rights reserved.
//

#import "JBKFakeScreenCollectionViewController.h"
#import "JBKImageStore.h"
#import "JBKScreenCellView.h"
#import "Chameleon.h"
#import <QuartzCore/QuartzCore.h>

@interface JBKFakeScreenCollectionViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *screenCollectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashCanButton;
@property (nonatomic, strong) NSMutableArray *selectedCells;

@end

@implementation JBKFakeScreenCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[JBKImageStore sharedStore] numberOfImages];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JBKScreenCellView *cell = (JBKScreenCellView *)[collectionView dequeueReusableCellWithReuseIdentifier:@"screenCell" forIndexPath:indexPath];
    [cell displayImage:[[JBKImageStore sharedStore] imageAtIndex:indexPath.row]];
    
    if (![self.selectedCells containsObject:[NSNumber numberWithFloat:indexPath.row]]) {
        NSLog(@"Deselecting cell");
        cell.imageView.alpha = 1.0f;
        cell.layer.borderColor = nil;
        cell.layer.borderWidth = 0.0f;
    } else {
        NSLog(@"Selecting cell");
        cell.imageView.alpha = 0.6f;
        cell.layer.borderColor = FlatOrange.CGColor;
        cell.layer.borderWidth = 3.0f;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.selectedCells containsObject:[NSNumber numberWithFloat:indexPath.row]]) {
        [self.selectedCells removeObject:[NSNumber numberWithFloat:indexPath.row]];
    } else {
        [self.selectedCells addObject:[NSNumber numberWithFloat:indexPath.row]];
    }
    
    self.trashCanButton.enabled = [self.selectedCells count];

    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (IBAction)userClickedTrash:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete the selected fake screens?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Screens" otherButtonTitles:nil,nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
        NSArray *array = [self.selectedCells sortedArrayUsingDescriptors: [NSArray arrayWithObject:sortOrder]];
        
        for (NSNumber *selected in array) {
            NSLog(@"Deleting %@", selected);
            NSInteger index = [selected intValue];
            [[JBKImageStore sharedStore] deleteImageAtIndex:index];
        }
        
        [self.selectedCells removeAllObjects];
        self.trashCanButton.enabled = NO;
        [self.screenCollectionView reloadData];
    }
}

- (IBAction)userClickedBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenCollectionView.dataSource = self;
    self.screenCollectionView.delegate = self;
    self.screenCollectionView.allowsMultipleSelection = YES;
    self.selectedCells = [[NSMutableArray alloc] init];
    
    [self.screenCollectionView registerClass:[JBKScreenCellView class] forCellWithReuseIdentifier:@"screenCell"];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
