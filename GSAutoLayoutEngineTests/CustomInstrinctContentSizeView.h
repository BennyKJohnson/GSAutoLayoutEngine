
#ifndef CustomInstrinctContentSizeView_h
#define CustomInstrinctContentSizeView_h

@interface CustomInstrinctContentSizeView : NSView

+ (CustomInstrinctContentSizeView *)withInstrinctContentSize: (CGSize)size;

@property NSSize intrinsicContentSize;

@end

@implementation CustomInstrinctContentSizeView

+ (CustomInstrinctContentSizeView *)withInstrinctContentSize: (CGSize)size {
    CustomInstrinctContentSizeView *view = [[CustomInstrinctContentSizeView alloc] init];
    view.intrinsicContentSize = size;
    return view;
}

@end

#endif /* CustomInstrinctContentSizeView_h */
