//
// VerticallyAlignedLabel.h
//
// You can specify vertical alignment on this label.
// Note that you can add a runtime attribute in IB for verticalAlignment, using Number.

#import <Foundation/Foundation.h>


typedef enum VerticalAlignment {
    VerticalAlignmentTop,
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface UILabelVAlignment : UILabel {
@private
    VerticalAlignment verticalAlignment_;
}

@property (nonatomic, assign) VerticalAlignment verticalAlignment;

@end