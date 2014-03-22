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

- (void)drawRect:(CGRect)dirtyRect
{
    [self.layout drawInContext:UIGraphicsGetCurrentContext()];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return self.layout.size;
}

@end
