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

@implementation YSCoreTextLayout

- (id)initWithConstraintSize:(CGSize)constraintSize
                         text:(NSString*)text
                   attributes:(NSDictionary*)attributes
{
    return [self initWithConstraintSize:constraintSize
                       attributedString:[[NSAttributedString alloc] initWithString:text
                                                                        attributes:attributes]];
}

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
    }
    return self;
}

- (void)dealloc
{
    SAFE_CFRELEASE(_ctframe);
}

- (void)drawInContext:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.f, self.size.height);
    CGContextScaleCTM(context, 1.f, -1.f);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CTFrameDraw(self.ctframe, context);
    CGContextRestoreGState(context);
    
    for (YSCoreTextHighlight *h in self.hightlight) {
        [self drawSelectedTextFragmentRectsFromIndex:h.range.location
                                             toIndex:h.range.location + h.range.length - 1
                                               color:h.color];
    }
}

#pragma mark - Draw highlight

/*
 UZTextView https://github.com/sonsongithub/UZTextView
 Copyright (c) 2013, sonson
 All rights reserved.
 BSD-License
*/

- (void)drawSelectedTextFragmentRectsFromIndex:(int)fromIndex
                                       toIndex:(int)toIndex
                                         color:(UIColor*)color
{
    NSArray *fragmentRects = [self fragmentRectsForGlyphFromIndex:fromIndex toIndex:toIndex];
    
    [color set];
    for (NSValue *rectValue in fragmentRects) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:[rectValue CGRectValue] cornerRadius:2.];
        [path fill];
    }
}

- (NSArray*)fragmentRectsForGlyphFromIndex:(int)fromIndex
                                   toIndex:(int)toIndex
{
	if (!(fromIndex <= toIndex && fromIndex >=0 && toIndex >=0))
		return @[];
	
	CFArrayRef lines = CTFrameGetLines(self.ctframe);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.ctframe, CFRangeMake(0, 0), lineOrigins);
	
	NSMutableArray *fragmentRects = [NSMutableArray array];
	
	NSRange range = NSMakeRange(fromIndex, toIndex - fromIndex + 1);
	
	if (range.length <= 0)
		range.length = 1;
	
    for (NSInteger index = 0; index < lineCount; index++) {
        CGPoint origin = lineOrigins[index];
        CTLineRef line = CFArrayGetValueAtIndex(lines, index);
        
		CGRect rect = CGRectZero;
		CFRange stringRange = CTLineGetStringRange(line);
		NSRange intersectionRange = NSIntersectionRange(range, NSMakeRange(stringRange.location, stringRange.length));
		CGFloat ascent;
        CGFloat descent;
        CGFloat leading;
        CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        CGRect lineRect = CGRectMake(origin.x,
                                     ceilf(origin.y - descent),
                                     width,
                                     ceilf(ascent + descent));
        lineRect.origin.y = self.size.height - CGRectGetMaxY(lineRect);
		
		if (intersectionRange.length > 0) {
			CGFloat startOffset = CTLineGetOffsetForStringIndex(line, intersectionRange.location, NULL);
			CGFloat endOffset = CTLineGetOffsetForStringIndex(line, NSMaxRange(intersectionRange), NULL);
			
			rect = lineRect;
			rect.origin.x += startOffset;
			rect.size.width -= (rect.size.width - endOffset);
			rect.size.width = rect.size.width - startOffset;
			[fragmentRects addObject:[NSValue valueWithCGRect:rect]];
		}
    }
	return [NSArray arrayWithArray:fragmentRects];
}

@end
