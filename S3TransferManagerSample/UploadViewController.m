/*
 * Copyright 2017 worksdelight or its affiliates. All Rights Reserved.
 * Visit https://www.worksdelight.com
 */

#import "UploadViewController.h"
#import <AWSS3/AWSS3.h>
#import "Constants.h"

@import AssetsLibrary;


@interface UploadViewController ()

@property (nonatomic, strong) NSMutableArray *collection;

@end

@implementation UploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // We will upload & inorder to download you can uncomment the download method.
    [self upload];
   // [self download];
}

- (void)upload{
    
    //We are uploading a static image here you can choose one from library.
    
    //Uploading multiple images asynchronously
    for (int i =0;i<4;i++)
    {
        
        UIImage *img = [UIImage imageNamed:@"circleface"];
        
        //Just generating a different filename everytime and adding extension to the file.
        NSString *fileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingString:@".png"];
        
        //Creating a temporary directory name there at the bucket
        NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:fileName];
        //Convert image to Data
        NSData * imageData = UIImagePNGRepresentation(img);
        
        [imageData writeToFile:filePath atomically:YES];
        
        //Note that this is not the bucket url infact is your local path
        NSURL* fileUrl = [NSURL fileURLWithPath:filePath];

        
        //Here is the few lines of code to upload
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        uploadRequest.body = fileUrl;
        uploadRequest.bucket = S3BucketName;
        uploadRequest.key = fileName;
        uploadRequest.contentType = @"image/png";
        
        //You can add any meta data here ,i'm using the tag in download to check the progress of each upload/download
        uploadRequest.metadata = @{@"tag":[NSString stringWithFormat:@"%i",i]};
        [self upload:uploadRequest];
        [self showprogress:uploadRequest];
    }
    

    
}
// This method reads and shows progress in a progress view
- (void)showprogress:(AWSS3TransferManagerUploadRequest*)uploadRequest
{
    int progressTag = [uploadRequest.metadata[@"tag"] intValue];

    NSLog(@"%@",uploadRequest.metadata);
    uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (totalBytesExpectedToSend > 0) {
                 float progress = (float)((double) totalBytesSent / totalBytesExpectedToSend);
                NSLog(@"%f",progress);
                
                if(progressTag == 0)
                {
                    _progressView.progress = progress;

                }
                else
                {
                    UIProgressView *v = [self.view viewWithTag:progressTag];
                    v.progress = progress;

                }
                
            }
        });
    };
}


- (void)download
{
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"myImage.png"];
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    downloadRequest.bucket = S3BucketName;
    
    // This is the same name that you upload with so store this locally or on your server
    //here it is the static name from my bucket
    
    downloadRequest.key =  @"0E30CB48-4B4F-4782-B87D-B940342C24DF-3716-000003A77FEC6A81.png";
    downloadRequest.downloadingFileURL = downloadingFileURL;

    
    [[transferManager download:downloadRequest ] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                            withBlock:^id(AWSTask *task) {
                                                                if (task.error){
                                                                    if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                        switch (task.error.code) {
                                                                                case AWSS3TransferManagerErrorCancelled:
                                                                                case AWSS3TransferManagerErrorPaused:
                                                                                break;
                                                                                
                                                                            default:
                                                                                NSLog(@"Error: %@", task.error);
                                                                                break;
                                                                        }
                                                                        
                                                                    } else {
                                                                        NSLog(@"Error: %@", task.error);
                                                                    }
                                                                }
                                                                
                                                                if (task.result) {
                                                                    AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
                                                                    
                                                                    UIImage *img = [UIImage imageWithContentsOfFile:downloadingFilePath];
                                                                    NSLog(@"%@",img);

                                                                }
                                                                return nil;
                                                            }];
}

#pragma mark - User action methods

- (IBAction)showAlertController:(id)sender
{
    //you may use this method to choose an image
}


- (void)upload:(AWSS3TransferManagerUploadRequest *)uploadRequest {
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];

    [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{

                        });
                    }
                        break;

                    default:
                        NSLog(@"Upload failed: [%@]", task.error);
                        break;
                }
            } else {
                NSLog(@"Upload failed: [%@]", task.error);
            }
        }

        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                NSLog(@"**********completed");

            });
        }

        return nil;
    }];
}

- (void)cancelAllUploads:(id)sender {
    [self.collection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AWSS3TransferManagerUploadRequest class]]) {
            AWSS3TransferManagerUploadRequest *uploadRequest = obj;
            [[uploadRequest cancel] continueWithBlock:^id(AWSTask *task) {
                if (task.error) {
                    NSLog(@"The cancel request failed: [%@]", task.error);
                }
                return nil;
            }];
        }
    }];
}

@end
