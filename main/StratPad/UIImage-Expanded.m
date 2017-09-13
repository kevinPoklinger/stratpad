//
//  UIImage-Expanded.m
//  StratPad
//
//  Created by Julian Wood on 12-01-17.
//  Copyright (c) 2012 Glassey Strategy. All rights reserved.
//

#import "UIImage-Expanded.h"

@implementation UIImage (Expanded)

- (CGSize)sizeForProportionalImageWithMaxDim:(CGFloat)maxDim
{
    // our target rect is a square, with image scaled proportionately to fit inside
	CGSize sz = self.size;
	CGFloat ratio = 0;
	if (sz.width > sz.height) {
		ratio = maxDim / sz.width;
	}
	else {
		ratio = maxDim / sz.height;
	}
    if (ratio < 1.0) {
        return CGSizeMake(ratio * sz.width, ratio * sz.height);
    } else {
        return sz;
    }
}

- (UIImage *)imageFromPDFWithDocumentRef:(CGPDFDocumentRef)documentRef
{
    CGPDFPageRef pageRef = CGPDFDocumentGetPage(documentRef, 1);
    CGRect pageRect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
    
    UIGraphicsBeginImageContext(pageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, CGRectGetMinX(pageRect),CGRectGetMaxY(pageRect));
    CGContextScaleCTM(context, 1, -1);  
    CGContextTranslateCTM(context, -(pageRect.origin.x), -(pageRect.origin.y));
    CGContextDrawPDFPage(context, pageRef);
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}

- (UIImage *)scaledImage:(UIImage*)image size:(CGSize)size 
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect blendMode:kCGBlendModePlusDarker alpha:1];
    UIImage *tmpValue = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tmpValue;
}


@end
