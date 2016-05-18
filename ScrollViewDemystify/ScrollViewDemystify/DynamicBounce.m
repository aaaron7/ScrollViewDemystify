//
//  DynamicBounce.m
//  ScrollViewDemystify
//
//  Created by aaaron7 on 5/13/16.
//  Copyright © 2016 aaaron7. All rights reserved.
//

#import "DynamicBounce.h"

@implementation DynamicBounce

-(instancetype)init{
    self = [super init];
    if (self){
        _bounds = CGRectMake(0, 0, 1, 1);
    }
    return self;
}

@end
