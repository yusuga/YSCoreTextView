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
#import <YSImageFilter/YSImageFilter.h>

static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if defined(__LP64__) && __LP64__
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

static inline CGFLOAT_TYPE CGFloat_round(CGFLOAT_TYPE cgfloat) {
#if defined(__LP64__) && __LP64__
    return round(cgfloat);
#else
    return roundf(cgfloat);
#endif
}

@interface Attachment : YSCoreTextAttachmentImage
@property (nonatomic) NSUInteger insertionIndex;
@end

@implementation Attachment
@end

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) UISwitch *langSwitch;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 0.f)];
    [slider sizeToFit];
    slider.minimumValue = 1.f;
    slider.maximumValue = 50.f;
    slider.value = 13.f;
    [slider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
    self.fontSize = slider.value;
    
    UISwitch *langSwitch = [[UISwitch alloc] init];
    [langSwitch addTarget:self action:@selector(langSwtichDidChange:) forControlEvents:UIControlEventValueChanged];
    self.langSwitch = langSwitch;
    
    self.toolbarItems = @[[[UIBarButtonItem alloc] initWithCustomView:slider],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          [[UIBarButtonItem alloc] initWithCustomView:langSwitch]];
    
    [self updateTextViews];
}

- (void)sliderDidChange:(UISlider*)slider
{
    CGFloat newValue = CGFloat_round(slider.value);
    slider.value = newValue;
    NSLog(@"fontSize: %f", slider.value);
    self.fontSize = slider.value;
    [self updateTextViews];
}

- (void)langSwtichDidChange:(UISwitch*)sender
{
    [self updateTextViews];
}

- (void)updateTextViews
{
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    self.y = 20.f;
    
    NSString *singleLine, *multiLine, *emojiSingleLine, *emojiMultiLine;
    if (self.langSwitch.on) {
        singleLine = @"one ライン string";
        multiLine = @"multi line stりいんg. multi ライン string. まるちらいんすとりんぐ. multi lineline string. multi line stringstring. 複数のラインテキスト。 multi multi multi line string. multi multi multi line string...string.";
        emojiSingleLine = @"one☔️ライン stir☔️ng";
        emojiMultiLine = @"multi line☔️stりいんg. multi☔️ライン string. まるちらいんすと☔️りんぐ. multi lineline string. multi line☔️stringstring. 複数☔️ラインテキスト。 multi multi mul☔️ti line string. multi multi mult☔️i line string...string.";
    } else {
        singleLine =  @"one line string";
        multiLine = @"multi line string. multi line string. multimulti line string. multi lineline string. multi line stringstring. multi multi multi line string. multi multi multi line string...string.";
        emojiSingleLine = @"one☔️line stir☔️ng";
        emojiMultiLine = @"multi☔️line string. multi l☔️ine string. multimulti line strin☔️g. multi lineline ☔️ string. multi line stringstring. multi mul☔️ti multi line string. m☔️ulti multi multi line string..☔️.string.";
    }
    
    [self addTextViewWithText:singleLine fontSize:self.fontSize regularExpressionPattern:@"(one)" attachments:nil];
    [self addTextViewWithText:singleLine fontSize:self.fontSize regularExpressionPattern:@"(line)" attachments:nil];
    [self addTextViewWithText:singleLine fontSize:self.fontSize regularExpressionPattern:@"(hli)" attachments:nil];
    
    [self addTextViewWithText:multiLine fontSize:self.fontSize regularExpressionPattern:@"(line high)" attachments:nil];
    
    [self addTextViewWithText:singleLine
                     fontSize:self.fontSize
     regularExpressionPattern:@"(one)"
                  attachments:@[[self attachmentWithFontSize:self.fontSize insertionIndex:0]]];
    
    [self addTextViewWithText:singleLine
                     fontSize:self.fontSize
     regularExpressionPattern:@"(one)"
                  attachments:@[[self attachmentWithFontSize:self.fontSize insertionIndex:5]]];
    
    [self addTextViewWithText:singleLine
                     fontSize:self.fontSize
     regularExpressionPattern:@"(line)" attachments:@[[self attachmentWithFontSize:self.fontSize insertionIndex:2],
                                                      [self attachmentWithFontSize:self.fontSize insertionIndex:12]]];
    
    [self addTextViewWithText:multiLine
                     fontSize:self.fontSize
     regularExpressionPattern:@"(multi)"
                  attachments:@[[self attachmentWithFontSize:self.fontSize insertionIndex:1],
                                [self attachmentWithFontSize:self.fontSize insertionIndex:1],
                                [self attachmentWithFontSize:self.fontSize insertionIndex:10],
                                [self attachmentWithFontSize:self.fontSize insertionIndex:24],
                                [self attachmentWithFontSize:self.fontSize insertionIndex:29],
                                [self attachmentWithFontSize:self.fontSize insertionIndex:40],
                                [self attachmentWithFontSize:self.fontSize insertionIndex:56],
                                [self attachmentWithFontSize:self.fontSize insertionIndex:71],
                                [self attachmentWithFontSize:self.fontSize insertionIndex:94],
                                [self attachmentWithFontSize:self.fontSize insertionIndex:111]]];
    
    [self addTextViewWithText:emojiSingleLine fontSize:self.fontSize regularExpressionPattern:@"(line)" attachments:nil];
    [self addTextViewWithText:emojiMultiLine fontSize:self.fontSize regularExpressionPattern:@"(multi)" attachments:nil];
    
    [self addMultiFontTextView:YES];
    [self addMultiFontTextView:NO]; // have to use the textContainerInset of YSCoreTextLayout
    
    CGRect frame = self.contentView.frame;
    frame.size.height = self.y;
    self.contentView.frame = frame;
    
    self.scrollView.contentSize = self.contentView.bounds.size;
}

- (Attachment*)attachmentWithFontSize:(CGFloat)fontSize insertionIndex:(NSUInteger)insertionIndex
{
    UIFont *font = [self fontWithSize:fontSize];
    CGFloat imgSize = font.ascender - font.descender;
    UIImage *img = [UIImage ys_imageFromColor:[UIColor redColor] withSize:CGSizeMake(imgSize, imgSize)];
    img = [YSImageFilter resizeWithImage:img size:img.size quality:kCGInterpolationHigh trimToFit:NO mask:YSImageFilterMaskCircle];
    CTParagraphStyleRef style = [self CTParagraphStyleCreateWithFont:font];
    Attachment *attachment = [[Attachment alloc] initWithImage:img font:font paragraphStyle:style];
    if (style) {
        CFRelease(style);
    }
    attachment.insertionIndex = insertionIndex;
    return attachment;
}

- (UIFont*)fontWithSize:(CGFloat)size
{
//    return [UIFont fontWithName:@"AcademyEngravedLetPlain" size:size];
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

- (CTParagraphStyleRef)CTParagraphStyleCreateWithFont:(UIFont*)font
{
    CGFloat lineHeight = CGFloat_ceil(font.lineHeight);
    CTParagraphStyleSetting setting[] = {
        { kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(lineHeight), &lineHeight }
    };
    return CTParagraphStyleCreate(setting, sizeof(setting) / sizeof(CTParagraphStyleSetting));
}

- (void)addTextViewWithText:(NSString*)text
                   fontSize:(CGFloat)fontSize
   regularExpressionPattern:(NSString*)pattern
                attachments:(NSArray*)attachments
{
    [self addTextViewWithText:text
                         font:[self fontWithSize:fontSize]
     regularExpressionPattern:pattern
                  attachments:attachments];
}

- (void)addTextViewWithText:(NSString*)text
                       font:(UIFont*)font
   regularExpressionPattern:(NSString*)pattern
                attachments:(NSArray*)attachments
{
    CGFloat x = 10.f;
    
    YSCoreTextView *textView = [[YSCoreTextView alloc] init];
    textView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:textView];
    
    CTParagraphStyleRef style = [self CTParagraphStyleCreateWithFont:font];
    
    NSMutableAttributedString *str = [[NSAttributedString alloc] initWithString:text
                                                                     attributes:@{NSFontAttributeName : font,
                                                                                  (id)kCTParagraphStyleAttributeName : (__bridge id)style}].mutableCopy;
    
    if (style) {
        CFRelease(style);
    }
    
    for (Attachment *attachment in attachments) {
        [[attachment class] insertAttachment:attachment
                                     atIndex:attachment.insertionIndex
                          toAttributedString:str];
    }
    
    CGSize constraintSize = CGSizeMake(self.view.bounds.size.width - x*2.f,
                                       CGFLOAT_MAX);
    
    YSCoreTextLayout *layout = [[YSCoreTextLayout alloc] initWithConstraintSize:constraintSize
                                                               attributedString:str
                                                                       baseFont:font];
    
    [self addHighlightWithRegularExpressionPattern:pattern colors:[self highlightColors] toLayout:layout];
    
    textView.layout = layout;
    [textView sizeToFit];
    
    CGRect frame = textView.frame;
    frame.origin.x = x;
    frame.origin.y = self.y;
    textView.frame = frame;
    
    self.y = CGRectGetMaxY(textView.frame) + 10.f;
}

- (void)addMultiFontTextView:(BOOL)systemFontAtFirst
{
    CGFloat x = 10.f;
    
    YSCoreTextView *textView = [[YSCoreTextView alloc] init];
    textView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:textView];
    
    UIFont *font, *subFont;
    if (systemFontAtFirst) {
        font = [UIFont systemFontOfSize:self.fontSize];
        subFont = [UIFont fontWithName:@"AcademyEngravedLetPlain" size:self.fontSize];
    } else {
        font = [UIFont fontWithName:@"AcademyEngravedLetPlain" size:self.fontSize];
        subFont = [UIFont systemFontOfSize:self.fontSize];
    }
    
    CTFontRef ctFont, ctSubFont;
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    ctFont = CTFontCreateWithName(fontName, self.fontSize, NULL);
    
    CFStringRef subFontName = (__bridge CFStringRef)subFont.fontName;
    ctSubFont = CTFontCreateWithName(subFontName, self.fontSize, NULL);
    
    CTParagraphStyleRef style = [self CTParagraphStyleCreateWithFont:font];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"GgGgあ"];
    [str addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)style range:NSMakeRange(0, str.length)];
    [str addAttribute:(id)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 2)];
    [str addAttribute:(id)kCTFontAttributeName value:(__bridge id)ctSubFont range:NSMakeRange(2, 2)];
    [str addAttribute:(id)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(4, 1)];
    
    CFRelease(ctFont);
    CFRelease(ctSubFont);
    CFRelease(style);
    
    CGSize constraintSize = CGSizeMake(self.view.bounds.size.width - x*2.f,
                                       CGFLOAT_MAX);
    
    YSCoreTextLayout *layout = [[YSCoreTextLayout alloc] initWithConstraintSize:constraintSize
                                                               attributedString:str
                                                                       baseFont:font];
    
    textView.layout = layout;
    [textView sizeToFit];
    
    CGRect frame = textView.frame;
    frame.origin.x = x;
    frame.origin.y = self.y;
    textView.frame = frame;
    
    self.y = CGRectGetMaxY(textView.frame) + 10.f;
}

@end
