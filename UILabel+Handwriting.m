//
//  UILabel+Handwriting.m
//  num
//
//  Created by Kien on 12/9/14.
//  Copyright (c) 2014 Thkeen. All rights reserved.
//

#import "UILabel+Handwriting.h"
#import "NSObject+PerformBlock.h"
#import "UIView+Frame.h"
#import <CoreText/CoreText.h>

// Create path from text
// See: http://www.codeproject.com/KB/iPhone/Glyph.aspx
// License: The Code Project Open License (CPOL) 1.02 http://www.codeproject.com/info/cpol10.aspx

@implementation UILabel (Handwriting)

- (void)clearAllWritingText {
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
}

- (void)setHandwritingText:(NSString *)text color:(UIColor*)textColor animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion{
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    self.text = @"";
    CGMutablePathRef letters = CGPathCreateMutable();
    
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)font, kCTFontAttributeName,
                           nil];
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[self.text stringByAppendingString:text]
                                                                     attributes:attrs];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    
    // for each RUN
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
    {
        // Get FONT for this run
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = (CTFontRef)CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        // for each GLYPH in run
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
        {
            // get Glyph & Glyph-data
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            // Get PATH of outline
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(letters, &t, letter);
                CGPathRelease(letter);
            }
        }
    }
    CFRelease(line);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path appendPath:[UIBezierPath bezierPathWithCGPath:letters]];
    
    CGPathRelease(letters);
    CFRelease(font);
    
    CAShapeLayer *pathLayer;
    pathLayer = [CAShapeLayer layer];
    pathLayer.frame = (self.textAlignment == NSTextAlignmentLeft) ? CGRectMake(0, -6, self.bounds.size.width, self.bounds.size.height) : self.bounds;
    pathLayer.bounds = (self.textAlignment == NSTextAlignmentCenter) ? CGPathGetBoundingBox(path.CGPath) : self.bounds;
    pathLayer.geometryFlipped = YES;
    pathLayer.strokeColor = textColor.CGColor;
    pathLayer.fillColor = [UIColor clearColor].CGColor;
    pathLayer.lineWidth = 1;
    pathLayer.lineJoin = kCALineJoinBevel;
    pathLayer.shouldRasterize = NO;
    [self.layer addSublayer:pathLayer];
    pathLayer.path = path.CGPath;
    
    // animation down here
    
    if (duration > 0) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = duration;
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        [pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
        
        [NSObject performBlock:^{
            pathLayer.fillColor = textColor.CGColor;
            pathLayer.lineWidth = 0;
            
            CABasicAnimation *fillAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
            fillAnimation.duration = 0.2;
            fillAnimation.fromValue = (id)[UIColor clearColor].CGColor;
            fillAnimation.toValue = (id)textColor.CGColor;
            [pathLayer addAnimation:fillAnimation forKey:@"fillColor"];
            
            CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
            lineAnimation.duration = duration;
            lineAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
            lineAnimation.toValue = [NSNumber numberWithFloat:0.0f];
            [pathLayer addAnimation:lineAnimation forKey:@"lineWidth"];
            
            [NSObject performBlock:^{
                if (completion) {
                    completion();
                }
            } afterDelay:0.2];
            
        } afterDelay:duration];
        
    } else {
        pathLayer.fillColor = textColor.CGColor;
        pathLayer.lineWidth = 0;
        if (completion) {
            completion();
        }
    }
}


@end
