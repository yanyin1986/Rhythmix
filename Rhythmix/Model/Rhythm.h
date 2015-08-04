//
//  Rhythm.h
//  Rhythmix
//
//  Created by 严隐 on 15/8/4.
//  Copyright © 2015年 shadowjilu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Rhythm : NSObject

@property (assign, nonatomic) NSUInteger frameCount;
@property (strong, nonatomic, readonly) NSArray *frames;

- (instancetype)initWithPath:(NSString *)path;
- (instancetype)initWithResourceName:(NSString *)resourceName;
- (instancetype)initWithArray:(NSArray *)frameArray;

@end
