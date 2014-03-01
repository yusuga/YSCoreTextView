//
//  YSCoreTextView.m
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/01.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSCoreTextView.h"

@interface YSCoreTextView ()

@end

@implementation YSCoreTextView

- (void)draw
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)dirtyRect
{
    [self.layout drawInContext:UIGraphicsGetCurrentContext()];
}

@end
