//
//  GlobalSetting.h
//  Rhythmix
//
//  Created by yin.yan on 7/7/15.
//  Copyright © 2015 tinycomic. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>

@interface GlobalSetting : NSObject


+ (GlobalSetting *)sharedInstance;
- (ALAsset *)assetWithIndex:(NSInteger)index;
- (NSUInteger)selectedAssetsCount;
- (void)addAsset:(ALAsset *)asset;
- (void)clearAllAssets;
- (void)removeAssetAtIndex:(NSUInteger)index;

@end
