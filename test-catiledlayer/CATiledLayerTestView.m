//
//  CATiledLayerTestView.m
//  test-catiledlayer
//
//  Created by Gaige B. Paulsen on 4/9/20.
//  Copyright © 2020 Gaige B. Paulsen. All rights reserved.
//

#import "CATiledLayerTestView.h"

@implementation CATiledLayerTestView

-(void)awakeFromNib
{
    NSLog(@"Starting");
    self.layer = [[CALayer alloc] init];
    self.wantsLayer = YES;
    
    _tlDelegate = [[MyDrawingDelegate alloc] init];
    
    _tiledLayer = [[CATiledLayer alloc] init];
    _tiledLayer.delegate = _tlDelegate;
    _tiledLayer.bounds = NSRectToCGRect( [self bounds]);
    _tiledLayer.frame = _tiledLayer.bounds;
    _tiledLayer.anchorPoint = CGPointMake( 0.0f, 0.0f);
    _tiledLayer.name = @"Test Layer";
    _tiledLayer.contentsScale = NSScreen.deepestScreen.backingScaleFactor;
    _tiledLayer.tileSize = CGSizeMake( 16, 16);
    _tiledLayer.levelsOfDetail = 4;
    _tiledLayer.levelsOfDetailBias = 1;
    
    _tlDelegate.tiledLayer = _tiledLayer;
    [self.layer addSublayer: _tiledLayer];
    _drawSynchronizeQueue = dispatch_queue_create( "drawSynchronizer", DISPATCH_QUEUE_SERIAL);

}

- (void)mouseDown:(NSEvent *)event
{
    NSLog(@"Boom!");
    [self.tiledLayer setNeedsDisplay];
    [self.layer setNeedsDisplay];
}


- (void)drawLayer:(CALayer *)caLayer inContext:(CGContextRef)ctx
{
    __block BOOL addedDrawer = NO;

    CGRect bbox = CGContextGetClipBoundingBox( ctx);
    
    NSLog(@"Bounding box %g,%g (%g,%g) : Thread %@ -- %@",
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
    sleep(1);
    
    if (addedDrawer) {
//        NSAssert( caLayer== tiledLayer, @"not a tiled layer when we left");        // can't do this unless we get our layer killed
        dispatch_sync( _drawSynchronizeQueue, ^{
            atomic_fetch_sub(&self->drawers, 1);
            NSAssert(self->drawers>=0, @"Shouldn't submarine drawers");
        });
    }

}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSLog(@"Shouldn't get called");
}

@end
