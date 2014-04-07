//
//  YSCoreTextAttachment.h
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/11.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreText;
#import "YSCoreTextAttachmentProtocol.h"

/*
 Base code from SECoreTextView (https://github.com/kishikawakatsumi/SECoreTextView>
 Copyright (c) 2013 kishikawa katsumi (http://kishikawakatsumi.com/)
 All rights reserved.
 MIT license
 */

@interface YSCoreTextAttachment : NSObject <YSCoreTextAttachmentProtocol>

@property (nonatomic, readonly) CTRunDelegateCallbacks callbacks;
- (void)configureAlignmentCenter;

@end
