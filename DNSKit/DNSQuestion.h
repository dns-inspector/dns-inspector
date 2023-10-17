//
//  DNSQuestion.h
//  DNSKit
//
//  Created by Ian Spence on 2023-10-15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSQuestion : NSObject

@property (strong, nonatomic, nonnull, readonly) NSString * name;
@property (nonatomic) NSUInteger questionType;
@property (nonatomic) NSUInteger questionClass;

@end

NS_ASSUME_NONNULL_END
