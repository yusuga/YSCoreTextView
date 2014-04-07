//
//  YSCoreTextImageAttachment.m
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/19.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSCoreTextAttachmentImage.h"
#import "YSCoreTextConstants.h"

@implementation YSCoreTextAttachmentImage
@synthesize ascent = _ascent;
@synthesize descent = _descent;
@synthesize width = _width;
@synthesize drawPoint = _drawPoint;

- (id)initWithImage:(UIImage *)image
               font:(UIFont *)font
     paragraphStyle:(CTParagraphStyleRef)paragraphStyle
{
    return [self initWithImage:image
                        ascent:font.ascender
                       descent:font.descender
                paragraphStyle:paragraphStyle];
}

- (instancetype)initWithImage:(UIImage*)image
                       ascent:(CGFloat)ascent
                      descent:(CGFloat)descent
               paragraphStyle:(CTParagraphStyleRef)paragraphStyle
{
    if (self = [super init]) {
        _object = image;
        _width = image.size.width;
        _ascent = ascent;
        _descent = descent;
        
        self.contentInset = UIEdgeInsetsZero;
        self.contentEdgeInsets = UIEdgeInsetsZero;
        
        CTRunDelegateCallbacks callbacks = self.callbacks;
        CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void *)self);
        
        NSMutableDictionary *attr = @{(id)kCTRunDelegateAttributeName : (__bridge id)runDelegate,
                                      kYSCoreTextAttachment : self}.mutableCopy;
        SAFE_CFRELEASE(runDelegate);
        
        if (paragraphStyle) {
            [attr setObject:(__bridge id)paragraphStyle forKey:(id)kCTParagraphStyleAttributeName];
        }
        _attachmentString = [[NSAttributedString alloc] initWithString:OBJECT_REPLACEMENT_CHARACTER
                                                            attributes:attr];
    }
    return self;
}

#pragma mark - YSCoreTextAttachmentProtocol

- (CGPoint)drawPoint
{
    return CGPointMake(self.contentEdgeInsets.left + _drawPoint.x - self.contentEdgeInsets.right,
                       self.contentEdgeInsets.top + _drawPoint.y - self.contentEdgeInsets.bottom);
}

#pragma mark -

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ %@, object: %@, ascent: %f, descent: %f }", [super description], self.object, self.ascent, self.descent];
}

@end
