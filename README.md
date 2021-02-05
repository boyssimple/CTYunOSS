# CTYunOSS
天翼云OSS

第一步添加Pod
如需要可添加，source 'https://github.com/CocoaPods/Specs.git'
  
pod 'CTYunOSS'

第二步引入头文件

#import <CTYunOSS/CTYunOSSManager.h>
#import <CTYunOSS/CTYunOSSConfig.h>

第三步

    [CTYunOSSConfig share].accessKey = @"0d1333f2073bacf0c27c";
    [CTYunOSSConfig share].securityKey = @"b55dfa5531329fe41c6e6bd3b0b14a41f70d9891";
    [CTYunOSSConfig share].domain = @"cqoss.xstore.ctyun.cn";
    [CTYunOSSConfig share].bucketDomain = @"myt-yh.cqoss.xstore.ctyun.cn";
    [CTYunOSSConfig share].bucket = @"myttest";
    
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"d" withExtension:@"jpg"];
    NSData *data = [[NSData alloc]initWithContentsOfURL:url];
    [[CTYunOSSManager share] upload:data finishBlock:^(NSString * _Nonnull imageUrl) {
        NSLog(@"%@,%@",@"上传完成",imageUrl);
    }];
