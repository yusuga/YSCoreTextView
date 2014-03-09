//
//  YSCoreTextConstants.h
//  YSCoreTextViewExample
//
//  Created by Yu Sugawara on 2014/03/01.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SAFE_CFRELEASE(p) if(p){CFRelease(p);p=NULL;}

#if DEBUG
    #if 1
        #define LOG_CORE_TEXT(...) NSLog(__VA_ARGS__)
    #endif
#endif

#ifndef LOG_CORE_TEXT
    #define LOG_CORE_TEXT(...)
#endif