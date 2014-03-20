//
//  YSCoreTextAttachmentProtocol.h
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/19.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YSCoreTextAttachmentProtocol <NSObject>

+ (void)insertAttachment:(id)attachment
                 atIndex:(NSUInteger)index
      toAttributedString:(NSMutableAttributedString *)attributedString;

- (CGFloat)ascent;
- (CGFloat)descent;
- (CGFloat)width;
- (UIEdgeInsets)contentInset;

@optional
- (UIEdgeInsets)contentEdgeInsets;
- (void)setContentEdgeInsets:(UIEdgeInsets)insets;

- (id)object;
@property (nonatomic) CGPoint drawPoint;

- (NSUInteger)custumLength;

@end
