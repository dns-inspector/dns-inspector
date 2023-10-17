//
//  DNSMessage.h
//  DNSKit
//
//  Created by Ian Spence on 2023-10-15.
//

#import <Foundation/Foundation.h>
#import <DNSKit/DNSQuestion.h>
#import <DNSKit/DNSAnswer.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSMessage : NSObject

@property (strong, nonatomic, nullable, readonly) NSArray<DNSQuestion *> * questions;
@property (strong, nonatomic, nullable, readonly) NSArray<DNSAnswer *> * answers;

@end

NS_ASSUME_NONNULL_END
