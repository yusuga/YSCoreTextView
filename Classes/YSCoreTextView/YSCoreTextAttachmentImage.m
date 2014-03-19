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
@synthesize size = _size;
@synthesize drawPoint = _drawPoint;
@synthesize contentEdgeInsets = _contentEdgeInsets;

+ (void)appendImage:(UIImage*)image
  contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets
 toAttributedString:(NSMutableAttributedString *)attributedString
{
    [self insertImage:image contentEdgeInsets:contentEdgeInsets atIndex:attributedString.length toAttributedString:attributedString];
}

+ (void)insertImage:(UIImage*)image
  contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets
            atIndex:(NSUInteger)index
 toAttributedString:(NSMutableAttributedString *)attributedString
{
    YSCoreTextAttachmentImage *attachment = [[YSCoreTextAttachmentImage alloc] initWithObject:image
                                                                                         size:image.size
                                                                            contentEdgeInsets:contentEdgeInsets];
    
    [self insertAttachment:attachment atIndex:index toAttributedString:attributedString];
}

+ (void)insertAttachment:(YSCoreTextAttachmentImage*)attachment
                 atIndex:(NSUInteger)index
      toAttributedString:(NSMutableAttributedString *)attributedString
{
    CTRunDelegateCallbacks callbacks = attachment.callbacks;
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void *)attachment);
    NSAttributedString *attachmentStr = [[NSAttributedString alloc] initWithString:OBJECT_REPLACEMENT_CHARACTER
                                                                        attributes:@{(id)kCTRunDelegateAttributeName : (__bridge id)runDelegate,
                                                                                     kYSCoreTextAttachment : attachment}];
    CFRelease(runDelegate);
    
    if (attributedString.length <= index) {
        [attributedString appendAttributedString:attachmentStr];
    } else {
        [attributedString insertAttributedString:attachmentStr atIndex:index];
    }
}

- (id)initWithObject:(id)object size:(CGSize)size contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets
{
    self = [super init];
    if (self) {
        _object = object;
        _size = size;
        _contentEdgeInsets = contentEdgeInsets;
    }
    return self;
}

- (CGPoint)drawPoint
{
    return CGPointMake(self.contentEdgeInsets.left + _drawPoint.x,
                       self.contentEdgeInsets.top + _drawPoint.y);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{\n\
            %@, %@, size: %@\n}", [super description], self.object, NSStringFromCGSize(self.size)];
}

@end
