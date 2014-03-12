//
//  ViewController.m
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/01.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "ViewController.h"
#import "YSCoreTextView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet YSCoreTextView *textView;
@property (weak, nonatomic) IBOutlet YSCoreTextView *textView2;

@end

static NSString * const OBJECT_REPLACEMENT_CHARACTER = @"\uFFFC";

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupTextView];
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
    NSString *str = [@"Simple drawing of the CoreText. Simple drawing of the CoreText. Simple drawing of the CoreText. Simple drawing of the CoreText. " mutableCopy];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    UIImage *img;
    img = [UIImage imageNamed:@"cat10x10"];
//    img = [UIImage imageNamed:@"cat40x40"];
    
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"[\\w]*( )[\\w]*"
																		 options:0
																		   error:nil];
    NSTextCheckingResult *result;
    do {
        result = [reg firstMatchInString:attrStr.string options:0 range:NSMakeRange(0, attrStr.length)];
        if ([result numberOfRanges] > 1) {
            NSRange range = [result rangeAtIndex:1];
            [attrStr replaceCharactersInRange:range withString:@""];
            [YSCoreTextAttachment insertImage:img
                            contentEdgeInsets:UIEdgeInsetsMake(0.f, 2.f, 0.f, 2.f)
                                      atIndex:range.location
                           toAttributedString:attrStr];
        }
    } while (result.numberOfRanges != 0);
    
    YSCoreTextLayout *layout = [[YSCoreTextLayout alloc] initWithConstraintSize:self.textView2.bounds.size attributedString:attrStr];
    
    self.textView2.layout = layout;
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
