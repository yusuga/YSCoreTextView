//
//  YSCoreTextAttachment.m
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/11.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "YSCoreTextAttachment.h"
#import "YSCoreTextConstants.h"

static void RunDelegateDeallocateCallback(void *refCon)
{
    
}

static CGFloat RunDelegateGetAscentCallback(void *refCon)
{
    YSCoreTextAttachment *attachment = (__bridge YSCoreTextAttachment *)refCon;
    return attachment.ascent;
//    return attachment.contentInset.top + attachment.size.height + attachment.contentInset.bottom;
}

static CGFloat RunDelegateGetDescentCallback(void *refCon)
{
    YSCoreTextAttachment *attachment = (__bridge YSCoreTextAttachment *)refCon;
    return attachment.descent;
}

static CGFloat RunDelegateGetWidthCallback(void *refCon)
{
    YSCoreTextAttachment *attachment = (__bridge YSCoreTextAttachment *)refCon;
    return attachment.width;
//    return attachment.contentInset.left + attachment.size.width + attachment.contentInset.right;
}

@implementation YSCoreTextAttachment

- (CTRunDelegateCallbacks)callbacks
{
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateCurrentVersion;
    callbacks.dealloc = RunDelegateDeallocateCallback;
    callbacks.getAscent = RunDelegateGetAscentCallback;
    callbacks.getDescent = RunDelegateGetDescentCallback;
    callbacks.getWidth = RunDelegateGetWidthCallback;
    
    return callbacks;
}

- (void)configureAlignmentCenter
{
    if (![self respondsToSelector:@selector(contentEdgeInsets)] ||
        ![self respondsToSelector:@selector(setContentEdgeInsets:)] ||
        UIEdgeInsetsEqualToEdgeInsets(self.contentInset, UIEdgeInsetsZero))
    {
        NSLog(@"%s; not working", __func__);
        return;
    }
    // Simple centering
    if (self.contentInset.left != self.contentInset.right) {
        NSLog(@"contentInset.left and contentInset.right is not equal");
        return;
    }
    UIEdgeInsets edgeInsets = self.contentEdgeInsets;
    edgeInsets.left = self.contentInset.left;
    [self setContentEdgeInsets:edgeInsets];
}

#pragma mark - YSCoreTextAttachmentProtocol required method

+ (void)insertAttachment:(id)attachment
                 atIndex:(NSUInteger)index
      toAttributedString:(NSMutableAttributedString *)attributedString
{
    abort();
}

- (CGFloat)ascent
{
    abort();
}

- (CGFloat)descent
{
    abort();
}

- (CGFloat)width
{
    abort();
}

- (UIEdgeInsets)contentInset
{
    return UIEdgeInsetsZero;
}

@end
