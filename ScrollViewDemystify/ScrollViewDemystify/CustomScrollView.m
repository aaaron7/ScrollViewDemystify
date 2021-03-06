//
//  CustomScrollView.m
//  ScrollViewDemystify
//
//  Created by aaaron7 on 5/13/16.
//  Copyright © 2016 aaaron7. All rights reserved.
//

#import "CustomScrollView.h"
#import "DynamicBounce.h"

static CGFloat rubberBandDistance(CGFloat offset, CGFloat dimension) {

    const CGFloat constant = 0.35f;
    CGFloat result = (constant * abs(offset) * dimension) / (dimension + constant * abs(offset));
    // The algorithm expects a positive offset, so we have to negate the result if the offset was negative.
    return offset < 0.0f ? -result : result;
}

@interface CustomScrollView ()<UIGestureRecognizerDelegate>

@property(nonatomic) CGPoint lastPanOffset;
@property(nonatomic) CGRect startBounds;
@property(nonatomic,strong) UIPanGestureRecognizer* gr;
@property(nonatomic,strong) DynamicBounce* bounceObject;
@property(nonatomic, strong) UIDynamicAnimator* animator;
@property(nonatomic,strong) UIDynamicItemBehavior* behavior;
@property(nonatomic,strong) UIAttachmentBehavior* spring;
@property(nonatomic,readonly) CGPoint maxOrigin;
@property(nonatomic,readonly) CGPoint minOrigin;

@end

@implementation CustomScrollView

@dynamic contentOffset;
@dynamic maxOrigin;
@dynamic minOrigin;

-(id)init{
    self = [super init];
    if(self){
        [self setup];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setup];
    }
    return self;
}

-(void)setup{
    _gr = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    _gr.delegate = self;
    [self addGestureRecognizer:_gr];

    self.bounceObject = [[DynamicBounce alloc]init];
    self.animator = [[UIDynamicAnimator alloc]initWithReferenceView:self];
}


-(void)setContentOffset:(CGPoint)contentOffset{
    CGRect bounds = self.bounds;

    bounds.origin.x = contentOffset.x;
    bounds.origin.y = contentOffset.y;
    [self setBounds:bounds];

    BOOL outOfBounds = contentOffset.x < self.minOrigin.x || contentOffset.x > self.maxOrigin.x ||
    contentOffset.y < self.minOrigin.y || self.contentOffset.y > self.maxOrigin.y;

    /*
     behavior必须存在，因为只有动作结束之后才存在这个效果
     spring不能存在，因为spring代表这个效果已经被激活了，无需再次激活
     */
    if(outOfBounds && self.behavior && !self.spring){
        CGPoint target = bounds.origin;
        if(bounds.origin.y < self.minOrigin.y){
            target.y = self.minOrigin.y;
        }else if (bounds.origin.y > self.maxOrigin.y){
            target.y = self.maxOrigin.y;
        }


        UIAttachmentBehavior* springBehavior = [[UIAttachmentBehavior alloc]initWithItem:self.bounceObject attachedToAnchor:target];
        springBehavior.length = 0;
        springBehavior.damping = 1;
        springBehavior.frequency = 2;

        [self.animator addBehavior:springBehavior];
        self.spring = springBehavior;
    }


}

-(CGPoint)contentOffset{
    return self.bounds.origin;
}

-(CGPoint)maxOrigin{
    CGFloat maxOriginX = self.contentSize.width - self.bounds.size.width;
    CGFloat maxOriginY = self.contentSize.height - self.bounds.size.height;
    return CGPointMake(maxOriginX, maxOriginY);
}

-(CGPoint)minOrigin{
    return CGPointMake(0, 0);
}

-(void)handlePan:(UIPanGestureRecognizer*)gestureRecognizer{
    CGPoint panOffset = [gestureRecognizer translationInView:self];

    CGPoint realOffset = CGPointMake(panOffset.x - _lastPanOffset.x, panOffset.y - _lastPanOffset.y);
    _lastPanOffset = panOffset;
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        _lastPanOffset = CGPointZero;

        CGPoint velocity = [gestureRecognizer velocityInView:self];
        self.bounceObject.center = self.bounds.origin;
        UIDynamicItemBehavior* beh = [[UIDynamicItemBehavior alloc]initWithItems:@[self.bounceObject]];
        velocity.x = - velocity.x;
        velocity.y = - velocity.y;

        if (self.bounds.origin.x <= self.minOrigin.x || self.bounds.origin.x >= self.maxOrigin.x){
            velocity.x = 0;
        }

        if (self.bounds.origin.y <= self.minOrigin.y || self.bounds.origin.y >= self.maxOrigin.y){
            velocity.y = 0;
        }
        
        [beh addLinearVelocity:velocity forItem:self.bounceObject];
        beh.resistance = 2.0;

        __weak typeof (self)weakSelf = self;
        beh.action = ^{
            CGRect bounds = self.bounds;
            bounds.origin = weakSelf.bounceObject.center;
            self.contentOffset = weakSelf.bounceObject.center;
        };

        [self.animator addBehavior:beh];
        self.behavior = beh;
    }else if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        [self.animator removeAllBehaviors];
        self.startBounds = self.bounds;
        self.spring = nil;
        self.behavior = nil;
        self.lastPanOffset = panOffset;
    }else{
        CGPoint offset = self.contentOffset;
        offset.y -= realOffset.y;

        CGFloat realBoundsOffsetY = self.contentOffset.y - panOffset.y;

        CGFloat minOffsetX = 0;
        CGFloat minOffsetY = 0;
        CGFloat maxOffsetY = self.contentSize.height - self.bounds.size.height;
        CGFloat maxOffsetX = self.contentSize.width - self.bounds.size.width;

        CGFloat validOriginX = fmin(offset.x,maxOffsetX);
        validOriginX = fmax(validOriginX,minOffsetX);
        //    CGFloat bounceX = rubberBandDistance(contentOffset.x - validOriginX, CGRectGetWidth(self.bounds));

        CGFloat validOriginY = fmin(offset.y,maxOffsetY);
        validOriginY = fmax(validOriginY,minOffsetY);
        CGFloat bounceY = rubberBandDistance(realBoundsOffsetY - validOriginY, CGRectGetHeight(self.bounds));

        CGPoint finalOffset = CGPointMake(validOriginX, validOriginY + bounceY);

        [self setContentOffset:finalOffset];
    }
}


@end
