//
//  UIImage-Expanded.h
//  StratPad
//
//  Created by Julian Wood on 12-01-17.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Expanded)

- (CGSize)sizeForProportionalImageWithMaxDim:(CGFloat)maxDim;
- (UIImage *)imageFromPDFWithDocumentRef:(CGPDFDocumentRef)documentRef;
- (UIImage *)scaledImage:(UIImage*)image size:(CGSize)size;

@end
