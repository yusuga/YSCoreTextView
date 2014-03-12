//
//  YSCoreTextAttachment.h
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/11.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreText;

/*
 Base code from SECoreTextView (https://github.com/kishikawakatsumi/SECoreTextView>
 Copyright (c) 2013 kishikawa katsumi (http://kishikawakatsumi.com/)
 All rights reserved.
 MIT license
 */

@interface YSCoreTextAttachment : NSObject

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

@property (nonatomic, readonly) id object;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) UIEdgeInsets contentEdgeInsets;
@property (nonatomic) CGPoint drawPoint;

@property (nonatomic, readonly) CTRunDelegateCallbacks callbacks;

@end
