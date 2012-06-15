//
//  MCZUtil.h
//  mczungry
//
//  Created by Ryohei Ueda on 12/01/10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#include <stdio.h>
#include <time.h>

#define ELT(A,I) ([A objectAtIndex:I])
#define DICT(...) ([NSDictionary dictionaryWithObjectsAndKeys:__VA_ARGS__, nil])
#define MDICT(...) ([NSMutableDictionary dictionaryWithObjectsAndKeys:__VA_ARGS__, nil])
#define FORMAT(...) ([NSString stringWithFormat:__VA_ARGS__])
#define ARRAY(...) ([[NSArray alloc] initWithObjects:__VA_ARGS__, nil])
#define MARRAY(...) ([[NSMutableArray alloc] initWithObjects:__VA_ARGS__, nil])
#define ASSOC(D, K) ([D objectForKey:K])
#define PREDICATE(F, ...) ([NSPredicate predicateWithFormat:F, __VA_ARGS__])
#define INDEX_PATH(R,S) ([NSIndexPath indexPathForRow:R inSection:S])
#define LOCALIZED_STRING(S) (NSLocalizedString(S, S))
#define AB_TESTING(A,B) ([(MCZAppDelegate*)[[UIApplication sharedApplication] delegate] ABTesting] ? A: B)
#define IS_VALID_STRING(s) (s && s != NULL && ![s isEqual:[NSNull null]] && [s length] > 0)
#define MAKE_ARRAY(O,C) (^{\
      NSMutableArray* array = [NSMutableArray array];   \
      for (NSInteger i = 0; i < C; i++) {               \
        [array addObject:O];                            \
      }                                                 \
      return array;                                     \
}())

#define CG_RECT_MAKE_SHORT(N) (CGRectMake(N##_X, N##_Y, N##_WIDTH, N##_HEIGHT))
#define UI_FONT_SHORT(N) ([UIFont fontWithName:N size:N##_SIZE])

#define RUN_JS(W,J) ([W stringByEvaluatingJavaScriptFromString:J])

#define MCZRGB(R,G,B) ([UIColor colorWithRed:R green:G blue:B alpha:1.0])
#define MCZRGBA(R,G,B,A) ([UIColor colorWithRed:R green:G blue:B alpha:A])
#define MCZRGB255(R,G,B) ([UIColor colorWithRed:R/255.0 \
                                          green:G/255.0 \
                                           blue:B/255.0 \
                                          alpha:1.0])
#define MCZRGBA255(R,G,B, A) ([UIColor colorWithRed:R/255.0       \
                                              green:G/255.0       \
                                               blue:B/255.0       \
                                              alpha:A])

#ifdef DEBUG
// #define LOG_INFO(...)  NSLog(__VA_ARGS__)
// #define LOG_WARN(...)  NSLog(__VA_ARGS__)
// #define LOG_ERROR(...) NSLog(__VA_ARGS__)
// #define LOG_FATAL(...) NSLog(__VA_ARGS__)
#define LOG_INFO(...)  NSLog(@"[INFO/%s] %@", __func__, FORMAT(__VA_ARGS__))
#define LOG_WARN(...)  NSLog(@"[WARN/%s] %@",                   \
                             __func__, FORMAT(__VA_ARGS__))
#define LOG_ERROR(...) NSLog(@"[ERROR/%s] %@",                  \
                             __func__, FORMAT(__VA_ARGS__))
#define LOG_FATAL(...) NSLog(@"[FATAL/%s] %@", __func__, FORMAT(__VA_ARGS__))
#else
#define LOG_INFO(...) ;
#define LOG_WARN(...) ;
#define LOG_ERROR(...) ;
#define LOG_FATAL(...) ;
#endif  // DEBUG


#define PUSH_GDC_QUEUE(BLOCK) \
  (dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), BLOCK))
#define IN_GCD_MAIN_QUEUE(BLOCK) (dispatch_async(dispatch_get_main_queue(), BLOCK))
#define WAIT_GCD (dispatch_sync(\
                    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{}))

//#define IS_ALPHABET(c) ((c >= 0x24B6 && c <= 0x24E9))
#define IS_UNICHAR_ASCII(c) (c < 256)

#define PUT_REVEAL_BUTTON {\
  UIImage* leftButtonImage                              \
  = [UIImage imageNamed:SLIDER_HOME_REVEAL_BUTTON];     \
  UIButton *leftButton                                  \
  = [[UIButton alloc]                                   \
    initWithFrame:CGRectMake(0, 0,                                      \
                             leftButtonImage.size.width,                \
                             leftButtonImage.size.height)];             \
  leftButton.contentMode = UIViewContentModeScaleToFill;                \
  [leftButton addTarget:self action:@selector(clickRevealButton:)       \
       forControlEvents:(UIControlEventTouchDown)];                     \
  [leftButton setBackgroundImage:leftButtonImage                        \
                        forState:UIControlStateNormal];                 \
  UIBarButtonItem *itemLeftButton = [[UIBarButtonItem alloc]            \
                                          initWithCustomView:leftButton]; \
  self.navigationItem.leftBarButtonItem = itemLeftButton;               \
  }

#define SET_NAVIGATION_BAR_TITLE {                                      \
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];   \
    titleLabel.font = UI_FONT_SHORT(NAVIGATION_BAR_TITLE_FONT);         \
    titleLabel.textColor = NAVIGATION_BAR_TITLE_FONT_COLOR;             \
    titleLabel.text = self.title;                                       \
    titleLabel.shadowColor = NAVIGATION_BAR_TITLE_FONT_SHADOW_COLOR;    \
    titleLabel.shadowOffset = NAVIGATION_BAR_TITLE_FONT_SHADOW_OFFSET;  \
    titleLabel.backgroundColor = [UIColor clearColor];                  \
    [titleLabel sizeToFit];                                             \
    self.navigationItem.titleView = titleLabel;                         \
  }

#define APP_LANG (NSLocalizedString(@"en", @"lang"))
#define SHOW_ERROR_POPUP(M) {                   \
    [SVProgressHUD show];                       \
    [SVProgressHUD dismissWithError:M];         \
  }
#define SHOW_SUCCESS_POPUP(M) {                   \
    [SVProgressHUD show];                       \
    [SVProgressHUD dismissWithSuccess:M];         \
  }

#define URLREQUEST_FROM_STRING(s) \
  ([NSURLRequest requestWithURL:[NSURL URLWithString:s]])

#define CALC_TIME_BEGIN clock_t __start_time__ = clock()
#define CALC_TIME_END(S) {                       \
  clock_t end_time = clock();                   \
  LOG_WARN(@"%@: %f", S, (double)(end_time - __start_time__) / CLOCKS_PER_SEC);    \
}
