
#import <XCTest/XCTest.h>
#import "GSAutoLayoutEngine.h"
#import "CustomBaselineView.h"
#import "CustomInstrinctContentSizeView.h"

// TODO Fix priority strength to support lower priorities that have a value greater than 1
CGFloat minimalPriorityHackValue = 1.0;

@interface GSAutoLayoutEngineTestCase : XCTestCase
@end

@implementation GSAutoLayoutEngineTestCase
{
    GSAutoLayoutEngine *engine;
}

- (void)setUp {
    engine = [[GSAutoLayoutEngine alloc] init];
}

-(NSLayoutConstraint*)widthConstraintForView: (NSView*)view constant: (CGFloat)constant
{
    return [NSLayoutConstraint
            constraintWithItem:view attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:constant];
}

-(NSLayoutConstraint*)heightConstraintForView: (NSView*)view constant: (CGFloat)constant
{
    return [NSLayoutConstraint
            constraintWithItem:view attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:constant];
}

-(void)addPositionConstraintsForSubView: (NSView*)subView superView: (NSView*)superView position: (CGPoint)position
{
    NSLayoutConstraint *xConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:position.x];
    
    NSLayoutConstraint *yConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:position.y];

    [engine addConstraint: xConstraint];
    [engine addConstraint:yConstraint];
}

-(void)pinView: (NSView*)subView toTopLeftCornerOfSuperView: (NSView*)superView engine: (GSAutoLayoutEngine*)engine
{
    NSLayoutConstraint *subViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    NSLayoutConstraint *subViewTopConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    [engine addConstraint:subViewLeadingConstraint];
    [engine addConstraint:subViewTopConstraint];
}

-(void)pinView: (NSView*)subView toTopRightCornerOfSuperView: (NSView*)superView engine: (GSAutoLayoutEngine*)engine
{
    NSLayoutConstraint *subViewTrailing = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    NSLayoutConstraint *subViewTopConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    [engine addConstraint:subViewTrailing];
    [engine addConstraint:subViewTopConstraint];
}

-(void)pinView: (NSView*)subView toBottomLeftCornerOfSuperView: (NSView*)superView engine: (GSAutoLayoutEngine*)engine
{
    [self addPositionConstraintsForSubView:subView superView:superView position:CGPointMake(0, 0)];
}

- (NSView*)createRootViewWithSize: (CGSize)size engine: (GSAutoLayoutEngine*)engine
{
    NSView *view = [[NSView alloc] init];
    [engine addInternalConstraintsToView:view];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
            constraintWithItem:view attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:size.width];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:size.height];
    
    [engine addConstraint: widthConstraint];
    [engine addConstraint: heightConstraint];

    return view;
}

-(void)centerSubView: (NSView*)subView inSuperView: (NSView*)superView engine: (GSAutoLayoutEngine*)engine
{
    NSLayoutConstraint *subViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *subViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [engine addConstraint:subViewCenterXConstraint];
    [engine addConstraint:subViewCenterYConstraint];
}

-(void)verticallyStackViewsSuperView: (NSView*)superView topView:(NSView*)topView bottomView: (NSView*)bottomView
{
    [self pinView:topView toTopLeftCornerOfSuperView:superView engine:engine];
    [self pinView:bottomView toBottomLeftCornerOfSuperView:superView engine:engine];
    
    NSLayoutConstraint *view1ToView2Constraint = [NSLayoutConstraint constraintWithItem:topView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bottomView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [engine addConstraint:view1ToView2Constraint];
    [engine addIntrinsicContentSizeConstraintsToView:topView];
    [engine addIntrinsicContentSizeConstraintsToView:bottomView];
}

-(void)horizontallyStackViewsInsideSuperView: (NSView*)superView leftView:(NSView*)leftView rightView: (NSView*)rightView
{
    [self pinView:leftView toTopLeftCornerOfSuperView:superView engine:engine];
    [self pinView:rightView toTopRightCornerOfSuperView:superView engine:engine];
    NSLayoutConstraint *view1ToView2Constraint = [NSLayoutConstraint constraintWithItem:leftView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:rightView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];

    [engine addConstraint:view1ToView2Constraint];
    
    [engine addIntrinsicContentSizeConstraintsToView:leftView];
    [engine addIntrinsicContentSizeConstraintsToView:rightView];
}


-(void)assertAlignmentRect:(NSRect)receivedRect expectedRect: (NSRect)expectedRect
{
    XCTAssertTrue(NSEqualRects(receivedRect, expectedRect));
}

-(void)testSolvesLayoutForRootViewWithWidthAndHeightConstraints
{
    NSView *rootView = [[NSView alloc] init];
    [engine addInternalConstraintsToView:rootView];
    // Define width and height
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
            constraintWithItem:rootView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:800];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:rootView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:600];
    [engine addConstraint:widthConstraint];
    [engine addConstraint:heightConstraint];

    NSRect rootViewFrame = [engine alignmentRectForView: rootView];
    [self assertAlignmentRect:rootViewFrame expectedRect: CGRectMake(0, 0, 800, 600)];
}

-(void)testSolvesLayoutForSubviewWithLeadingTrailingTopAndBottomConstraintsToSuperView
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(800, 600) engine:engine];
    NSView *subView = [[NSView alloc] init];
    NSArray *layoutAttributes = @[
        @(NSLayoutAttributeLeading),
        @(NSLayoutAttributeTrailing),
        @(NSLayoutAttributeTop),
        @(NSLayoutAttributeBottom),
    ];
    
    for (id attribute in layoutAttributes) {
        NSLayoutAttribute layoutAttribute = [(NSNumber*)attribute unsignedIntegerValue];
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:subView attribute:layoutAttribute relatedBy:NSLayoutRelationEqual toItem:rootView attribute:layoutAttribute multiplier:1.0 constant:10];
        [engine addConstraint: constraint];
    }

    NSRect subViewFrame = [engine alignmentRectForView:subView];
    [self assertAlignmentRect:subViewFrame expectedRect: CGRectMake(10, 10, 780, 580)];
}

-(void)testSolvesLayoutForSubViewWithLeftRightConstraintToSuperView
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(500, 500) engine: engine];
    NSView *subView = [[NSView alloc] init];
    NSArray *layoutAttributes = @[
        @(NSLayoutAttributeLeft),
        @(NSLayoutAttributeRight),
        @(NSLayoutAttributeTop),
        @(NSLayoutAttributeBottom),
    ];
    for (id attribute in layoutAttributes) {
        NSLayoutAttribute layoutAttribute = [(NSNumber*)attribute unsignedIntegerValue];
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:subView attribute:layoutAttribute relatedBy:NSLayoutRelationEqual toItem:rootView attribute:layoutAttribute multiplier:1.0 constant:10];
        [engine addConstraint: constraint];
    }
    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    [self assertAlignmentRect:subViewFrame expectedRect:CGRectMake(10, 10, 480, 480)];
}

-(void)testSolvesLayoutWithHorizontalCenterConstraint
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    NSView *subView = [[NSView alloc] init];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    NSLayoutConstraint *subViewTopConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeTop multiplier:1.0 constant:20];
    NSLayoutConstraint *subViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
    [engine addConstraint:widthConstraint];
    [engine addConstraint:heightConstraint];
    [engine addConstraint:subViewTopConstraint];
    [engine addConstraint:subViewCenterXConstraint];
        
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    [self assertAlignmentRect:subViewFrame expectedRect:CGRectMake(150, 280, 100, 100)];
}

-(void)testSolvesLayoutWithVerticalCenterConstraint
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    NSView *subView = [[NSView alloc] init];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    NSLayoutConstraint *subViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *subViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    
    [engine addConstraint:widthConstraint];
    [engine addConstraint:heightConstraint];
    [engine addConstraint:subViewCenterXConstraint];
    [engine addConstraint:subViewCenterYConstraint];
    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrame, CGRectMake(150, 150, 100, 100)));
}

-(void)testSolvesLayoutWithRequiredAndNonRequiredPriorityConstraints
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    NSView *subView = [[NSView alloc] init];
    
    NSLayoutConstraint *nonRequiredWidthConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    nonRequiredWidthConstraint.priority = NSLayoutPriorityDefaultHigh;
    NSLayoutConstraint *requiredWidthConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
    requiredWidthConstraint.priority = NSLayoutPriorityRequired;
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];


    [engine addConstraint:nonRequiredWidthConstraint];
    [engine addConstraint:requiredWidthConstraint];
    [engine addConstraint:heightConstraint];
    [self centerSubView:subView inSuperView:rootView engine:engine];

    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrame, CGRectMake(100, 150, 200, 100)));
}

-(void)testSolvesLayoutWithConstraintsUsingCustomPriorities
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    NSView *subView = [[NSView alloc] init];
    
    NSLayoutConstraint *nonRequiredWidthConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    nonRequiredWidthConstraint.priority = 499;
    NSLayoutConstraint *requiredWidthConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
    requiredWidthConstraint.priority = 500;
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];


    [engine addConstraint:nonRequiredWidthConstraint];
    [engine addConstraint:requiredWidthConstraint];
    [engine addConstraint:heightConstraint];
    [self centerSubView:subView inSuperView:rootView engine:engine];

    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrame, CGRectMake(100, 150, 200, 100)));
}

-(void)testSolvesLayoutAfterRemovingConstraint
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    NSView *subView = [[NSView alloc] init];
    
    NSLayoutConstraint *constraintToRemove = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
            constraintWithItem:subView attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    [engine addConstraint:heightConstraint];
    
    [engine addConstraint:constraintToRemove];
    [engine addConstraint:widthConstraint];
    [self centerSubView:subView inSuperView:rootView engine:engine];

    NSRect subViewFrameBeforeRemovingConstraint = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrameBeforeRemovingConstraint, CGRectMake(150, 150, 100, 100)));
    
    [engine removeConstraint: constraintToRemove];
    NSRect subViewFrameAfterRemovingConstraint = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrameAfterRemovingConstraint, CGRectMake(100, 150, 200, 100)));
}

-(void)testSolvesLayoutAfterRemovingSeveralConstraints
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    NSView *subView = [[NSView alloc] init];
    
    NSLayoutConstraint *widthConstraintToRemove = [self widthConstraintForView:subView constant:100];
    NSLayoutConstraint *widthConstraint = [self widthConstraintForView:subView constant:200];
    NSLayoutConstraint *heightConstraintToRemove = [self heightConstraintForView:subView constant:100];
    NSLayoutConstraint *heightConstraint = [self heightConstraintForView:subView constant:200];
    
    [self centerSubView:subView inSuperView:rootView engine:engine];

    [engine addConstraint:widthConstraintToRemove];
    [engine addConstraint:widthConstraint];
    [engine addConstraint:heightConstraintToRemove];
    [engine addConstraint:heightConstraint];
    

    NSRect subViewFrameBeforeRemovingConstraint = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrameBeforeRemovingConstraint, CGRectMake(150, 150, 100, 100)));
    
    [engine removeConstraints: [NSArray arrayWithObjects:widthConstraintToRemove, heightConstraintToRemove, nil]];
    NSRect subViewFrameAfterRemovingConstraint = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrameAfterRemovingConstraint, CGRectMake(100, 100, 200, 200)));
}

-(void)testSolvesLayoutWithConstraintThatHasAMultiplier
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    NSView *subView = [[NSView alloc] init];
    [self centerSubView:subView inSuperView:rootView engine:engine];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeHeight multiplier:0.5 constant:0];
    
    [engine addConstraint:widthConstraint];
    [engine addConstraint:heightConstraint];
    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrame, CGRectMake(100, 100, 200, 200)));
}

-(CustomBaselineView*)createBaselineViewInsideSuperView:(NSView*)superView WithEngine: (GSAutoLayoutEngine*)engine
{
    CustomBaselineView *baselineView = [[CustomBaselineView alloc] init];
    NSLayoutConstraint *baselineWidth = [self widthConstraintForView:baselineView constant:20];
    NSLayoutConstraint *baselineHeight = [self heightConstraintForView:baselineView constant:20];
    NSLayoutConstraint *baselineX = [NSLayoutConstraint constraintWithItem:baselineView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *baselineY = [NSLayoutConstraint constraintWithItem:baselineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    
    [engine addConstraint:baselineWidth];
    [engine addConstraint:baselineHeight];
    [engine addConstraint:baselineX];
    [engine addConstraint:baselineY];
    
    return baselineView;
}

-(void)addSizeConstraintsToView: (NSView*)view engine: (GSAutoLayoutEngine*)engine size: (CGSize)size
{
    NSLayoutConstraint *widthConstraint = [self widthConstraintForView:view constant:size.width];
    NSLayoutConstraint *heightConstraint = [self heightConstraintForView:view constant:size.height];
    [engine addConstraint:widthConstraint];
    [engine addConstraint:heightConstraint];
}

-(void)testSolvesLayoutWithFirstBaselineConstraint
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    
    CustomBaselineView *baselineView = [self createBaselineViewInsideSuperView:rootView WithEngine:engine];
    baselineView.firstBaselineOffsetFromTop = 5;
    
    NSView *baselineOffsetView = [[NSView alloc] init];
    [self addSizeConstraintsToView:baselineOffsetView engine:engine size:CGSizeMake(20, 20)];

    NSLayoutConstraint *baselineOffsetX = [NSLayoutConstraint constraintWithItem:baselineOffsetView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    
    NSLayoutConstraint *baselineOffsetYConstraint = [NSLayoutConstraint constraintWithItem:baselineOffsetView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:baselineView attribute:NSLayoutAttributeFirstBaseline multiplier:1.0 constant:0];
    
    [engine addConstraint:baselineOffsetX];
    [engine addConstraint:baselineOffsetYConstraint];
    
    NSRect subViewFrameAfterUpdatingConstraint = [engine alignmentRectForView:baselineOffsetView];
    CGFloat expectedY = 400 - 5 - 20;
    XCTAssertTrue(NSEqualRects(subViewFrameAfterUpdatingConstraint, CGRectMake(0, expectedY, 20, 20)));
    baselineView.firstBaselineOffsetFromTop = 0;
    NSRect offsetViewFrameAfterUpdating = [engine alignmentRectForView:baselineOffsetView];
    XCTAssertTrue(NSEqualRects(offsetViewFrameAfterUpdating, CGRectMake(0, 380, 20, 20)));
}

-(void)testSolvesLayoutWithLastBaselineConstraint
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    
    CustomBaselineView *baselineView = [self createBaselineViewInsideSuperView:rootView WithEngine:engine];
    baselineView.baselineOffsetFromBottom = 10;
    
    NSView *baselineOffsetView = [[NSView alloc] init];
    [self addSizeConstraintsToView:baselineOffsetView engine:engine size:CGSizeMake(20, 20)];

    NSLayoutConstraint *baselineOffsetX = [NSLayoutConstraint constraintWithItem:baselineOffsetView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    
    NSLayoutConstraint *baselineOffsetYConstraint = [NSLayoutConstraint constraintWithItem:baselineOffsetView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:baselineView attribute:NSLayoutAttributeLastBaseline multiplier:1.0 constant:0];
    
    [engine addConstraint:baselineOffsetX];
    [engine addConstraint:baselineOffsetYConstraint];
    
    NSRect subViewFrameAfterUpdatingConstraint = [engine alignmentRectForView:baselineOffsetView];
    XCTAssertTrue(NSEqualRects(subViewFrameAfterUpdatingConstraint, CGRectMake(0, 370, 20, 20)));
    
    baselineView.baselineOffsetFromBottom = 0;
    NSRect offsetViewFrameAfterUpdating = [engine alignmentRectForView:baselineOffsetView];
    XCTAssertTrue(NSEqualRects(offsetViewFrameAfterUpdating, CGRectMake(0, 360, 20, 20)));
}

-(void)testAddingConflictingConstraintsDoesNotThrow
{
    NSView *view = [[NSView alloc] init];
    NSLayoutConstraint *widthConstraint = [self widthConstraintForView:view constant:100];
    NSLayoutConstraint *conflictingWidthConstraint = [self widthConstraintForView:view constant:200];
    
    GSAutoLayoutEngine *engine = [[GSAutoLayoutEngine alloc] init];
    [engine addConstraint: widthConstraint];
    [engine addConstraint: conflictingWidthConstraint];
}

-(void)testRemovingAConstraintThatHasNotBeenAddedDoesNotThrow
{
    NSView *view = [[NSView alloc] init];
    NSLayoutConstraint *widthConstraint = [self widthConstraintForView:view constant:100];
    GSAutoLayoutEngine *engine = [[GSAutoLayoutEngine alloc] init];
    [engine removeConstraint:widthConstraint];
}

-(void)testSolvesLayoutAfterUpdatingConstraint
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    NSView *subView = [[NSView alloc] init];
    NSLayoutConstraint *widthConstraint = [self widthConstraintForView:subView constant:100];
    NSLayoutConstraint *heightConstraint = [self heightConstraintForView:subView constant:100];
    
    [self centerSubView:subView inSuperView:rootView engine:engine];

    [engine addConstraint:widthConstraint];
    [engine addConstraint:heightConstraint];
    
    NSRect subViewFrameBeforeUpdatingConstraint = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrameBeforeUpdatingConstraint, CGRectMake(150, 150, 100, 100)));
    [widthConstraint setConstant:200];

    NSRect subViewFrameAfterUpdatingConstraint = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrameAfterUpdatingConstraint, CGRectMake(100, 150, 200, 100)));
}

-(void)testSolvesLayoutWithConstraintRelationGreaterThanOrEqual
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    NSView *subView = [[NSView alloc] init];
    
    [self centerSubView:subView inSuperView:rootView engine:engine];
    NSLayoutConstraint *heightConstraint = [self heightConstraintForView:subView constant:100];
    NSLayoutConstraint *widthGreaterThanConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
    
    NSLayoutConstraint *widthFixedConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:250];
    widthFixedConstraint.priority = 999;
    
    [engine addConstraint:heightConstraint];
    [engine addConstraint:widthGreaterThanConstraint];
    [engine addConstraint:widthFixedConstraint];
    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrame, CGRectMake(75, 150, 250, 100)));
}

-(void)testSolvesLayoutWithConstraintRelationLessThanOrEqual
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    NSView *subView = [[NSView alloc] init];
    
    [self centerSubView:subView inSuperView:rootView engine:engine];
    NSLayoutConstraint *heightConstraint = [self heightConstraintForView:subView constant:100];
    NSLayoutConstraint *widthLessThanConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:250];
    
    NSLayoutConstraint *widthFixedConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
    widthFixedConstraint.priority = 999;
    
    [engine addConstraint:heightConstraint];
    [engine addConstraint:widthLessThanConstraint];
    [engine addConstraint:widthFixedConstraint];
    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrame, CGRectMake(100, 150, 200, 100)));
}

-(void)testSolvesLayoutWithConstraintAssociatedRelationLessThanOrEqual
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    NSView *subView = [[NSView alloc] init];
    
    [self centerSubView:subView inSuperView:rootView engine:engine];
    NSLayoutConstraint *heightConstraint = [self heightConstraintForView:subView constant:100];
    NSLayoutConstraint *widthGreaterThanConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:rootView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    
    NSLayoutConstraint *widthFixedConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:250];
    widthFixedConstraint.priority = 999;
    
    [engine addConstraint:heightConstraint];
    [engine addConstraint:widthGreaterThanConstraint];
    [engine addConstraint:widthFixedConstraint];
    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrame, CGRectMake(75, 150, 250, 100)));
}

-(void)testSolvesLayoutWithConstraintAssociatedRelationGreaterThanOrEqual
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    NSView *subView = [[NSView alloc] init];
    NSView *associatedView = [[NSView alloc] init];
    
    NSLayoutConstraint *associatedViewWidthConstraint = [self widthConstraintForView:associatedView constant:100];
    NSLayoutConstraint *associatedViewHeightConstraint = [self heightConstraintForView:associatedView constant:100];
    
    
    [self centerSubView:subView inSuperView:rootView engine:engine];
    NSLayoutConstraint *heightConstraint = [self heightConstraintForView:subView constant:100];
    NSLayoutConstraint *widthGreaterThanConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:associatedView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    
    NSLayoutConstraint *widthFixedConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:250];
    widthFixedConstraint.priority = 999;
    
    [engine addConstraint:associatedViewWidthConstraint];
    [engine addConstraint:associatedViewHeightConstraint];
    [engine addConstraint:heightConstraint];
    [engine addConstraint:widthGreaterThanConstraint];
    [engine addConstraint:widthFixedConstraint];
    
    NSRect subViewFrame = [engine alignmentRectForView:subView];
    XCTAssertTrue(NSEqualRects(subViewFrame, CGRectMake(75, 150, 250, 100)));
}

-(void)testSolvesLayoutUsingViewIntrinsicContentSize
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    CustomInstrinctContentSizeView *subView = [[CustomInstrinctContentSizeView alloc] init];
    subView.intrinsicContentSize = CGSizeMake(40, 20);
    [engine addIntrinsicContentSizeConstraintsToView:subView];
    [self addPositionConstraintsForSubView:subView superView:rootView position:CGPointMake(0, 0)];
    
    NSRect subviewAlignRect = [engine alignmentRectForView: subView];
    XCTAssertTrue(NSEqualRects(subviewAlignRect, CGRectMake(0, 0, 40, 20)));
}

-(void)testSolvesLayoutWithCompetingIntrinsicContentSizeHorizontalHuggingResistancePriorities
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    CustomInstrinctContentSizeView *view1 = [CustomInstrinctContentSizeView withInstrinctContentSize:CGSizeMake(50, 20)];
    CustomInstrinctContentSizeView *view2 = [CustomInstrinctContentSizeView withInstrinctContentSize:CGSizeMake(50, 20)];
    
    [view1 setContentHuggingPriority:250 forOrientation:NSLayoutConstraintOrientationHorizontal];
    // TODO Fix priority strength to support content hugging priorities greater than 1
    [view2 setContentHuggingPriority:1 forOrientation:NSLayoutConstraintOrientationHorizontal];
//
    [self horizontallyStackViewsInsideSuperView:rootView leftView:view1 rightView:view2];
    
    NSRect view1Rect = [engine alignmentRectForView:view1];
    NSRect view2Rect = [engine alignmentRectForView:view2];
    
    XCTAssertTrue(NSEqualRects(view1Rect, CGRectMake(0, 380, 50, 20)));
    XCTAssertTrue(NSEqualRects(view2Rect, CGRectMake(50, 380, 350, 20)));
}

-(void)testSolvesLayoutWithCompetingIntrinsicContentSizeVerticalHuggingResistancePriorities
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    CustomInstrinctContentSizeView *view1 = [CustomInstrinctContentSizeView withInstrinctContentSize:CGSizeMake(50, 50)];
    CustomInstrinctContentSizeView *view2 = [CustomInstrinctContentSizeView withInstrinctContentSize:CGSizeMake(50, 50)];
    
    [view1 setContentHuggingPriority:250 forOrientation:NSLayoutConstraintOrientationVertical];
    // TODO Fix priority strength to support content hugging priorities greater than 1
    [view2 setContentHuggingPriority:1 forOrientation:NSLayoutConstraintOrientationVertical];
    
    [self verticallyStackViewsSuperView:rootView topView:view1 bottomView:view2];
        
    XCTAssertTrue(NSEqualRects([engine alignmentRectForView:view1], CGRectMake(0, 350, 50, 50)));
    XCTAssertTrue(NSEqualRects([engine alignmentRectForView:view2], CGRectMake(0, 0, 50, 350)));
}

-(void)testSolvesLayoutWithCompetingInstrinctContentSizeHorizonalCompressionResistance
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    CustomInstrinctContentSizeView *view1 = [CustomInstrinctContentSizeView withInstrinctContentSize:CGSizeMake(250, 20)];
    CustomInstrinctContentSizeView *view2 = [CustomInstrinctContentSizeView withInstrinctContentSize:CGSizeMake(250, 20)];
    
    [view1 setContentCompressionResistancePriority:750 forOrientation:NSLayoutConstraintOrientationHorizontal];
    [view2 setContentCompressionResistancePriority:minimalPriorityHackValue forOrientation:NSLayoutConstraintOrientationHorizontal];
    
    [self horizontallyStackViewsInsideSuperView:rootView leftView:view1 rightView:view2];
    
    XCTAssertTrue(NSEqualRects([engine alignmentRectForView:view1], CGRectMake(0, 380, 250, 20)));
    XCTAssertTrue(NSEqualRects([engine alignmentRectForView:view2], CGRectMake(250, 380, 150, 20)));
}

-(void)testSolvesLayoutWithCompetingInstrinctContentSizeVerticalCompressionResistance
{
    NSView *rootView = [self createRootViewWithSize:CGSizeMake(400, 400) engine:engine];
    CustomInstrinctContentSizeView *view1 = [CustomInstrinctContentSizeView withInstrinctContentSize:CGSizeMake(50, 250)];
    CustomInstrinctContentSizeView *view2 = [CustomInstrinctContentSizeView withInstrinctContentSize:CGSizeMake(50, 250)];
    
    [view1 setContentCompressionResistancePriority:750 forOrientation:NSLayoutConstraintOrientationVertical];
    [view2 setContentCompressionResistancePriority:minimalPriorityHackValue forOrientation:NSLayoutConstraintOrientationVertical];

    [self verticallyStackViewsSuperView:rootView topView:view1 bottomView:view2];
    
    [self assertAlignmentRect:[engine alignmentRectForView:view1] expectedRect:CGRectMake(0, 150, 50, 250)];
    [self assertAlignmentRect:[engine alignmentRectForView:view2] expectedRect:CGRectMake(0, 0, 50, 150)];
}

@end
