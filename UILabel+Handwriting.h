//
//  UILabel+Handwriting.h
//  num
//
//  Created by Kien on 12/9/14.
//  Copyright (c) 2014 Thkeen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Handwriting)
- (void)clearAllWritingText;
- (void)setHandwritingText:(NSString *)text color:(UIColor*)textColor animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;
@end
