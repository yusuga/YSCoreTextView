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
        
        self.hightlight = [NSMutableArray array];
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
                CGFloat insetLeft = 0.f, insetTop = 0.f;
                if (attachment) {
                    insetLeft = attachment.contentEdgeInsets.left;
                    insetTop = attachment.contentEdgeInsets.top;
                }
                CFRange runRange = CTRunGetStringRange(run);
                width = CTRunGetTypographicBounds(run, CFRangeMake(0, runRange.length), NULL, NULL, NULL);
                CGContextSetTextPosition(context, origin.x + insetLeft, origin.y - insetTop);
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
    
    for (YSCoreTextHighlight *h in self.hightlight) {
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
    LOG_YSCORE_TEXT_CTRUN(@"range = %@", NSStringFromRange(range));
    for (NSInteger lineIdx = 0; lineIdx < lineCount; lineIdx++) {
        CGPoint origin = lineOrigins[lineIdx];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIdx);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        CFIndex runCount = CFArrayGetCount(runs);
        LOG_YSCORE_TEXT_CTRUN(@"runCount = %@", @(runCount));
        
        CGRect lineRect = CGRectZero;
        lineRect.origin.x = origin.x;
        NSUInteger nextMinimumIdx = 0;
        for (CFIndex runIdx = 0; runIdx < runCount; runIdx++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, runIdx);
            CFRange runRange = CTRunGetStringRange(run);
            if (runRange.location < nextMinimumIdx) {
                LOG_YSCORE_TEXT_CTRUN(@"continue: runRange = %@, nextMinimumIdx = %@", NSStringFromRange(NSMakeRange(runRange.location, runRange.length)), @(nextMinimumIdx));
                continue;
            }
            
            NSRange intersectionRange = NSIntersectionRange(range, NSMakeRange(runRange.location, runRange.length));
            CGFloat ascent, descent, leading;
            double width = CTRunGetTypographicBounds(run,
                                                     CFRangeMake(0, intersectionRange.length),
                                                     &ascent,
                                                     &descent,
                                                     &leading);
            LOG_YSCORE_TEXT_CTRUN(@"runRange = %@, intersectionRange = %@, ascent = %f, descent = %f, leading = %f, width = %f;", NSStringFromRange(NSMakeRange(runRange.location, runRange.length)), NSStringFromRange(intersectionRange), ascent, descent, leading, width);
            
            if (intersectionRange.length == 0) {
                if (lineRect.size.width == 0.f) {
                    lineRect.origin.x += width;
                }
            } else if (runRange.location != intersectionRange.location) {
                double width = CTRunGetTypographicBounds(run,
                                                         CFRangeMake(0, intersectionRange.location),
                                                         NULL,
                                                         NULL,
                                                         NULL);
                lineRect.origin.x += width;
            }
            
            if (intersectionRange.length > 0) {
                if (lineRect.size.width == 0.f) {
                    lineRect.origin.y = CGFloat_ceil(origin.y - descent);
                    lineRect.size.height = CGFloat_ceil(ascent + descent);
                    lineRect.origin.y = self.size.height - CGRectGetMaxY(lineRect);
                }
                lineRect.size.width += width;
                
                if (nextMinimumIdx == 0) {
                    nextMinimumIdx = runRange.location + runRange.length;
                } else {
                    nextMinimumIdx += runRange.length;
                }
            }
        }
        if (lineRect.size.width > 0.f) {
            [fragmentRects addObject:[NSValue valueWithCGRect:lineRect]];
        }
    }
	return [NSArray arrayWithArray:fragmentRects];
}

@end
