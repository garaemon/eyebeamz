//
//  MCZResultViewController.m
//  eyebeamz
//
//  Created by Ryohei Ueda on 12/06/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MCZResultViewController.h"
#import "MCZUtil.h"
@interface MCZResultViewController ()
@property (strong, nonatomic) NSString* html;
@property (strong, nonatomic) NSString* imageURL;
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;
@property (strong, nonatomic) UIView* indicatorView;
@property (nonatomic) BOOL lock;
@end

@implementation MCZResultViewController
@synthesize lock = _lock;
@synthesize activityIndicator = _activityIndicator;
@synthesize indicatorView = _indicatorView;
@synthesize html = _html;
@synthesize imageURL = _imageURL;
- (id)init {
  self = [super init];
  if (self) {
    
  }
  return self;
}

- (void)createIndicator
{
  if (!_indicatorView) {
    CGRect frame = CGRectMake(0, 0,
                              320, 480);
    _indicatorView = [[UIView alloc] initWithFrame:frame];
    _indicatorView.backgroundColor = MCZRGBA(0.0, 0.0, 0.0, 0.8);
    _indicatorView.hidden = YES;
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = LOCALIZED_STRING(@"saving...");
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue"
                                 size:13];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    label.center = CGPointMake(320.0 / 2.0, 260);
    [_indicatorView addSubview:label];
  }
  if (!_activityIndicator) {
    CGRect indicatorFrame = CGRectMake((320 - 21) / 2.0,
                                       (480 - 21) / 2.0,
                                       21, 21);
    _activityIndicator
      = [[UIActivityIndicatorView alloc] initWithFrame:indicatorFrame];
    _activityIndicator.activityIndicatorViewStyle
      = UIActivityIndicatorViewStyleWhite;
    [_indicatorView addSubview:_activityIndicator];
    [self.view addSubview:_indicatorView];
    // [self.view addSubview:_indicatorView];
    [self.view bringSubviewToFront:_indicatorView];
  }
}

- (void)showIndicator
{
  _indicatorView.hidden = NO;
  if (![_activityIndicator isAnimating])
    [_activityIndicator startAnimating];
}

- (void)hideIndicator
{
  _indicatorView.hidden = YES;
  if ([_activityIndicator isAnimating])
    [_activityIndicator stopAnimating];
}


- (void)loadHTMLString:(NSString*)html imageURL:(NSString*)imageURL
{
  LOG_INFO(@"loadHTMLString");
  _imageURL = imageURL;
  _html = html;
}

- (void)clickCancel
{
  [self dismissModalViewControllerAnimated:YES];
}

- (void)clickSave
{
  if (!_lock) {
    _lock = YES;
    NSString* path = _imageURL;
    NSURL* url = [NSURL URLWithString:path];
    NSData* data = [NSData dataWithContentsOfURL:url];
    UIImage* img = [[UIImage alloc] initWithData:data];
    [self showIndicator];
    [self.view bringSubviewToFront:_indicatorView];
    UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL );
  }
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
  if(!error){
    NSLog(@"Save the image is complete.");
  } else {
    NSLog(@"Failed to save the image.");
  }
  [self hideIndicator];
  _lock = NO;
}


- (void)loadView
{
  self.title = @"Result";
  UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Save"
                                               style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(clickSave)];
  self.navigationItem.rightBarButtonItem = rightButton;
  UIBarButtonItem* leftButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Close"
                                               style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(clickCancel)];
  self.navigationItem.leftBarButtonItem = leftButton;
  LOG_INFO(@"loadView");
  [super loadView];
  self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460 - 44)];
  UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
  [webView loadHTMLString:_html baseURL:nil];
  [self.view addSubview:webView];
  [self createIndicator];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  LOG_INFO(@"good bye!");
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
