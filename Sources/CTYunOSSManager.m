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
                    [results addObject:fileName];
                }
                return task;
            }];
        }
    }
    return results;
}


/// 上传文件
/// @param data 文件data
- (void)upload:(NSData*)data finishBlock:(void (^)(NSString *fileName))block{
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
                if (block) {
                    block(fileName);
                }
            }
            return task;
        }];
    }
}

/// 上传文件
/// @param fileName 文件名称
- (void)download:(NSString*)fileName finishBlock:(void (^)(UIImage *image))block{
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"download_temp.jpg"]];
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    
    OOSTransferManagerDownloadRequest *downloadRequest = [OOSTransferManagerDownloadRequest new];
    downloadRequest.bucket = [CTYunOSSConfig share].bucket;
    downloadRequest.key = fileName;
    downloadRequest.downloadingFileURL = downloadingFileURL;
    
    [[self.transferManager download:downloadRequest] continueWithBlock:^id(OOSTask *task) {
        if (task.error){
            NSLog(@"Error: %@", task.error);
        }
        
        if (task.result) {
            NSData *data = [NSData dataWithContentsOfFile:downloadingFilePath];
            if (block) {
                block([UIImage imageWithData:data]);
            }
//            dispatch_async(dispatch_get_main_queue(), ^{
                
//                imageView.image = [UIImage imageWithContentsOfFile:downloadingFilePath];
//            });
        }
        return nil;
    }];
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
