//
//  MCZRootViewController.m
//  eyebeamz
//
//  Created by Ryohei Ueda on 12/06/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MCZRootViewController.h"
#import "MCZUtil.h"
#import "MCZNetworkClient.h"
#import "MCZResultViewController.h"

@interface MCZRootViewController ()
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;
@property (strong, nonatomic) UIView* indicatorView;

@end

@implementation MCZRootViewController
@synthesize activityIndicator = _activityIndicator;
@synthesize indicatorView = _indicatorView;

- (void)createIndicator
{
  if (!_indicatorView) {
    CGRect frame = CGRectMake(0, 0,
                              320, 480);
    _indicatorView = [[UIView alloc] initWithFrame:frame];
    _indicatorView.backgroundColor = MCZRGBA(0.0, 0.0, 0.0, 0.8);
    _indicatorView.hidden = YES;
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = LOCALIZED_STRING(@"uploading...");
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
    //[self.view addSubview:_indicatorView];
    // [self.view addSubview:_indicatorView];
    // [self.view bringSubviewToFront:_indicatorView];
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


- (void)alertView:(NSString*)title message:(NSString*)message
{
  UIAlertView* alert
    = [[UIAlertView alloc]
        initWithTitle:title
              message:message
             delegate:nil
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
  [alert show];
}

- (id)initWithoutStyle
{
  self = [self initWithStyle:UITableViewStyleGrouped];
  if (self) {
    
  }
  return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;
 
  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)loadView {
  [super loadView];
  [self createIndicator];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
  // Configure the cell...
  NSInteger row = indexPath.row;
  NSInteger section = indexPath.section;
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:CellIdentifier];
  }
  switch (section) {
  case 0:
    switch (row) {
    case 0:
      cell.textLabel.text = LOCALIZED_STRING(@"take a picture");
      break;
    case 1:
      cell.textLabel.text = LOCALIZED_STRING(@"choose from photoroll");
      break;
    default:
      break;
    }
    break;
  default:
    break;
  }
  
  return cell;
}

- (void)openCameraPicker:(UIImagePickerControllerSourceType)sourceType
{
  if (![UIImagePickerController
             isSourceTypeAvailable:sourceType]) {
    [self alertView:@"Bad news"
            message:@"your device does not support this device"];
  }
  else {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    picker.allowsEditing = NO;
    LOG_INFO(@"open picker");
    [self presentModalViewController:picker animated:YES];
  }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  LOG_INFO(@"closed");
  [self dismissModalViewControllerAnimated:YES];
}

- (void)modalResultView:(MCZResultViewController*)resultView
{
  UINavigationController* navigationController
    = [[UINavigationController alloc]
        initWithRootViewController:resultView];
  [self presentModalViewController:navigationController animated:YES];
}

- (void)showResult:(NSURL*)imageURL
{
  NSString* baseURL = @"https://eyebeam.herokuapp.com";
  NSString* fullURL = FORMAT(@"%@%@",baseURL, imageURL);
  MCZResultViewController* resultView = [[MCZResultViewController alloc] init];
  [resultView loadHTMLString:FORMAT(@"<html>\
<head>\
</head>\
<body>\
<img src='%@' />\
</body>\
</html>\
", fullURL) imageURL:fullURL];
  [self performSelector:@selector(modalResultView:)
             withObject:resultView
             afterDelay:0.5];
}

- (void)imagePickerController:(UIImagePickerController*)picker
        didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo
{
  LOG_INFO(@"closed");
  __weak __block MCZRootViewController* weakSelf = self;
  MCZNetworkClient* client = [MCZNetworkClient callback:^(NSString* result){
      if (IS_VALID_STRING(result)) {
        // extract image url
        NSError* error = nil;
        NSRegularExpression *regexp =
        [NSRegularExpression regularExpressionWithPattern:@"src='(/beam/.+\.jpg)'"
                                                  options:0
                                                    error:&error];
        NSMutableArray *dats = [[NSMutableArray alloc] init];
        [regexp enumerateMatchesInString:result options:0 
                                   range:NSMakeRange(0, result.length)
                              usingBlock:^(NSTextCheckingResult *arr, NSMatchingFlags flag, BOOL *stop) {
            [dats addObject: [result substringWithRange:[arr rangeAtIndex:1]]];
          }];
        
        if ([dats count] > 0) {
          // success
          LOG_INFO(@"success! %@", dats);
          [weakSelf dismissModalViewControllerAnimated:YES];
          [weakSelf showResult:ELT(dats, 0)];
        }
        else {
          // error
          LOG_INFO(@"failed!");
          [weakSelf alertView:@"Sorry" message:@"Failed to upload the image"];
          [weakSelf dismissModalViewControllerAnimated:YES];
        }
      }
      else {
        LOG_INFO(@"failed!");
        [weakSelf alertView:@"Sorry" message:@"Failed to upload the image"];
        [weakSelf dismissModalViewControllerAnimated:YES];
      }
    }];
  // before that, we add indicator
  [self showIndicator];
  [picker.view addSubview:_indicatorView];
  [picker.view bringSubviewToFront:_indicatorView];
  if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
    // smallize
    UIImage *image_resized;  // リサイズ後UIImage
    float widthPer = 0.5;  // リサイズ後幅の倍率
    float heightPer = 0.5;  // リサイズ後高さの倍率
    
    CGSize sz = CGSizeMake(image.size.width*widthPer,
                           image.size.height*heightPer);
    UIGraphicsBeginImageContext(sz);
    [image drawInRect:CGRectMake(0, 0, sz.width, sz.height)];
    image_resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [client postPhoto:image_resized];
  }
  else {
    [client postPhoto:image];
  }
}

#pragma mark - Table view delegate
   
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  NSInteger section = indexPath.section;
  NSInteger row = indexPath.row;
  if (section == 0 && row == 0)
    [self openCameraPicker:UIImagePickerControllerSourceTypeCamera];
  else if (section == 0 && row == 1)
    [self openCameraPicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

@end
