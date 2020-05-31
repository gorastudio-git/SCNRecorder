//
//  SCNRecorderOriginMulticastDelegate.h
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 30.05.2020.
//

#import <Foundation/Foundation.h>
#import "SCNRecorderMulticastDelegate.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(OriginMulticastDelegate)
@interface SCNRecorderOriginMulticastDelegate<__covariant Delegate> : SCNRecorderMulticastDelegate<Delegate>

@property (nonatomic, weak, nullable) Delegate origin;

@end

NS_ASSUME_NONNULL_END
