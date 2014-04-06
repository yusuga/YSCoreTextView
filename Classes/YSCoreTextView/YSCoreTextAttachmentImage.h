//
//  YSCoreTextImageAttachment.h
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/19.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSCoreTextAttachment.h"

@interface YSCoreTextAttachmentImage : YSCoreTextAttachment

+ (YSCoreTextAttachmentImage*)appendImage:(UIImage*)image
                                 withFont:(UIFont*)font
                       toAttributedString:(NSMutableAttributedString*)attributedString;

+ (YSCoreTextAttachmentImage*)insertImage:(UIImage*)image
                                 withFont:(UIFont*)font
                                  atIndex:(NSUInteger)index
                       toAttributedString:(NSMutableAttributedString*)attributedString;

- (instancetype)initWithImage:(UIImage*)image
                         font:(UIFont*)font;

- (instancetype)initWithImage:(UIImage*)image
                       ascent:(CGFloat)ascent
                      descent:(CGFloat)descent;

- (CTParagraphStyleRef)CTParagraphStyleCreate;

/* YSCoreTextAttachmentProtocol */
+ (void)insertAttachment:(YSCoreTextAttachmentImage*)attachment
                 atIndex:(NSUInteger)index
      toAttributedString:(NSMutableAttributedString *)attributedString;

@property (nonatomic, readonly) CGFloat ascent;
@property (nonatomic, readonly) CGFloat descent;
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic) UIEdgeInsets contentInset;
@property (nonatomic) UIEdgeInsets contentEdgeInsets;
@property (nonatomic, readonly) id object;

@end
