//
//  DNSAnswer.h
//  DNSKit
//
//  Created by Ian Spence on 2023-10-15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSAnswer : NSObject

@property (strong, nonatomic, nonnull, readonly) NSString * name;
@property (nonatomic) NSUInteger answerType;
@property (nonatomic) NSUInteger answerClass;
@property (nonatomic) NSUInteger ttlSeconds;
@property (strong, nonatomic, nonnull, readonly) NSData * data;

@end

NS_ASSUME_NONNULL_END
