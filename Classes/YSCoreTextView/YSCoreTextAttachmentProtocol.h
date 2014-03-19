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

- (CGSize)size;
- (UIEdgeInsets)contentInset;

@optional
- (id)object;
@property (nonatomic) CGPoint drawPoint;

- (UIEdgeInsets)contentOffset;

@end
