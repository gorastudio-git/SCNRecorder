//
//  SCNRecorderOriginMulticastDelegate.m
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 30.05.2020.
//

#import "SCNRecorderOriginMulticastDelegate.h"

@implementation SCNRecorderOriginMulticastDelegate

#pragma mark - NSProxy

- (void)forwardInvocation:(NSInvocation *)invocation
{
  if ([self.origin respondsToSelector:invocation.selector]) {
     [invocation invokeWithTarget:self.origin];
  }

  [super forwardInvocation:invocation];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
  NSMethodSignature *methodSinature = [self.origin methodSignatureForSelector:selector];
  if (methodSinature) {
    return methodSinature;
  }
  return [super methodSignatureForSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)selector
{
  return [self.origin respondsToSelector:selector] || [super respondsToSelector:selector];
}

- (BOOL)conformsToProtocol:(Protocol *)protocol
{
    return [self.origin conformsToProtocol:protocol] || [super conformsToProtocol:protocol];
}

@end
