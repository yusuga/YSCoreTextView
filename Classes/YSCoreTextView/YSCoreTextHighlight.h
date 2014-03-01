//
//  YSCoreTextHighlight.h
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/01.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSCoreTextHighlight : NSObject

+ (instancetype)highlightWithRange:(NSRange)range color:(UIColor*)color;
- (instancetype)initWithRange:(NSRange)range color:(UIColor*)color;

@property (nonatomic, readonly) NSRange range;
@property (nonatomic, readonly) UIColor *color;

@end
