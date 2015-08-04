//
//  Song.m
//  Rhythmix
//
//  Created by 严隐 on 15/8/4.
//  Copyright © 2015年 shadowjilu. All rights reserved.
//

#import "Song.h"
#import "Rhythm.h"

@interface Song ()

@property (strong, nonatomic) NSMutableArray *rhythmsInternal;

@end

@implementation Song

- (instancetype)init
{
    self = [super init];
    if (self) {
        _rhythmsInternal = [NSMutableArray array];
    }
    return self;
}

- (void)addRhythm:(Rhythm *)rhythm
{
    [_rhythmsInternal addObject:rhythm];
}

- (NSArray *)rhythms
{
    return _rhythmsInternal;
}

@end
