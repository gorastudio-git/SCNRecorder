//
//  MTDMulticastDelegate.m
//  MulticastDelegate
//
//  Created by Vladislav Grigoryev on 30.05.2020.
//  Copyright © 2020 GORA Studio. https://gora.studio
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <MulticastDelegate/MTDMulticastDelegate.h>

@interface MTDMulticastDelegate ()

@property (nonatomic, strong) NSPointerArray *mutableDelegates;

@end

@implementation MTDMulticastDelegate

- (instancetype)init
{
  _mutableDelegates = [NSPointerArray weakObjectsPointerArray];
  return self;
}

#pragma mark - Public interface

- (NSArray *)delegates
{
  [self.mutableDelegates compact];
  return [self.mutableDelegates allObjects];
}

- (void)addDelegate:(id)delegate
{
  [self.mutableDelegates addPointer:(__bridge void * _Nullable)(delegate)];
}

- (void)removeDelegate:(id)delegate
{
  for (NSUInteger i = [self.mutableDelegates count] - 1; i >= 0; i--)
  {
    if ([self.mutableDelegates pointerAtIndex:i] == (__bridge void * _Nullable)(delegate))
    {
      [self.mutableDelegates removePointerAtIndex:i];
    }
  }
}

#pragma mark - NSProxy

- (void)forwardInvocation:(NSInvocation *)invocation
{
  for (id delegate in self.mutableDelegates) {
      if ([delegate respondsToSelector:invocation.selector]) {
          [invocation invokeWithTarget:delegate];
      }
  }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    id firstResponder = [self firstResponderToSelector:selector];
    return [firstResponder methodSignatureForSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)selector
{
    return [self firstResponderToSelector:selector];
}

- (BOOL)conformsToProtocol:(Protocol *)protocol
{
    return [self firstConformedToProtocol:protocol];
}

#pragma mark - Private

- (id)firstResponderToSelector:(SEL)selector
{
    for (id delegate in self.mutableDelegates) {
        if ([delegate respondsToSelector:selector]) {
            return delegate;
        }
    }
    return nil;
}

- (id)firstConformedToProtocol:(Protocol *)protocol
{
    for (id delegate in self.mutableDelegates) {
        if ([delegate conformsToProtocol:protocol]) {
            return delegate;
        }
    }
    return nil;
}

@end
