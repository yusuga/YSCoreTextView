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

- (id)initWithConstraintWidth:(CGFloat)constraintWidth
                         text:(NSString*)text
                   attributes:(NSDictionary*)attributes;

- (id)initWithConstraintWidth:(CGFloat)constraintWidth
             attributedString:(NSAttributedString*)attributedString;

@property (nonatomic, readonly) NSAttributedString *attributedString;
@property (nonatomic, readonly) CTFrameRef ctframe;
@property (nonatomic, readonly) CGSize size;

@property (nonatomic) NSMutableArray *hightlight; // YSCoreTextHighlight objects
- (void)drawInContext:(CGContextRef)context;

@end
