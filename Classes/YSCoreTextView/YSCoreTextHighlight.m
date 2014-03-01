//
//  YSCoreTextHighlight.m
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/01.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSCoreTextHighlight.h"

@implementation YSCoreTextHighlight

+ (instancetype)highlightWithRange:(NSRange)range color:(UIColor*)color
{
    return [[self alloc] initWithRange:range color:color];
}

- (instancetype)initWithRange:(NSRange)range color:(UIColor*)color
{
    if (self = [super init]) {
        _range = range;
        _color = color;
    }
    return self;
}

@end
