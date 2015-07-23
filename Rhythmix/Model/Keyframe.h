//
//  Keyframe.h
//  Rhythmix
//
//  Created by yin.yan on 7/7/15.
//  Copyright © 2015 tinycomic. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    KeyFrameActionBegin,
    KeyFrameActionEnd,
    KeyFrameActionHideTitle,
    KeyFrameActionChange,
    KeyFrameActionUp,
    KeyFrameActionDown,
    KeyFrameActionLeft,
    KeyFrameActionRight,
} KeyFrameAction;

@interface KeyFrame : NSObject

@property (nonatomic,assign) double time;
@property (nonatomic,assign) KeyFrameAction action;

@end
