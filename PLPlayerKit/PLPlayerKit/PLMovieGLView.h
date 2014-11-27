//
//  ESGLView.h
//  PLPlayerKit
//
//  Created by 0day on 14/11/13
//  Copyright (c) 2012 qgenius. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLVideoFrame;
@class PLMovieDecoder;

@interface PLMovieGLView : UIView

- (id)initWithFrame:(CGRect)frame
            decoder:(PLMovieDecoder *)decoder;

- (void)render:(PLVideoFrame *)frame;

@end
