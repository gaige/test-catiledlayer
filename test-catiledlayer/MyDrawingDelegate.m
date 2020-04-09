//
//  MyDrawingDelegate.m
//  test-catiledlayer
//
//  Created by Gaige B. Paulsen on 4/9/20.
//  Copyright © 2020 Gaige B. Paulsen. All rights reserved.
//

#include <stdatomic.h>
#import "MyDrawingDelegate.h"

@implementation MyDrawingDelegate
- (instancetype)init
{
    self = [super init];
    if (self) {
           _drawSynchronizeQueue = dispatch_queue_create( "drawSynchronizer", DISPATCH_QUEUE_SERIAL);

    }
    return self;
}

- (void)drawLayer:(CALayer *)caLayer inContext:(CGContextRef)ctx
{
    __block BOOL addedDrawer = NO;

    CGRect bbox = CGContextGetClipBoundingBox( ctx);
    
    NSLog(@"MDD: Bounding box %g,%g (%g,%g) : Thread %@ -- %@",
          bbox.origin.x, bbox.origin.y, bbox.size.width, bbox.size.height,
          [NSThread currentThread],
          [caLayer name]);

    dispatch_sync( _drawSynchronizeQueue, ^{
        if (caLayer == self->_tiledLayer) {
            atomic_fetch_add( &self->drawers, 1);
            addedDrawer = YES;
            if (self->drawers>self->maxDrawers) {
                self->maxDrawers=self->drawers;
                NSLog(@"Max now %d", self->maxDrawers);
            }
        }
    });
//    sleep(1);
    
    if (addedDrawer) {
//        NSAssert( caLayer== tiledLayer, @"not a tiled layer when we left");        // can't do this unless we get our layer killed
        dispatch_sync( _drawSynchronizeQueue, ^{
            atomic_fetch_sub(&self->drawers, 1);
            NSAssert(self->drawers>=0, @"Shouldn't submarine drawers");
        });
    }

}

@end
