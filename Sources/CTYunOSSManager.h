//
//  CTYunOSSManager.h
//  TestOSS
//
//  Created by simple on 2021/1/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTYunOSSManager : NSObject
/// 上传文件
/// @depre
/// @param datas 文件data
- (NSArray*)uploads:(NSArray*)datas;

/// 上传文件
/// @param data 文件data
- (void)upload:(NSData*)data finishBlock:(void (^)(NSString *imageUrl))block;

+ (CTYunOSSManager *)share;
@end

NS_ASSUME_NONNULL_END
