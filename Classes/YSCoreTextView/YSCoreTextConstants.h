//
//  YSCoreTextConstants.h
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/01.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

#if DEBUG
    #if 0
        #define LOG_YSCORE_TEXT(...) NSLog(__VA_ARGS__)
    #endif
    #if 0
        #define LOG_YSCORE_TEXT_CTLINE(...) NSLog(__VA_ARGS__)
    #endif
#endif

#ifndef LOG_YSCORE_TEXT
    #define LOG_YSCORE_TEXT(...)
#endif

#ifndef LOG_YSCORE_TEXT_CTLINE
    #define LOG_YSCORE_TEXT_CTLINE(...)
#endif

#define SAFE_CFRELEASE(p) if(p){CFRelease(p);p=NULL;}

extern NSString * const OBJECT_REPLACEMENT_CHARACTER;
extern NSString * const kYSCoreTextAttachment;

