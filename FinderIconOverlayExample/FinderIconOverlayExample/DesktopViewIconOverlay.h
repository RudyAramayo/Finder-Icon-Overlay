//
//  DesktopViewIconOverlay.h
//  FinderIconOverlayExample
//
//  Created by Villela Medina on 2/20/13.
//
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import "Finder.h"

@interface DesktopViewIconOverlay : NSObject

+ (void)pluginLoad;
- (void) FO_prepareToDrawNode:(const struct TFENode *)arg1;
- (void) FO_drawIconInContext:(struct CGContext *)arg1;

@end
