//
//  DynamicBounce.h
//  ScrollViewDemystify
//
//  Created by aaaron7 on 5/13/16.
//  Copyright © 2016 aaaron7. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface DynamicBounce : NSObject<UIDynamicItem>


@property (nonatomic,readwrite) CGPoint center;
@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic,readwrite) CGAffineTransform transform;

@end
