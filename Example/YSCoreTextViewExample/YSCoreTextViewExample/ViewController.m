//
//  ViewController.m
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/01.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "ViewController.h"
#import "YSCoreTextView.h"

#import <YSUIKitAdditions/UIImage+YSUIKitAdditions.h>

@interface Attachment : YSCoreTextAttachmentImage
@property (nonatomic) NSUInteger insertionIndex;
@end

@implementation Attachment
@end

@interface ViewController ()

@property (nonatomic) CGFloat y;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.y = 20.f;
    CGFloat fontSize = 13.f;
    
    NSString *oneLine = @"one line highlight";
    NSString *multiLine = @"multi line highlight. multi line highlight. multi line highlight. multi line highlight. multi line highlight. multi line highlight.";
    
    [self addTextViewWithText:oneLine fontSize:fontSize regularExpressionPattern:@"(one)" attachments:nil];
    [self addTextViewWithText:oneLine fontSize:fontSize regularExpressionPattern:@"(line)" attachments:nil];
    [self addTextViewWithText:oneLine fontSize:fontSize regularExpressionPattern:@"(hli)" attachments:nil];
    
    [self addTextViewWithText:multiLine fontSize:fontSize regularExpressionPattern:@"(line high)" attachments:nil];
    
    [self addTextViewWithText:oneLine
                     fontSize:fontSize
     regularExpressionPattern:@"(one)"
                  attachments:@[[self attachmentWithFontSize:fontSize insertionIndex:0]]];
    
    [self addTextViewWithText:oneLine
                     fontSize:fontSize
     regularExpressionPattern:@"(one)"
                  attachments:@[[self attachmentWithFontSize:fontSize insertionIndex:5]]];
    
    [self addTextViewWithText:oneLine
                     fontSize:fontSize
     regularExpressionPattern:@"(line)" attachments:@[[self attachmentWithFontSize:fontSize insertionIndex:2],
                                                     [self attachmentWithFontSize:fontSize insertionIndex:12]]];
    
    [self addTextViewWithText:multiLine
                     fontSize:fontSize
     regularExpressionPattern:@"(multi)"
                  attachments:@[[self attachmentWithFontSize:fontSize insertionIndex:1],
                                [self attachmentWithFontSize:fontSize insertionIndex:1],
                                [self attachmentWithFontSize:fontSize insertionIndex:10],
                                [self attachmentWithFontSize:fontSize insertionIndex:24],
                                [self attachmentWithFontSize:fontSize insertionIndex:29],
                                [self attachmentWithFontSize:fontSize insertionIndex:40],
                                [self attachmentWithFontSize:fontSize insertionIndex:56],
                                [self attachmentWithFontSize:fontSize insertionIndex:71],
                                [self attachmentWithFontSize:fontSize insertionIndex:94],
                                [self attachmentWithFontSize:fontSize insertionIndex:111]]];
}

- (Attachment*)attachmentWithFontSize:(CGFloat)fontSize insertionIndex:(NSUInteger)insertionIndex
{
    UIFont *font = [self fontWithSize:fontSize];
    CGFloat imgSize = font.ascender - font.descender;
    UIImage *img = [UIImage ys_imageFromColor:[UIColor redColor] withSize:CGSizeMake(imgSize, imgSize)];
    Attachment *attachment = [[Attachment alloc] initWithImage:img font:font];
    attachment.insertionIndex = insertionIndex;
    return attachment;
}

- (UIFont*)fontWithSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size];
}

- (void)addHighlightWithRegularExpressionPattern:(NSString*)pattern colors:(NSArray*)colors toLayout:(YSCoreTextLayout*)layout
{
    if (pattern == nil) return;
    
    NSString *text = layout.attributedString.string;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern
																		 options:0
																		   error:nil];
	NSArray *array = [reg matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    NSMutableArray *highlight = [NSMutableArray arrayWithCapacity:[array count]];
    for (NSTextCheckingResult *result in array) {
        for (int i = 1; i < [result numberOfRanges]; i++) {
            NSLog(@"i = %@, %@", @(i), @([result numberOfRanges]));
            if ([result numberOfRanges] > 1 && [result rangeAtIndex:i].location != NSNotFound) {
                [highlight addObject:[YSCoreTextHighlight highlightWithRange:result.range
                                                                       color:colors[i - 1]]];
            }
        }
    }
    layout.highlight = highlight;
}

- (NSArray*)highlightColors
{
    return @[[[UIColor blueColor] colorWithAlphaComponent:0.4f],
             [[UIColor greenColor] colorWithAlphaComponent:0.4f],
             [[UIColor redColor] colorWithAlphaComponent:0.4f]];
}

- (void)addTextViewWithText:(NSString*)text
                   fontSize:(CGFloat)fontSize
   regularExpressionPattern:(NSString*)pattern
                attachments:(NSArray*)attachments
{
    CGFloat x = 10.f;
    
    YSCoreTextView *textView = [[YSCoreTextView alloc] init];
    textView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textView];
    
    UIFont *font = [self fontWithSize:fontSize];
    
    NSMutableAttributedString *str = [[NSAttributedString alloc] initWithString:text
                                                                     attributes:@{NSFontAttributeName : font}].mutableCopy;
    
    for (Attachment *attachment in attachments) {
        [[attachment class] insertAttachment:attachment
                                     atIndex:attachment.insertionIndex
                          toAttributedString:str];
    }
    
    YSCoreTextLayout *layout = [[YSCoreTextLayout alloc] initWithConstraintSize:CGSizeMake(self.view.bounds.size.width - x*2.f,
                                                                                           CGFLOAT_MAX)
                                                               attributedString:str];
    
    [self addHighlightWithRegularExpressionPattern:pattern colors:[self highlightColors] toLayout:layout];
    
    textView.layout = layout;
    [textView sizeToFit];
    
    CGRect frame = textView.frame;
    frame.origin.x = x;
    frame.origin.y = self.y;
    textView.frame = frame;
    
    self.y = CGRectGetMaxY(textView.frame) + 10.f;
}

@end
