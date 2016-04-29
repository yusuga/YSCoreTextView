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
#import <YSImageFilter/UIImage+YSImageFilter.h>

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
@property (nonatomic) UIEdgeInsets textInsets;
@property (nonatomic) UISwitch *langSwitch;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textInsets = UIEdgeInsetsZero;
#if 1
    self.textInsets = UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
#endif
    
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
    
#if 1
    [self addTextViewWithText:singleLine fontSize:self.fontSize regularExpressionPattern:@"(one)" attachments:nil];
    [self addTextViewWithText:singleLine fontSize:self.fontSize regularExpressionPattern:@"(line)" attachments:nil];
    [self addTextViewWithText:singleLine fontSize:self.fontSize regularExpressionPattern:@"(line string)" attachments:nil];
    
    [self addTextViewWithText:multiLine fontSize:self.fontSize regularExpressionPattern:@"(line string)" attachments:nil];
    
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
    
    [self addTextViewWithText:emojiMultiLine
                         font:[self fontWithSize:self.fontSize]
     regularExpressionPattern:@"(multi)"
                  attachments:nil
                   textInsets:UIEdgeInsetsMake(50., 50., 50., 50.)];
    
    
    [self addMultiFontTextView:YES];
    [self addMultiFontTextView:NO]; // have to use the textContainerInset of YSCoreTextLayout
#endif
    
    
    for (NSUInteger i = 0; i < 2; i++) {
        BOOL isAlignmentRight = i != 0;
#if 1
        // Arabic only
#if 1
        [self addTextViewWithText:@"ما فائدته ؟"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(فائدته)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
        [self addTextViewWithText:@"ما فائدته ؟ ما فائدته ؟"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(فائدته)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
        [self addTextViewWithText:@"ما فائدته ؟"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(ما فائدته ؟)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
        [self addTextViewWithText:@"ما فائدته ؟ ما فائدته ؟"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(ما فائدته ؟)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
#endif
        
        // Arabic + Alphabet
#if 1
        [self addTextViewWithText:@"ما فائدته ؟ lorem"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(lorem)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
        [self addTextViewWithText:@"ما فائدته ؟ lorem"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(فائدته)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
        [self addTextViewWithText:@"ما فائدته ؟ lorem"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(ما فائدته ؟)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
#endif
        
        // Alphabet + Arabic
#if 1
        [self addTextViewWithText:@"lorem ما فائدته ؟"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(lorem)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
        [self addTextViewWithText:@"lorem ما فائدته ؟"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(فائدته)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
        [self addTextViewWithText:@"lorem ما فائدته ؟"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(ما فائدته ؟)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
#endif
        
        // Arabic*3
#if 1
        {
            YSCoreTextLayout *layout = [self addTextViewWithText:@"إيبسوم لأنها تعطي"
                                                        fontSize:self.fontSize
                                        regularExpressionPattern:nil
                                                     attachments:nil
                                                isAlignmentRight:isAlignmentRight];
            [self addHighlightWithRegularExpressionPattern:@"(تعطي)" colors:[self highlightColors] toLayout:layout];
            [self addHighlightWithRegularExpressionPattern:@"(لأنها)" colors:[self highlightColors] toLayout:layout];
            [self addHighlightWithRegularExpressionPattern:@"(إيبسوم)" colors:[self highlightColors] toLayout:layout];
        }
        
        {
            YSCoreTextLayout *layout = [self addTextViewWithText:@"إيبسوم لأنها تعطي a"
                                                        fontSize:self.fontSize
                                        regularExpressionPattern:nil
                                                     attachments:nil
                                                isAlignmentRight:isAlignmentRight];
            [self addHighlightWithRegularExpressionPattern:@"(تعطي)" colors:[self highlightColors] toLayout:layout];
            [self addHighlightWithRegularExpressionPattern:@"(لأنها)" colors:[self highlightColors] toLayout:layout];
            [self addHighlightWithRegularExpressionPattern:@"(إيبسوم)" colors:[self highlightColors] toLayout:layout];
        }
        {
            YSCoreTextLayout *layout = [self addTextViewWithText:@"a إيبسوم لأنها تعطي"
                                                        fontSize:self.fontSize
                                        regularExpressionPattern:nil
                                                     attachments:nil
                                                isAlignmentRight:isAlignmentRight];
            [self addHighlightWithRegularExpressionPattern:@"(تعطي)" colors:[self highlightColors] toLayout:layout];
            [self addHighlightWithRegularExpressionPattern:@"(لأنها)" colors:[self highlightColors] toLayout:layout];
            [self addHighlightWithRegularExpressionPattern:@"(إيبسوم)" colors:[self highlightColors] toLayout:layout];
        }
        {
            YSCoreTextLayout *layout = [self addTextViewWithText:@"a إيبسوم لأنها تعطي a"
                                                        fontSize:self.fontSize
                                        regularExpressionPattern:nil
                                                     attachments:nil
                                                isAlignmentRight:isAlignmentRight];
            [self addHighlightWithRegularExpressionPattern:@"(تعطي)" colors:[self highlightColors] toLayout:layout];
            [self addHighlightWithRegularExpressionPattern:@"(لأنها)" colors:[self highlightColors] toLayout:layout];
            [self addHighlightWithRegularExpressionPattern:@"(إيبسوم)" colors:[self highlightColors] toLayout:layout];
        }
#endif
        
        // Alphabet + Arabic + Alphabet
#if 1
        [self addTextViewWithText:@"ما lorem فائدته ؟"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(lorem)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
#endif
        
        // Arabic + Alphabet + Arabic
#if 1
        [self addTextViewWithText:@"lo ما فائدته ؟ rem"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(ما فائدته ؟)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
#endif
        
        // Alphabet*2 + Arabic*2 + Alphabet*2
#if 1
        [self addTextViewWithText:@"lorem lorem ما فائدته ؟ ما فائدته ؟ lorem lorem"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(lorem)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
        [self addTextViewWithText:@"lorem lorem ما فائدته ؟ ما فائدته ؟ lorem lorem"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(فائدته)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
        [self addTextViewWithText:@"lorem lorem ما فائدته ؟ ما فائدته ؟ lorem lorem"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(ما فائدته ؟)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
#endif
        
        // Arabic*2 + Alphabet*2 + Arabic*2
#if 1
        [self addTextViewWithText:@"ما فائدته ؟ ما فائدته ؟ lorem lorem ما فائدته ؟ ما فائدته ؟"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(lorem)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
        [self addTextViewWithText:@"ما فائدته ؟ ما فائدته ؟ lorem lorem ما فائدته ؟ ما فائدته ؟"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(فائدته)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
        [self addTextViewWithText:@"ما فائدته ؟ ما فائدته ؟ lorem lorem ما فائدته ؟ ما فائدته ؟"
                         fontSize:self.fontSize
         regularExpressionPattern:@"(ما فائدته ؟)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
#endif
        
        // Long arabic + Alphabet
#if 1
        [self addTextViewWithText:@"هناك حقيقة مثبتة منذ زمن طويل وهي أن المحتوى المقروء لصفحة ما سيلهي القارئ عن التركيز على الشكل الخارجي للنص أو شكل توضع الفقرات في الصفحة التي يقرأها. ولذلك يتم استخدام طريقة لوريم إيبسوم لأنها تعطي توزيعاَ طبيعياَ -إلى حد ما- للأحرف عوضاً عن استخدام \"هنا يوجد محتوى نصي، هنا يوجد محتوى نصي\" فتجعلها تبدو (أي الأحرف) وكأنها نص مقروء. العديد من برامح النشر المكتبي وبرامح تحرير صفحات الويب تستخدم لوريم إيبسوم بشكل إفتراضي كنموذج عن النص، وإذا قمت بإدخال \"lorem ipsum\" في أي محرك بحث ستظهر العديد من المواقع الحديثة العهد في نتائج البحث. على مدى السنين ظهرت نسخ جديدة ومختلفة من نص لوريم إيبسوم، أحياناً عن طريق الصدفة، وأحياناً عن عمد كإدخال بعض العبارات الفكاهية إليها."
                         fontSize:self.fontSize
         regularExpressionPattern:@"(lorem ipsum)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
#endif
        
        // Long Alphabet + Arabic
#if 1
        [self addTextViewWithText:@"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, ما فائدته ؟ when an unknown printer took a galley of type and scrambled it to make a type specimen book."
                         fontSize:self.fontSize
         regularExpressionPattern:@"(ما فائدته ؟)"
                      attachments:nil
                 isAlignmentRight:isAlignmentRight];
#endif
        
#endif
    }
    
    CGRect frame = self.contentView.frame;
    frame.size.height = self.y;
    self.contentView.frame = frame;
    
    self.scrollView.contentSize = self.contentView.bounds.size;
}

- (Attachment*)attachmentWithFontSize:(CGFloat)fontSize insertionIndex:(NSUInteger)insertionIndex
{
    UIFont *font = [self fontWithSize:fontSize];
    CGFloat imgSize = [YSCoreTextAttachmentImage imageSizeFromFont:font];
    UIImage *img = [UIImage ys_imageFromColor:[UIColor redColor] withSize:CGSizeMake(imgSize, imgSize)];
    
    YSImageFilter *filter = [[YSImageFilter alloc] init];
    filter.size = img.size;
    filter.quality = kCGInterpolationHigh;
    filter.trimToFit = NO;
    filter.mask = YSImageFilterMaskCircle;
    img = [img ys_filter:filter];
    
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
    
    [layout.highlight addObjectsFromArray:highlight];
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

- (YSCoreTextLayout *)addTextViewWithText:(NSString*)text
                                 fontSize:(CGFloat)fontSize
                 regularExpressionPattern:(NSString*)pattern
                              attachments:(NSArray*)attachments
{
    return [self addTextViewWithText:text
                                font:[self fontWithSize:fontSize]
            regularExpressionPattern:pattern
                         attachments:attachments];
}

- (YSCoreTextLayout *)addTextViewWithText:(NSString*)text
                                 fontSize:(CGFloat)fontSize
                 regularExpressionPattern:(NSString*)pattern
                              attachments:(NSArray*)attachments
                         isAlignmentRight:(BOOL)isAlignmentRight
{
    return [self addTextViewWithText:text
                                font:[self fontWithSize:fontSize]
            regularExpressionPattern:pattern
                         attachments:attachments
                          textInsets:self.textInsets
                    isAlignmentRight:isAlignmentRight];
}

- (YSCoreTextLayout *)addTextViewWithText:(NSString*)text
                                     font:(UIFont*)font
                 regularExpressionPattern:(NSString*)pattern
                              attachments:(NSArray*)attachments
{
    return [self addTextViewWithText:text
                                font:font
            regularExpressionPattern:pattern
                         attachments:attachments
                          textInsets:self.textInsets];
}

- (YSCoreTextLayout *)addTextViewWithText:(NSString*)text
                                     font:(UIFont*)font
                 regularExpressionPattern:(NSString*)pattern
                              attachments:(NSArray*)attachments
                               textInsets:(UIEdgeInsets)textInsets
{
    return [self addTextViewWithText:text
                                font:font
            regularExpressionPattern:pattern
                         attachments:attachments
                          textInsets:textInsets
                    isAlignmentRight:NO];
}

- (YSCoreTextLayout *)addTextViewWithText:(NSString*)text
                                     font:(UIFont*)font
                 regularExpressionPattern:(NSString*)pattern
                              attachments:(NSArray*)attachments
                               textInsets:(UIEdgeInsets)textInsets
                         isAlignmentRight:(BOOL)isAlignmentRight
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
                                                                       baseFont:font
                                                                     textInsets:textInsets
                                                               isAlignmentRight:isAlignmentRight
                                                               isSizeToFitWidth:NO];
    
    [self addHighlightWithRegularExpressionPattern:pattern colors:[self highlightColors] toLayout:layout];
    
    textView.layout = layout;
    [textView sizeToFit];
    
    CGRect frame = textView.frame;
    frame.origin.x = x;
    frame.origin.y = self.y;
    textView.frame = frame;
    
    self.y = CGRectGetMaxY(textView.frame) + 10.f;
    
    return layout;
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
                                                                       baseFont:font
                                                                     textInsets:self.textInsets
                                                               isAlignmentRight:NO
                                                               isSizeToFitWidth:NO];
    
    textView.layout = layout;
    [textView sizeToFit];
    
    CGRect frame = textView.frame;
    frame.origin.x = x;
    frame.origin.y = self.y;
    textView.frame = frame;
    
    self.y = CGRectGetMaxY(textView.frame) + 10.f;
}

@end
