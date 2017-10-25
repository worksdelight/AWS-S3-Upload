/*
 * Copyright 2017 worksdelight or its affiliates. All Rights Reserved.
 * Visit https://www.worksdelight.com
 */

@import UIKit;
@import ELCImagePickerController;

@interface UploadViewController : UIViewController


- (IBAction)showAlertController:(id)sender;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

@end

@interface UploadCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *label;

@end
