//
//  Rhythm.m
//  Rhythmix
//
//  Created by 严隐 on 15/8/4.
//  Copyright © 2015年 shadowjilu. All rights reserved.
//

#import "Rhythm.h"

@interface Rhythm ()

@property (strong, nonatomic) NSMutableArray *framesInternal;

@end

@implementation Rhythm

- (instancetype)init
{
    self = [super init];
    if (self) {
        _framesInternal = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithArray:(NSArray *)array
{
    self = [self init];
    if (self) {
        if ([array count] > 0) {
            [_framesInternal addObjectsFromArray:array];
        }
    }
    
    return self;
}

- (instancetype)initWithPath:(NSString *)path
{
    NSArray *frames = [NSArray arrayWithContentsOfFile:path];
    return [self initWithArray:frames];
}

- (instancetype)initWithResourceName:(NSString *)name
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    return [self initWithPath:path];
}

- (NSArray *)frames
{
    return _framesInternal;
}

@end
