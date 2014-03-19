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
                       toAttributedString:(NSMutableAttributedString*)attributedString;

+ (YSCoreTextAttachmentImage*)insertImage:(UIImage*)image
                                  atIndex:(NSUInteger)index
                       toAttributedString:(NSMutableAttributedString*)attributedString;

- (instancetype)initWithObject:(id)object size:(CGSize)size;

/* YSCoreTextAttachmentProtocol */
+ (void)insertAttachment:(YSCoreTextAttachmentImage*)attachment
                 atIndex:(NSUInteger)index
      toAttributedString:(NSMutableAttributedString *)attributedString;

@property (nonatomic, readonly) CGSize size;
@property (nonatomic) UIEdgeInsets contentInset;
@property (nonatomic) UIEdgeInsets contentOffset;
@property (nonatomic, readonly) id object;

@end
