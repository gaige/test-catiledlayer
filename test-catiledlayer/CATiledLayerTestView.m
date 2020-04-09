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
    
    CATiledLayer *layer = [[CATiledLayer alloc] init];
    layer.delegate = self;
    layer.bounds = NSRectToCGRect( [self bounds]);
    layer.anchorPoint = CGPointMake( 0.0f, 0.0f);
    layer.name = @"Test Layer";
    layer.contentsScale = NSScreen.deepestScreen.backingScaleFactor;
    layer.tileSize = CGSizeMake( 16, 16);
    
    self.tiledLayer = layer;
    [self.layer addSublayer: layer];
    _drawSynchronizeQueue = dispatch_queue_create( "drawSynchronizer", DISPATCH_QUEUE_SERIAL);

}

- (void)mouseDown:(NSEvent *)event
{
    NSLog(@"Boom!");
    [self.tiledLayer setNeedsDisplay];
    
}


- (void)drawLayer:(CALayer *)caLayer inContext:(CGContextRef)ctx
{
    __block BOOL addedDrawer = NO;

    CGRect bbox = CGContextGetClipBoundingBox( ctx);
    
    NSRect drawBounds = NSRectFromCGRect( bbox); // although we might need to transform through tx
    CGAffineTransform transform = CGContextGetCTM( ctx);
    CGSize scaledSize = CGSizeApplyAffineTransform( bbox.size,  transform);
    NSLog(@"Bounding box %g,%g (%g,%g) -- ctm: %g,%g (%g,%g): Thread %@ -- %@",
          bbox.origin.x, bbox.origin.y, bbox.size.width, bbox.size.height,
          transform.tx, transform.ty,
          scaledSize.width, scaledSize.height,
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
    
    NSLog(@"Hi");
        
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
