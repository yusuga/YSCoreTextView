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

- (void)drawWithLayout:(YSCoreTextLayout *)layout
{
    _layout = layout;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)dirtyRect
{
    [_layout drawInContext:UIGraphicsGetCurrentContext()];
}

@end
