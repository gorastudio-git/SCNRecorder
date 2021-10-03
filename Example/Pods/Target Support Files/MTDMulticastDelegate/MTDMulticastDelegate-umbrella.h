#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MTDMulticastDelegate.h"
#import "MTDOriginMulticastDelegate.h"
#import "MulticastDelegate.h"

FOUNDATION_EXPORT double MulticastDelegateVersionNumber;
FOUNDATION_EXPORT const unsigned char MulticastDelegateVersionString[];

