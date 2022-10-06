
#ifndef CustomInstrinctContentSizeView_h
#define CustomInstrinctContentSizeView_h

@interface CustomInstrinctContentSizeView : NSView

+ (CustomInstrinctContentSizeView *)withInstrinctContentSize: (NSSize)size;

@property NSSize intrinsicContentSize;

@end

@implementation CustomInstrinctContentSizeView

+ (CustomInstrinctContentSizeView *)withInstrinctContentSize: (NSSize)size {
    CustomInstrinctContentSizeView *view = [[CustomInstrinctContentSizeView alloc] init];
    view.intrinsicContentSize = size;
    return view;
}

@end

#endif /* CustomInstrinctContentSizeView_h */
