//
//  CTYunOSSConfig.m
//  TestOSS
//
//  Created by simple on 2021/1/20.
//

#import "CTYunOSSConfig.h"

@implementation CTYunOSSConfig
+ (CTYunOSSConfig *)share
{
    static CTYunOSSConfig * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CTYunOSSConfig alloc] init];
    });
    
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}
@end
