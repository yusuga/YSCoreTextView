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

static inline CGFLOAT_TYPE CGFloat_floor(CGFLOAT_TYPE cgfloat) {
#if defined(__LP64__) && __LP64__
    return floor(cgfloat);
#else
    return floorf(cgfloat);
#endif
}

static inline CFIndex ys_CFLineGetRunStatus(CTLineRef line, CFIndex index) {
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CFIndex runsCount = CFArrayGetCount(runs);
    for (CFIndex idx = 0; idx < runsCount; idx++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, idx);
        CFRange range = CTRunGetStringRange(run);
        if (NSLocationInRange(index, NSMakeRange(range.location, range.length))) {
            return CTRunGetStatus(run);
        }
    }
    return kCTRunStatusNoStatus;
}

@interface YSCoreTextLayout ()

@property (nonatomic, readonly) NSMutableArray *attachments;
@property (nonatomic) CGFloat baseLine;

@end

@implementation YSCoreTextLayout

- (instancetype)initWithConstraintSize:(CGSize)constraintSize
                      attributedString:(NSAttributedString*)attributedString
                              baseFont:(UIFont*)baseFont
                            textInsets:(UIEdgeInsets)textInsets
                      isAlignmentRight:(BOOL)isAlignmentRight
                      isSizeToFitWidth:(BOOL)isSizeToFitWidth
{
    if (self = [super init]) {
        _attributedString = attributedString;
        _textInsets = textInsets;
        _isAlignmentRight = isAlignmentRight;
        
        constraintSize.width = constraintSize.width - textInsets.left - textInsets.right;
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
        _size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                             CFRangeMake(0, attributedString.length),
                                                             NULL,
                                                             constraintSize,
                                                             NULL);
        if (!isSizeToFitWidth) {
            _size.width = constraintSize.width;
        }
        
        LOG_YSCORE_TEXT(@"constraintSize: %@, CTFramesetterSuggestFrameSize: %@", NSStringFromCGSize(constraintSize), NSStringFromCGSize(_size));
        CGMutablePathRef path = CGPathCreateMutable();
        CGRect pathRect = CGRectZero;
        pathRect.size = self.size;
        CGPathAddRect(path, NULL, pathRect);
        
        _ctframe = CTFramesetterCreateFrame(framesetter,
                                            CFRangeMake(0.f, attributedString.length),
                                            path,
                                            NULL);
        SAFE_CFRELEASE(framesetter);
        SAFE_CFRELEASE(path);
        
        _size.width = CGFloat_ceil(_size.width) + textInsets.left + textInsets.right;
        _size.height += textInsets.top + textInsets.bottom;
        LOG_YSCORE_TEXT(@"size(+textInsets): %@", NSStringFromCGSize(_size));
        
        self.baseLine = CGFloat_floor(-baseFont.descender + 0.5f);
        
        // check font sizes
        /*
         NSLog(@"ascender: %f, descender: %f leading: %f, capHeight: %f, xHeight: %f, lineHeight: %f", baseFont.ascender, baseFont.descender, baseFont.leading, baseFont.capHeight, baseFont.xHeight, baseFont.lineHeight);
         NSLog(@"h1: %f, h2: %f, h3: %f, h4: %f, h5: %f",
         CGFloat_floor(baseFont.lineHeight),
         CGFloat_floor(baseFont.lineHeight + 0.5f),
         CGFloat_floor(baseFont.ascender + 0.5f) + CGFloat_floor(-baseFont.descender),
         CGFloat_floor(baseFont.ascender) + CGFloat_floor(-baseFont.descender + 0.5f),
         CGFloat_floor(baseFont.ascender + 0.5f) + CGFloat_floor(-baseFont.descender + 0.5f));
         */
        
        _highlight = [NSMutableArray array];
        _attachments = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    SAFE_CFRELEASE(_ctframe);
}

#pragma mark - Draw

- (void)drawInContext:(CGContextRef)context
{
    CFArrayRef lines = CTFrameGetLines(self.ctframe);
    CFIndex lineCount = CFArrayGetCount(lines);
    
    /* CTFrameGetLineOrigins bug: origin.y is not right at use multiple font */
    // CGPoint lineOrigins[lineCount];
    // CTFrameGetLineOrigins(self.ctframe, CFRangeMake(0, lineCount), lineOrigins);
    
    NSMutableArray *attachments = [NSMutableArray array];
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.f, self.size.height);
    CGContextScaleCTM(context, 1.f, -1.f);
    CGFloat lineHeight = [self lineHeightForLineCount:lineCount];
    CGFloat baseLine = [self calculatedBaseLine];
    CGFloat x = self.textInsets.left;
    
    LOG_YSCORE_TEXT(@"--- lineCount: %@, self.size.height: %f, textInsets: %@, lineHeight: %f, isRightToLeft: %d",
                    @(lineCount),
                    self.size.height,
                    NSStringFromUIEdgeInsets(self.textInsets),
                    lineHeight,
                    isRightToLeft);
    for (int lineIdx = 0; lineIdx < lineCount; lineIdx++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIdx);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        CFIndex runCount = CFArrayGetCount(runs);
        
        CGPoint origin = CGPointMake(x,
                                     lineHeight*((lineCount - 1) - lineIdx) + baseLine); // Workaround: CTFrameGetLineOrigins bug
        LOG_YSCORE_TEXT(@"origin: %@, self.size.height: %f", NSStringFromCGPoint(origin), self.size.height);
        CGFloat currentX = x;
        
        if (self.isAlignmentRight) {
            origin.x += self.size.width - self.textInsets.left - self.textInsets.right - CGFloat_ceil(CGRectGetWidth(CTLineGetImageBounds(line, context)));
        }
        
        for (CFIndex runIdx = 0; runIdx < runCount; runIdx++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, runIdx);
            CFDictionaryRef runAttr = CTRunGetAttributes(run);
            CTRunDelegateRef runDelegate = CFDictionaryGetValue(runAttr, kCTRunDelegateAttributeName);
            id <YSCoreTextAttachmentProtocol>attachment = (__bridge id <YSCoreTextAttachmentProtocol>)CTRunDelegateGetRefCon(runDelegate);
            double width = 0.;
            
            if ([attachment respondsToSelector:@selector(drawPoint)]) {
                CFRange runRange = CTRunGetStringRange(run);
                CGFloat ascent, descent, leading;
                width = CTRunGetTypographicBounds(run, CFRangeMake(0, runRange.length), &ascent, &descent, &leading);
                attachment.drawPoint = CGPointMake(currentX,
                                                   self.size.height - origin.y - ascent);
                [attachments addObject:attachment];
            } else {
                CGFloat adjustX = 0.f, adjustY = 0.f;
                if ([attachment respondsToSelector:@selector(contentEdgeInsets)]) {
                    UIEdgeInsets insets = attachment.contentEdgeInsets;
                    adjustX = insets.left + insets.right;
                    adjustY = insets.top + insets.bottom;
                }
                CFRange runRange = CTRunGetStringRange(run);
                width = CTRunGetTypographicBounds(run, CFRangeMake(0, runRange.length), NULL, NULL, NULL);
                //LOG_YSCORE_TEXT(@"h: %f, origin: %@, ascent: %f, descent: %f, leading: %f", self.size.height, NSStringFromCGPoint(origin), ascent, descent, leading);
                CGContextSetTextPosition(context,
                                         origin.x + adjustX,
                                         origin.y - adjustY);
                CTRunDraw(run, context, CFRangeMake(0, 0));
            }
            currentX += width;
        }
    }
    CGContextRestoreGState(context);
    LOG_YSCORE_TEXT(@"---");
    
    for (id <YSCoreTextAttachmentProtocol> attachment in attachments) {
        NSAssert1([attachment respondsToSelector:@selector(object)], @"attachment = %@", attachment);
        UIImage *img = attachment.object;
        if ([img isKindOfClass:[UIImage class]]) {
            [img drawAtPoint:attachment.drawPoint];
        }
    }
    
    for (YSCoreTextHighlight *h in self.highlight) {
        [self drawSelectedTextFragmentRectsWithRange:h.range
                                               color:h.color
                                             context:context];
    }
}

#pragma mark - Draw highlight

- (void)drawSelectedTextFragmentRectsWithRange:(NSRange)range
                                         color:(UIColor*)color
                                       context:(CGContextRef)context
{
    if (range.location == NSNotFound || range.length == 0) {
        return;
    }
    NSUInteger fromIndex = range.location;
    NSUInteger toIndex = NSMaxRange(range) - 1;
    
    NSArray *fragmentRects = [self fragmentRectsForGlyphFromIndex:fromIndex
                                                          toIndex:toIndex
                                                          context:context];
    
    LOG_YSCORE_TEXT_FRAGMENT(@"fragmentRects = %@", fragmentRects);
    
    [color set];
    for (NSValue *rectValue in fragmentRects) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:[rectValue CGRectValue] cornerRadius:2.];
        [path fill];
    }
}

- (NSArray*)fragmentRectsForGlyphFromIndex:(NSUInteger)fromIndex
                                   toIndex:(NSUInteger)toIndex
                                   context:(CGContextRef)context
{
    CFArrayRef lines = CTFrameGetLines(self.ctframe);
    CFIndex lineCount = CFArrayGetCount(lines);
    NSMutableArray *fragmentRects = [NSMutableArray array];
    NSRange range = NSMakeRange(fromIndex, toIndex - fromIndex + 1);
    CGFloat lineHeight = [self lineHeightForLineCount:lineCount];
    CGFloat baseLine = [self calculatedBaseLine];
    CGFloat x = self.textInsets.left;
    
    LOG_YSCORE_TEXT_FRAGMENT(@"range = %@", NSStringFromRange(range));
    for (NSInteger lineIdx = 0; lineIdx < lineCount; lineIdx++) {
        CGPoint origin = CGPointMake(x,
                                     lineHeight*((lineCount - 1) - lineIdx) + baseLine); // Workaround CTFrameGetLineOrigins bug
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIdx);
        CFRange lineRange = CTLineGetStringRange(line);
        NSRange intersectionRange = NSIntersectionRange(range, NSMakeRange(lineRange.location, lineRange.length));
        
        if (self.isAlignmentRight) {
            origin.x += self.size.width - self.textInsets.left - self.textInsets.right - CGRectGetWidth(CTLineGetImageBounds(line, context));
        }
        
        LOG_YSCORE_TEXT_FRAGMENT(@"lineIdx = %@, lineRange: %@, intersectionRange = %@, %@",
                                 @(lineIdx),
                                 NSStringFromRange(NSMakeRange(lineRange.location, lineRange.length)),
                                 NSStringFromRange(intersectionRange),
                                 [self.attributedString.string substringWithRange:intersectionRange]);
        
        CGRect fragRect = CGRectZero;
        if (intersectionRange.length > 0) {
            CGFloat ascent, descent, leading;
            double width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            LOG_YSCORE_TEXT_FRAGMENT(@"width: %f, ascent: %f, descent: %f, leading: %f", width, ascent, descent, leading);
            
#if 0
#warning debug log enabled
            NSLog(@"{\nline:\n'%@'\n(%@)\ntext:\n'%@'\n(%@)\n}", [self.attributedString.string substringWithRange:NSMakeRange(lineRange.location, lineRange.length)], NSStringFromRange(NSMakeRange(lineRange.location, lineRange.length)), [self.attributedString.string substringWithRange:NSMakeRange(intersectionRange.location, intersectionRange.length)], NSStringFromRange(NSMakeRange(intersectionRange.location, intersectionRange.length)));
            for (NSUInteger i = lineRange.location; i < lineRange.length; i++) {
                CGFloat secondaryOffset = 0.;
                CGFloat offset = CTLineGetOffsetForStringIndex(line, i, &secondaryOffset);
                NSLog(@"%zd: %f, %f, %@", i, offset, secondaryOffset, [self.attributedString.string substringWithRange:NSMakeRange(i, 1)]);
            }
            {
                CFArrayRef runs = CTLineGetGlyphRuns(line);
                CFIndex runsCount = CFArrayGetCount(runs);
                for (CFIndex idx = 0; idx < runsCount; idx++) {
                    CTRunRef run = CFArrayGetValueAtIndex(runs, idx);
                    CFRange range = CTRunGetStringRange(run);
                    NSLog(@"run: %@ (%@)", [self.attributedString.string substringWithRange:NSMakeRange(range.location, range.length)], NSStringFromRange(NSMakeRange(range.location, range.length)));
                }
            }
#endif
            
            CGFloat startOffset = 0.;
            CGFloat endOffset = 0.;
            
            BOOL isRightToLeft = ys_CFLineGetRunStatus(line, intersectionRange.location) & kCTRunStatusRightToLeft;
            
            CGFloat startSecondaryOffset = 0.;
            startOffset = CTLineGetOffsetForStringIndex(line, intersectionRange.location, &startSecondaryOffset);
            if (startOffset == startSecondaryOffset) {
                CFIndex intersectionEndIndex = intersectionRange.location + intersectionRange.length;
                CGFloat endSecondaryOffset = 0.;
                endOffset = CTLineGetOffsetForStringIndex(line, intersectionEndIndex, &endSecondaryOffset);
                
                if (endOffset == endSecondaryOffset) {
                    if (isRightToLeft) {
                        CGFloat swap = endOffset;
                        endOffset = startOffset;
                        startOffset = swap;
                    }
                } else {
                    if (isRightToLeft) {
                        CFIndex rightToLeftStartIndex = -1;
                        for (CFIndex idx = intersectionEndIndex - 1; idx >= lineRange.location; idx--) {
                            CGFloat secondaryOffset = 0.;
                            CGFloat offset = CTLineGetOffsetForStringIndex(line, idx, &secondaryOffset);
                            if (offset != secondaryOffset) {
                                rightToLeftStartIndex = idx;
                                break;
                            }
                        }
                        if (rightToLeftStartIndex == -1) {
                            endOffset = endSecondaryOffset;
                        } else {
                            if (rightToLeftStartIndex < intersectionRange.location) {
                                CGFloat swap = endOffset;
                                endOffset = startOffset;
                                startOffset = swap;
                            } else {
                                CFIndex startIndex = rightToLeftStartIndex + intersectionRange.length;
                                startOffset = CTLineGetOffsetForStringIndex(line, startIndex, NULL);
                                endOffset = endSecondaryOffset;
                            }
                        }
                    } else {
                        endOffset = endSecondaryOffset;
                    }
                }
            } else {
                CFIndex intersectionEndIndex = intersectionRange.location + intersectionRange.length;
                
                if (isRightToLeft) {
                    CFIndex rightToLeftEndIndex = lineRange.location + lineRange.length;
                    for (CFIndex idx = intersectionEndIndex; idx < lineRange.location + lineRange.length; idx++) {
                        CGFloat secondaryOffset = 0.;
                        CGFloat offset = CTLineGetOffsetForStringIndex(line, idx, &secondaryOffset);
                        if (offset != secondaryOffset) {
                            rightToLeftEndIndex = idx;
                            break;
                        }
                    }
                    
                    if (rightToLeftEndIndex == lineRange.location + lineRange.length) {
                        CFIndex intersectionStartIndex = intersectionRange.location + intersectionRange.length;
                        
                        startOffset = CTLineGetOffsetForStringIndex(line, intersectionStartIndex, NULL);
                        endOffset = startSecondaryOffset;
                    } else {
                        CFIndex intersectionEndIndex = rightToLeftEndIndex - intersectionRange.length;
                        
                        CGFloat endSecondaryOffset;
                        endOffset = CTLineGetOffsetForStringIndex(line, intersectionEndIndex, &endSecondaryOffset);
                        if (endOffset == endSecondaryOffset) {
                            endOffset = startSecondaryOffset;
                            startOffset = CTLineGetOffsetForStringIndex(line, intersectionRange.location + intersectionRange.length, NULL);
                        } else {
                            endOffset = endSecondaryOffset;
                        }
                    }
                } else {
                    CGFloat endSecondaryOffset;
                    endOffset = CTLineGetOffsetForStringIndex(line, intersectionEndIndex, &endSecondaryOffset);
                    if (endOffset == endSecondaryOffset) {
                        endOffset = CTLineGetOffsetForStringIndex(line, intersectionEndIndex, NULL);
                    } else {
                        endOffset = startSecondaryOffset;
                    }
                }
            }
            
            if (endOffset == 0.f) {
                endOffset = width;
            }
            
            CGFloat textWidth = endOffset - startOffset;
            LOG_YSCORE_TEXT_FRAGMENT(@"startOffset: %f, endOffset: %f, textWidth: %f", startOffset, endOffset, textWidth);
            fragRect.origin.x = origin.x + startOffset;
            fragRect.origin.y = origin.y - descent;
            fragRect.size.height = lineHeight;
            fragRect.origin.y = self.size.height - CGRectGetMaxY(fragRect);
            fragRect.size.width = textWidth;
        }
        
        if (fragRect.size.width > 0.f) {
            LOG_YSCORE_TEXT_FRAGMENT(@"Hit, lineRect: %@", NSStringFromCGRect(fragRect));
            [fragmentRects addObject:[NSValue valueWithCGRect:fragRect]];
            
            if (NSMaxRange(range) == NSMaxRange(intersectionRange)) {
                LOG_YSCORE_TEXT_FRAGMENT(@"break");
                break;
            }
        }
    }
    return [NSArray arrayWithArray:fragmentRects];
}

#pragma mark - Util

- (CGFloat)lineHeightForLineCount:(CFIndex)lineCount
{
    return (self.size.height - self.textInsets.top - self.textInsets.bottom) / lineCount;
}

- (CGFloat)calculatedBaseLine
{
    return self.baseLine + self.textInsets.bottom;
}

@end
