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
    return attachment.contentInset.top + attachment.size.height + attachment.contentInset.bottom;
}

static CGFloat RunDelegateGetDescentCallback(void *refCon)
{
    return 0.0f;
}

static CGFloat RunDelegateGetWidthCallback(void *refCon)
{
    YSCoreTextAttachment *attachment = (__bridge YSCoreTextAttachment *)refCon;
    return attachment.contentInset.left + attachment.size.width + attachment.contentInset.right;
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

#pragma mark - YSCoreTextAttachmentProtocol required method

+ (void)insertAttachment:(id)attachment
                 atIndex:(NSUInteger)index
      toAttributedString:(NSMutableAttributedString *)attributedString
{
    abort();
}

- (CGSize)size
{
    abort();
}

- (UIEdgeInsets)contentInset
{
    abort();
}

@end
