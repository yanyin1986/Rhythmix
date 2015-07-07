//
//  AssetPickerViewController.m
//  Rhythmix
//
//  Created by yin.yan on 7/7/15.
//  Copyright © 2015 tinycomic. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetPickerViewController.h"
#import "AssetCollectionViewCell.h"
#import "GlobalSetting.h"
#import "ViewController.h"


@interface AssetPickerViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *assetCollectionView;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) ALAssetsLibrary *library;
@property (nonatomic, strong) NSMutableArray *assets;

@end

@implementation AssetPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)_assetCollectionView.collectionViewLayout;
    //layout.minimumInteritemSpacing = 2.5;
    //layout.minimumLineSpacing = 2.5;
    
    self.view.frame = [UIScreen mainScreen].bounds;
    UINib *nib = [UINib nibWithNibName:@"AssetCollectionViewCell" bundle:[NSBundle mainBundle]];
    [_assetCollectionView registerNib:nib forCellWithReuseIdentifier:@"AssetCollectionViewCell"];
    
    _assets = [NSMutableArray array];
    _library = [[ALAssetsLibrary alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkAssetsAuth];
}

- (void)checkAssetsAuth
{
    ALAuthorizationStatus authorStatus = [ALAssetsLibrary authorizationStatus];
    switch (authorStatus) {
        case ALAuthorizationStatusAuthorized:
        case ALAuthorizationStatusNotDetermined:
        {
            [self scanALAssets];
        }
            break;
        case ALAuthorizationStatusDenied:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Have No Permission!"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
            [alertView show];
        }
            break;
        default:
        {
            
        }
            break;
    }
}

- (void)scanALAssets
{
    NSMutableArray *assetsArray = [NSMutableArray array];
    NSMutableSet *assetsSet = [NSMutableSet set];
    
    __weak typeof(self) weakSelf = self;
    ALAssetsLibraryGroupsEnumerationResultsBlock enumerationBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        if ([group numberOfAssets] > 0) {
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    if (![assetsSet containsObject:result.defaultRepresentation.url]) {
                        [assetsSet addObject:result.defaultRepresentation.url];
                        [assetsArray addObject:result];
                    } else {
                        WARN(@"dumplicate one");
                    }
                    
                }
            }];
        }
        
        if (!group) {
            [assetsArray sortUsingComparator:^NSComparisonResult(ALAsset *obj1, ALAsset *obj2) {
                NSDate* date1 = [obj1 valueForProperty:ALAssetPropertyDate];
                NSDate* date2 = [obj2 valueForProperty:ALAssetPropertyDate];
                
                CGFloat value = [date1 timeIntervalSince1970] - [date2 timeIntervalSince1970];
                
                return (value > 0 ?
                        NSOrderedAscending :
                        (value == 0 ? NSOrderedSame : NSOrderedDescending));
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (assetsArray.count == 0) {
                    /*
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"There is no video clip in your albums"
                                                                        message:@"Please record some first"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    
                    [alertView showWithCompletion:^(UIAlertView *alertView, BOOL canceled, NSInteger buttonIdx) {
                        
                    }];
                     */
                } else {
                    weakSelf.assets = assetsArray;
                    [weakSelf.assetCollectionView reloadData];
                }
            });
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
    };
    
    [self.library enumerateGroupsWithTypes:ALAssetsGroupAll
                                usingBlock:enumerationBlock
                              failureBlock:failureBlock];
}

- (IBAction)nextButtonPressed:(id)sender
{
    ViewController *viewController = [[ViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -  <UICollectionViewDataSource>
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _assets.count;
}

- (UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *identifier = @"AssetCollectionViewCell";
    
    AssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    ALAsset *asset = [_assets objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
    
    return cell;
}

#pragma mark -  <UICollectionViewDelegate>
- (void)collectionView:(nonnull UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [[GlobalSetting sharedInstance] addAsset:_assets[indexPath.row]];
    
    _nextButton.enabled = [[GlobalSetting sharedInstance] selectedAssetsCount] > 0;
}


@end
