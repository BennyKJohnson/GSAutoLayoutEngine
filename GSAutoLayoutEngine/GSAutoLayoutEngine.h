
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSAutoLayoutEngine : NSObject

-(void)addConstraint: (NSLayoutConstraint*)constraint;

-(void)addConstraints: (NSArray*)constraints;

-(void)removeConstraint: (NSLayoutConstraint*)constraint;

-(void)removeConstraints: (NSArray*)constraints;

-(void)addInternalConstraintsToView: (NSView*)view;

-(void)addIntrinsicContentSizeConstraintsToView: (NSView*)view;

-(NSRect)alignmentRectForView: (NSView*)view;

-(NSString*)debugSolver;

@end

NS_ASSUME_NONNULL_END
