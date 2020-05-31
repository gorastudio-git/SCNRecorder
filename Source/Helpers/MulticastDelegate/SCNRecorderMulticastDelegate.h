//
//  SCNRecorderMulticastDelegate.h
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 30.05.2020.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(MulticastDelegate)
@interface SCNRecorderMulticastDelegate<__covariant Delegate> : NSProxy

@property (nonatomic, strong, readonly) NSArray<Delegate> *delegates;

- (instancetype)init;

- (void)addDelegate:(Delegate)delegate;

- (void)removeDelegate:(Delegate)delegate;

@end

NS_ASSUME_NONNULL_END
