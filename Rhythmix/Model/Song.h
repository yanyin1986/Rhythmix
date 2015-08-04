//
//  Song.h
//  Rhythmix
//
//  Created by 严隐 on 15/8/4.
//  Copyright © 2015年 shadowjilu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Rhythm;
@interface Song : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic, readonly) NSArray *rhythms;

- (void)addRhythm:(Rhythm *)rhythm;

@end
