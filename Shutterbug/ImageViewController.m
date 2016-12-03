//
//  ImageViewController.m
//  Imaginarium
//
//  Created by Ultimate on 11/29/15.
//  Copyright (c) 2015 Lehman College. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation ImageViewController

-(UIImageView *)imageView
{
    if(!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.imageView.image = image;
    [self.imageView sizeToFit];
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    [self.spinner stopAnimating];
    [self setZoomScale];
}

- (void)setZoomScale
{
    double heightScale = (self.scrollView.bounds.size.height - self.navigationController.navigationBar.frame.size.height - self.tabBarController.tabBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height) / self.imageView.image.size.height;
    double widthScale = self.scrollView.bounds.size.width / self.imageView.image.size.width;
    if (heightScale < widthScale){
        self.scrollView.zoomScale = widthScale;
    }else{
        self.scrollView.zoomScale = heightScale;
    }
}

- (UIImage *)image
{
    return self.imageView.image;
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}


- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self startDownloadingImage];
}


- (void)startDownloadingImage
{
    self.image = nil;
    [self.spinner startAnimating];
    if (self.imageURL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSURLSessionDownloadTask *task = [session
                                          downloadTaskWithRequest:request
                                          completionHandler:^(NSURL *localFile, NSURLResponse *response,
                                                              NSError *error) {
                                              if (!error) {
                                                  if ([request.URL isEqual:self.imageURL]) {
                                                      UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localFile]];
                                                      [self performSelectorOnMainThread:@selector(setImage:)
                                                                             withObject:image
                                                                          waitUntilDone:NO];
                                                  }
                                              }
                                          }];
        [task resume];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}



#pragma mark - UISplitViewControllerDelegate

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}


- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}



- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = aViewController.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}


- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}

@end
