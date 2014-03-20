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

@interface ViewController ()

@property (weak, nonatomic) IBOutlet YSCoreTextView *textView;
@property (weak, nonatomic) IBOutlet YSCoreTextView *textView2;

@end

static NSString * const OBJECT_REPLACEMENT_CHARACTER = @"\uFFFC";

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self setupTextView];
    [self setupTextView2];
}

- (void)setupTextView
{
    UIFont *font = [UIFont systemFontOfSize:25.];
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFloat fontSize = font.pointSize;
	CTFontRef ctfont = CTFontCreateWithName(fontName, fontSize, NULL);
    
    NSString *text = @"Simple drawing of the CoreText.";
    
    YSCoreTextLayout *layout = [[YSCoreTextLayout alloc] initWithConstraintSize:CGSizeMake(self.textView.bounds.size.width, CGFLOAT_MAX)
                                attributedString:[[NSAttributedString alloc] initWithString:text
                                                                                 attributes:@{(id)kCTFontAttributeName : (__bridge id)ctfont,
                                                                                              (id)kCTForegroundColorAttributeName : (__bridge id)[UIColor blueColor].CGColor}]];
    CFRelease(ctfont);
    
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"(Simple)|(the Core)"
																		 options:0
																		   error:nil];
	NSArray *array = [reg matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    NSMutableArray *hightlight = [NSMutableArray arrayWithCapacity:[array count]];
    for (NSTextCheckingResult *result in array) {
		if ([result numberOfRanges]) {
			if ([result rangeAtIndex:1].length) {
                [hightlight addObject:[YSCoreTextHighlight highlightWithRange:result.range
                                                                        color:[[UIColor blueColor] colorWithAlphaComponent:0.4]]];
            }
            if ([result rangeAtIndex:2].length) {
                [hightlight addObject:[YSCoreTextHighlight highlightWithRange:result.range
                                                                        color:[[UIColor greenColor] colorWithAlphaComponent:0.4]]];
            }
        }
    }
    layout.hightlight = hightlight;
    
    CGRect frame = self.textView.frame;
    frame.size = layout.size;
    self.textView.frame = frame;
    self.textView.layout = layout;
}

- (void)setupTextView2
{
    NSString *str;
    str = @"Simple".mutableCopy;
//    str = @"Simple drawing of the CoreText. Simple drawing of the CoreText. Simple drawing of the CoreText. Simple drawing of the CoreText. ".mutableCopy;
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    UIFont *font = [UIFont systemFontOfSize:20.];
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFloat fontSize = font.pointSize;
	CTFontRef ctfont = CTFontCreateWithName(fontName, fontSize, NULL);
    
    [attrStr addAttribute:(id)kCTFontAttributeName value:(__bridge id)ctfont range:NSMakeRange(0, attrStr.length)];
//    [attrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attrStr.length)];
    
    NSRegularExpression *reg;
    
    UIImage *img;
//    img = [UIImage imageNamed:@"cat10x10"];
//    img = [UIImage imageNamed:@"cat40x40"];
    CGFloat imgSize = font.ascender - font.descender;
    img = [UIImage ys_imageFromColor:[UIColor purpleColor] withSize:CGSizeMake(imgSize, imgSize)];
#if 1
    #if 1
    YSCoreTextAttachmentImage *attachment = [YSCoreTextAttachmentImage insertImage:img
                                                                        withAscent:font.ascender
                                                                           descent:font.descender
                                                                           atIndex:0
                                                                toAttributedString:attrStr];
    #if 0
    attachment.contentInset = UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f);
    [attachment configureAlignmentCenter];
    UIEdgeInsets edgeInsets = attachment.contentEdgeInsets;
    edgeInsets.top = attachment.contentInset.top;
    attachment.contentEdgeInsets = edgeInsets;
    #endif

    #else
    reg = [NSRegularExpression regularExpressionWithPattern:@"[\\w]*( )[\\w]*"
																		 options:0
																		   error:nil];
    NSTextCheckingResult *result;
    do {
        result = [reg firstMatchInString:attrStr.string options:0 range:NSMakeRange(0, attrStr.length)];
        if ([result numberOfRanges] > 1) {
            NSRange range = [result rangeAtIndex:1];
            [attrStr replaceCharactersInRange:range withString:@""];
            YSCoreTextAttachmentImage *attachment = [YSCoreTextAttachmentImage insertImage:img
                                                                                withAscent:font.ascender
                                                                                   descent:font.descender
                                                                                   atIndex:range.location
                                                                        toAttributedString:attrStr];
            attachment.contentInset = UIEdgeInsetsMake(0.f, 3.f, 0.f, 3.f);
            [attachment configureAlignmentCenter];
//            attachment.contentEdgeInsets = UIEdgeInsetsMake(0.f, attachment.contentInset.left, 0.f, 0.f);
        }
    } while (result.numberOfRanges != 0);
    #endif
#endif
    YSCoreTextLayout *layout = [[YSCoreTextLayout alloc] initWithConstraintSize:self.textView2.bounds.size attributedString:attrStr];
    
#if 1
    reg = [NSRegularExpression regularExpressionWithPattern:@"(Simple drawing)"
                                                    options:0
                                                      error:nil];
	NSArray *array = [reg matchesInString:attrStr.string options:0 range:NSMakeRange(0, attrStr.length)];
    NSMutableArray *hightlight = [NSMutableArray arrayWithCapacity:[array count]];
    for (NSTextCheckingResult *result in array) {
		if ([result numberOfRanges]) {
			if ([result rangeAtIndex:1].length) {
                [hightlight addObject:[YSCoreTextHighlight highlightWithRange:result.range
                                                                        color:[[UIColor blueColor] colorWithAlphaComponent:0.4]]];
                NSLog(@"%@", [attrStr.string substringWithRange:[result rangeAtIndex:1]]);
            }
        }
    }
    layout.hightlight = hightlight;
#endif
    
    self.textView2.layout = layout;
    
    CGRect frame = self.textView2.frame;
    frame.size = layout.size;
    self.textView2.frame = frame;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
