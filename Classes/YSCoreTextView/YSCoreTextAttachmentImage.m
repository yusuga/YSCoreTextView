//
//  YSCoreTextImageAttachment.m
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/19.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSCoreTextAttachmentImage.h"
#import "YSCoreTextConstants.h"

static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if defined(__LP64__) && __LP64__
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

static inline CGFLOAT_TYPE CGFloat_floor(CGFLOAT_TYPE cgfloat) {
#if defined(__LP64__) && __LP64__
    return floor(cgfloat);
#else
    return floorf(cgfloat);
#endif
}

@implementation YSCoreTextAttachmentImage
@synthesize ascent = _ascent;
@synthesize descent = _descent;
@synthesize width = _width;
@synthesize drawPoint = _drawPoint;

+ (YSCoreTextAttachmentImage*)appendImage:(UIImage *)image
                                 withFont:(UIFont *)font
                       toAttributedString:(NSMutableAttributedString *)attributedString
{
    return [self insertImage:image
                    withFont:font
                     atIndex:attributedString.length
          toAttributedString:attributedString];
}

+ (YSCoreTextAttachmentImage*)insertImage:(UIImage*)image
                                 withFont:(UIFont *)font
                                  atIndex:(NSUInteger)index
                       toAttributedString:(NSMutableAttributedString *)attributedString
{
    YSCoreTextAttachmentImage *attachment = [[YSCoreTextAttachmentImage alloc] initWithImage:image
                                                                                        font:font];
    
    [self insertAttachment:attachment atIndex:index toAttributedString:attributedString];
    return attachment;
}

+ (void)insertAttachment:(YSCoreTextAttachmentImage*)attachment
                 atIndex:(NSUInteger)index
      toAttributedString:(NSMutableAttributedString *)attributedString
{
    CTRunDelegateCallbacks callbacks = attachment.callbacks;
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void *)attachment);
    
    CTParagraphStyleRef paragraphStyle = [attachment CTParagraphStyleCreate];
    NSAttributedString *attachmentStr = [[NSAttributedString alloc] initWithString:OBJECT_REPLACEMENT_CHARACTER
                                                                        attributes:@{(id)kCTRunDelegateAttributeName : (__bridge id)runDelegate,
                                                                                     kYSCoreTextAttachment : attachment,
                                                                                     (id)kCTParagraphStyleAttributeName : (__bridge id)paragraphStyle}];
    
    CFRelease(runDelegate);
    CFRelease(paragraphStyle);
    
    if (attributedString.length <= index) {
        [attributedString appendAttributedString:attachmentStr];
    } else {
        [attributedString insertAttributedString:attachmentStr atIndex:index];
    }
}

- (id)initWithImage:(UIImage *)image
               font:(UIFont *)font
{
    return [self initWithImage:image ascent:font.ascender descent:font.descender];
}

- (instancetype)initWithImage:(UIImage*)image
                       ascent:(CGFloat)ascent
                      descent:(CGFloat)descent
{
    if (self = [super init]) {
        _object = image;
        _width = image.size.width;
        _ascent = CGFloat_ceil(ascent);
        _descent = CGFloat_floor(descent);
        
        self.contentInset = UIEdgeInsetsZero;
        self.contentEdgeInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (CGPoint)drawPoint
{
    return CGPointMake(self.contentEdgeInsets.left + _drawPoint.x - self.contentEdgeInsets.right,
                       self.contentEdgeInsets.top + _drawPoint.y - self.contentEdgeInsets.bottom);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{\n\
            %@, %@, ascent: %f, descent: %f\n}", [super description], self.object, self.ascent, self.descent];
}

@end
