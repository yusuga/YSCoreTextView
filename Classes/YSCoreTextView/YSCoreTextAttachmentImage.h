//
//  YSCoreTextImageAttachment.h
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/19.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSCoreTextAttachment.h"

@interface YSCoreTextAttachmentImage : YSCoreTextAttachment

- (instancetype)initWithImage:(UIImage*)image
                         font:(UIFont*)font
               paragraphStyle:(CTParagraphStyleRef)paragraphStyle;

- (instancetype)initWithImage:(UIImage*)image
                       ascent:(CGFloat)ascent
                      descent:(CGFloat)descent
               paragraphStyle:(CTParagraphStyleRef)paragraphStyle;

/* YSCoreTextAttachmentProtocol */
@property (nonatomic, readonly) NSAttributedString *attachmentString;
@property (nonatomic, readonly) CGFloat ascent;
@property (nonatomic, readonly) CGFloat descent;
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic) UIEdgeInsets contentInset;
@property (nonatomic) UIEdgeInsets contentEdgeInsets;
@property (nonatomic, readonly) id object;

@end
