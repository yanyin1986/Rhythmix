//
//  GlobalSetting.m
//  Rhythmix
//
//  Created by yin.yan on 7/7/15.
//  Copyright © 2015 tinycomic. All rights reserved.
//

#import "GlobalSetting.h"

@interface GlobalSetting ()

@property (nonatomic, strong) NSMutableArray *assets;

@end

@implementation GlobalSetting

+ (GlobalSetting *)sharedInstance
{
    static GlobalSetting *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GlobalSetting alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _assets = [NSMutableArray array];
    }
    
    return self;
}

- (ALAsset *)assetWithIndex:(NSInteger)index
{
    if (index < _assets.count) {
        return _assets[index];
    }
    return nil;
}

- (NSUInteger)selectedAssetsCount
{
    return _assets.count;
}

- (void)addAsset:(ALAsset *)asset
{
    [_assets addObject:asset];
}

- (void)removeAssetAtIndex:(NSUInteger)index
{
    if (index < _assets.count) {
        [_assets removeObjectAtIndex:index];
    }
}

- (void)clearAllAssets
{
    [_assets removeAllObjects];
}

@end
