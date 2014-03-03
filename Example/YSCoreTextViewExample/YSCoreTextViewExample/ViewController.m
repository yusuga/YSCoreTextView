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

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIFont *font = [UIFont systemFontOfSize:25.];
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFloat fontSize = font.pointSize;
	CTFontRef ctfont = CTFontCreateWithName(fontName, fontSize, NULL);
    
    NSString *text = @"Simple drawing of the CoreText.";
    
    YSCoreTextLayout *layout = [[YSCoreTextLayout alloc] initWithConstraintSize:CGSizeMake(self.textView.bounds.size.width, CGFLOAT_MAX)
                                                                           text:text
                                                                     attributes:@{(id)kCTFontAttributeName : (__bridge id)ctfont,
                                                                                  (id)kCTForegroundColorAttributeName : (__bridge id)[UIColor blueColor].CGColor}];
    CFRelease(ctfont);
    
    [layout.hightlight addObjectsFromArray:@[[YSCoreTextHighlight highlightWithRange:NSMakeRange(1, 3)
                                                                               color:[[UIColor blueColor] colorWithAlphaComponent:0.4]],
                                             [YSCoreTextHighlight highlightWithRange:NSMakeRange(19, 5) color:[[UIColor yellowColor] colorWithAlphaComponent:0.4]]]];
    
    CGRect frame = self.textView.frame;
    frame.size = layout.size;
    self.textView.frame = frame;
    NSLog(@"%@", NSStringFromCGRect(self.textView.frame));
    
    self.textView.layout = layout;
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
