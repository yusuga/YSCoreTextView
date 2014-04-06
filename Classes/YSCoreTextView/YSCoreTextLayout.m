//
//  YSCoreTextLayout.m
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/01.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSCoreTextLayout.h"
#import "YSCoreTextHighlight.h"
#import "YSCoreTextConstants.h"
#import "YSCoreTextAttachmentProtocol.h"

static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if defined(__LP64__) && __LP64__
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

static CGFloat const kMinimumHightWhenAttachmentWasAdded = 15.f;

@interface YSCoreTextLayout ()

@property (nonatomic) NSMutableArray *attachments;

@end

@implementation YSCoreTextLayout

- (id)initWithConstraintSize:(CGSize)constraintSize
            attributedString:(NSAttributedString*)attributedString
{
    if (self = [super init]) {
        _attributedString = attributedString;
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
        _size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                             CFRangeMake(0, attributedString.length),
                                                             NULL,
                                                             constraintSize,
                                                             NULL);
        CGMutablePathRef path = CGPathCreateMutable();
        CGRect pathRect = CGRectZero;
        pathRect.size = self.size;
        CGPathAddRect(path, NULL, pathRect);
        _ctframe = CTFramesetterCreateFrame(framesetter,
                                            CFRangeMake(0.f, attributedString.length),
                                            path,
                                            NULL);
        SAFE_CFRELEASE(framesetter);
        
        self.highlight = [NSMutableArray array];
        self.attachments = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    SAFE_CFRELEASE(_ctframe);
}

- (void)drawInContext:(CGContextRef)context
{
    CFArrayRef lines = CTFrameGetLines(self.ctframe);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.ctframe, CFRangeMake(0, lineCount), lineOrigins);
    
    NSMutableArray *attachments = [NSMutableArray array];
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.f, self.size.height);
    CGContextScaleCTM(context, 1.f, -1.f);
    for (int lineIdx = 0; lineIdx < lineCount; lineIdx++) {
        CGPoint origin = lineOrigins[lineIdx];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIdx);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        CFIndex runCount = CFArrayGetCount(runs);
        CGFloat currentX = 0.f;
        for (CFIndex runIdx = 0; runIdx < runCount; runIdx++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, runIdx);
            CFDictionaryRef runAttr = CTRunGetAttributes(run);
            CTRunDelegateRef runDelegate = CFDictionaryGetValue(runAttr, kCTRunDelegateAttributeName);
            id <YSCoreTextAttachmentProtocol>attachment = (__bridge id <YSCoreTextAttachmentProtocol>)CTRunDelegateGetRefCon(runDelegate);
            double width;
            if ([attachment respondsToSelector:@selector(drawPoint)]) {
                CFRange runRange = CTRunGetStringRange(run);
                CGFloat ascent, descent, leading;
                width = CTRunGetTypographicBounds(run, CFRangeMake(0, runRange.length), &ascent, &descent, &leading);
                attachment.drawPoint = CGPointMake(currentX, self.size.height - origin.y - ascent);
                [attachments addObject:attachment];
            } else {
                CGFloat adjustX = 0.f, adjustY = 0.f;
                if ([attachment respondsToSelector:@selector(contentEdgeInsets)]) {
                    UIEdgeInsets insets = attachment.contentEdgeInsets;
                    adjustX = insets.left + insets.right;
                    adjustY = insets.top + insets.bottom;
                }
                NSUInteger len;
                if ([attachment respondsToSelector:@selector(custumLength)]) {
                    len = [attachment custumLength];
                } else {
                    CFRange runRange = CTRunGetStringRange(run);
                    len = runRange.length;
                }
                width = CTRunGetTypographicBounds(run, CFRangeMake(0, len), NULL, NULL, NULL);
                CGContextSetTextPosition(context, origin.x + adjustX, origin.y - adjustY);
                CTRunDraw(run, context, CFRangeMake(0, 0));
            }
            currentX += width;
        }
    }
    CGContextRestoreGState(context);

    for (id <YSCoreTextAttachmentProtocol> attachment in attachments) {
        NSAssert1([attachment respondsToSelector:@selector(object)], @"attachment = %@", attachment);
        UIImage *img = attachment.object;
        if ([img isKindOfClass:[UIImage class]]) {
            [img drawAtPoint:attachment.drawPoint];
        }
    }
    
    for (YSCoreTextHighlight *h in self.highlight) {
        [self drawSelectedTextFragmentRectsWithRange:h.range color:h.color];
    }
}

#pragma mark - Draw highlight

/*
 Base idea from UZTextView https://github.com/sonsongithub/UZTextView
 Copyright (c) 2013, sonson
 All rights reserved.
 BSD-License
*/

- (void)drawSelectedTextFragmentRectsWithRange:(NSRange)range
                                         color:(UIColor*)color
{
    if (range.location == NSNotFound || range.length == 0) {
        return;
    }
    NSUInteger fromIndex = range.location;
    NSUInteger toIndex = NSMaxRange(range) - 1;
    
    NSArray *fragmentRects = [self fragmentRectsForGlyphFromIndex:fromIndex toIndex:toIndex];
    
    LOG_YSCORE_TEXT(@"fragmentRects = %@", fragmentRects);
    
    [color set];
    for (NSValue *rectValue in fragmentRects) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:[rectValue CGRectValue] cornerRadius:2.];
        [path fill];
    }
}

- (NSArray*)fragmentRectsForGlyphFromIndex:(NSUInteger)fromIndex
                                   toIndex:(NSUInteger)toIndex
{
	CFArrayRef lines = CTFrameGetLines(self.ctframe);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.ctframe, CFRangeMake(0, 0), lineOrigins);
	
	NSMutableArray *fragmentRects = [NSMutableArray array];
	
	NSRange range = NSMakeRange(fromIndex, toIndex - fromIndex + 1);
    LOG_YSCORE_TEXT_CTLINE(@"range = %@", NSStringFromRange(range));
    for (NSInteger lineIdx = 0; lineIdx < lineCount; lineIdx++) {
        CGPoint origin = lineOrigins[lineIdx];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIdx);
        CFRange lineRange = CTLineGetStringRange(line);
        NSRange intersectionRange = NSIntersectionRange(range, NSMakeRange(lineRange.location, lineRange.length));
        
        LOG_YSCORE_TEXT_CTLINE(@"lineIdx = %@, intersectionRange = %@, %@", @(lineIdx), NSStringFromRange(intersectionRange), [self.attributedString.string substringWithRange:intersectionRange]);
        
        CGRect fragRect = CGRectZero;
        if (intersectionRange.length > 0) {
            CGFloat ascent, descent, leading;
            double  width;
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            
            CFIndex startIndex = intersectionRange.location;
            CGFloat startOffset = CTLineGetOffsetForStringIndex(line, startIndex, NULL);
            CFIndex endIndex = startIndex + intersectionRange.length;
            CGFloat endOffset = CTLineGetOffsetForStringIndex(line, endIndex, NULL);
            CGFloat textWidth = endOffset - startOffset;
            
            fragRect.origin.x = origin.x + startOffset;
            fragRect.origin.y = CGFloat_ceil(origin.y - descent);
            fragRect.size.height = CGFloat_ceil(ascent + descent);
            fragRect.origin.y = self.size.height - CGRectGetMaxY(fragRect);
            fragRect.size.width = textWidth;
        }
        
        if (fragRect.size.width > 0.f) {
            LOG_YSCORE_TEXT_CTLINE(@"Hit, lineRect: %@", NSStringFromCGRect(fragRect));
            [fragmentRects addObject:[NSValue valueWithCGRect:fragRect]];
            
            if (NSMaxRange(range) == NSMaxRange(intersectionRange)) {
                LOG_YSCORE_TEXT_CTLINE(@"break");
                break;
            }
        }
    }
	return [NSArray arrayWithArray:fragmentRects];
}

#pragma mark - 

+ (CGFloat)minimumHightWhenAttachmentWasAdded;
{
    return kMinimumHightWhenAttachmentWasAdded;
}

@end
