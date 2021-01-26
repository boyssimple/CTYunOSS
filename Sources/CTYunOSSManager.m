//
//  CTYunOSSManager.m
//  TestOSS
//
//  Created by simple on 2021/1/22.
//

/*
 实例
NSURL *url = [[NSBundle mainBundle] URLForResource:@"d" withExtension:@"jpg"];
NSData *data = [[NSData alloc]initWithContentsOfURL:url];
[[CTYunOSSManager share] upload:data finishBlock:^(NSString * _Nonnull fileName) {
    NSLog(@"%@,%@",@"上传完成",fileName);
    [[CTYunOSSManager share] download:fileName finishBlock:^(UIImage * _Nonnull image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
        });
    }];
}];
*/


#import "CTYunOSSManager.h"
#import <CTYunOSS/OOS.h>
#import "CTYunOSSConfig.h"

@interface CTYunOSSManager()
@property (nonatomic, copy) OOSTransferManager *transferManager;
@end
@implementation CTYunOSSManager
+ (CTYunOSSManager *)share
{
    static CTYunOSSManager * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CTYunOSSManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        // 可以在网页中获取secretKey
        OOSStaticCredentialsProvider *provider = [[OOSStaticCredentialsProvider alloc] initWithAccessKey:[CTYunOSSConfig share].accessKey secretKey:[CTYunOSSConfig share].securityKey];
        // 选择所属Region
        OOSServiceConfiguration *configuration = [[OOSServiceConfiguration alloc] initWithRegion:OOSRegionZhengZhou
                                                                             credentialsProvider:provider];
        configuration.maxRetryCount = [CTYunOSSConfig share].maxRetryCount;
        configuration.timeoutIntervalForRequest =  [CTYunOSSConfig share].timeoutIntervalForRequest;
        // 设为默认配置
        [OOSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
        
        _transferManager = [OOSTransferManager defaultTransferManager];
    }
    return self;
}


/// 上传文件
/// @param datas 文件data
- (NSArray*)uploads:(NSArray*)datas{
    NSMutableArray *results = [[NSMutableArray alloc]initWithCapacity:[datas count]];
    for (NSData *data in datas) {
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.jpg"];
        BOOL saved = [data writeToFile:filePath atomically:NO];
        if (saved) {
            OOSTransferManagerUploadRequest *uploadRequest = [OOSTransferManagerUploadRequest new];
            NSString *fileName = [self uuidString];
            uploadRequest.bucket = [CTYunOSSConfig share].bucket;//@"myttest";
            uploadRequest.key = fileName;
            uploadRequest.body = [NSURL fileURLWithPath:filePath];
             
            [[self.transferManager upload:uploadRequest] continueWithBlock:^id(OOSTask *task) {
                if (task.error){
                    NSLog(@"Error: %@", task.error);
                }
                
                if (task.result) {
                    NSString *url = [NSString stringWithFormat:@"http://%@.oos-cn.ctyunapi.cn/%@",[CTYunOSSConfig share].bucket,fileName];
                    [results addObject:url];
                }
                return task;
            }];
        }
    }
    return results;
}


/// 上传文件
/// @param data 文件data
- (void)upload:(NSData*)data finishBlock:(void (^)(NSString *imageUrl))block{
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.jpg"];
    BOOL saved = [data writeToFile:filePath atomically:NO];
    if (saved) {
        OOSTransferManagerUploadRequest *uploadRequest = [OOSTransferManagerUploadRequest new];
        NSString *fileName = [NSString stringWithFormat:@"%@.png",[self uuidString]];
        uploadRequest.bucket = [CTYunOSSConfig share].bucket;//@"myttest";
        uploadRequest.key = fileName;
        uploadRequest.body = [NSURL fileURLWithPath:filePath];
         
        [[self.transferManager upload:uploadRequest] continueWithBlock:^id(OOSTask *task) {
            if (task.error){
                NSLog(@"Error: %@", task.error);
            }
            
            if (task.result) {
                if (block) {
                    //拼接
//                http://myttest.oos-cn.ctyunapi.cn/61063a05-18ef-4785-a0a3-0a9cbfeaed73.jpg
                    NSString *url = [NSString stringWithFormat:@"http://%@.oos-cn.ctyunapi.cn/%@",[CTYunOSSConfig share].bucket,fileName];
                    block(url);
                }
            }
            return task;
        }];
    }
}


- (NSString *)uuidString

{

    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);

    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);

    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];

    CFRelease(uuid_ref);

    CFRelease(uuid_string_ref);

    return [uuid lowercaseString];

}
@end
