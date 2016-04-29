//
//  YSCoreTextLayout.h
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/01.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreText;

@interface YSCoreTextLayout : NSObject

- (instancetype)initWithConstraintSize:(CGSize)constraintSize
                      attributedString:(NSAttributedString*)attributedString
                              baseFont:(UIFont*)baseFont
                            textInsets:(UIEdgeInsets)textInsets
                      isAlignmentRight:(BOOL)isAlignmentRight
                      isSizeToFitWidth:(BOOL)isSizeToFitWidth;

@property (nonatomic, readonly) NSAttributedString *attributedString;
@property (nonatomic, readonly) CTFrameRef ctframe;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) UIEdgeInsets textInsets;
@property (nonatomic, readonly) BOOL isAlignmentRight;

@property (nonatomic, readonly) NSMutableArray *highlight; // YSCoreTextHighlight objects

- (void)drawInContext:(CGContextRef)context;

///-----------
/// @name Util
///-----------

- (CGFloat)lineHeightForLineCount:(CFIndex)lineCount;
- (CGFloat)calculatedBaseLine;

@end
