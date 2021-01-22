//
//  CTYunOSSConfig.h
//  TestOSS
//
//  Created by simple on 2021/1/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTYunOSSConfig : NSObject

// accessKey
@property (nonatomic, copy) NSString *accessKey;
// securityKey
@property (nonatomic, copy) NSString *securityKey;
// 地域
@property (nonatomic, copy) NSString *domain;
// bucket域名
@property (nonatomic, copy) NSString *bucketDomain;
// bucket
@property (nonatomic, copy) NSString *bucket;
// maxRetryCount
@property (nonatomic, assign) int maxRetryCount;                  //3
// maxRetryCount
@property (nonatomic, assign) NSInteger timeoutIntervalForRequest;      //5000



+ (CTYunOSSConfig *)share;
@end

NS_ASSUME_NONNULL_END
