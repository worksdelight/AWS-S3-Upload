/*
 * Copyright 2017 worksdelight or its affiliates. All Rights Reserved.
 * Visit https://www.worksdelight.com
 */

#import "AppDelegate.h"
#import "Constants.h"
#import <AWSS3/AWSS3.h>
@import AWSCore;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [self launchAWS];
    return YES;
}
- (void) launchAWS
{
    
    
    AWSStaticCredentialsProvider *staticprovider =
    
    [[AWSStaticCredentialsProvider alloc]initWithAccessKey:S3_Accesskey secretKey:S3_Secret];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast2 credentialsProvider:staticprovider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
}




@end
