//
//  YSCoreTextImageAttachment.h
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/19.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSCoreTextAttachment.h"

@interface YSCoreTextAttachmentImage : YSCoreTextAttachment

+ (void)appendImage:(UIImage*)image
  contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets
 toAttributedString:(NSMutableAttributedString*)attributedString;

+ (void)insertImage:(UIImage*)image
  contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets
            atIndex:(NSUInteger)index
 toAttributedString:(NSMutableAttributedString*)attributedString;

+ (void)insertAttachment:(YSCoreTextAttachment*)attachment
                 atIndex:(NSUInteger)index
      toAttributedString:(NSMutableAttributedString *)attributedString;

- (id)initWithObject:(id)object size:(CGSize)size contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets;

@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) UIEdgeInsets contentEdgeInsets;
@property (nonatomic, readonly) id object;

@end
