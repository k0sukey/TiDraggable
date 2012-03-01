//
//  TiDraggableView.m
//  draggable
//
//  Created by Pedro Enrique on 1/21/12.
//  Copyright 2012 Pedro Enrique
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "TiDraggableView.h"
#import "TiUtils.h"



@implementation TiDraggableView

-(void)dealloc
{
	[super dealloc];
}

-(NSDictionary *)_center
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithFloat:self.center.x], @"x", 
							[NSNumber numberWithFloat:self.center.y], @"y",
							nil];
}

#pragma mark view resize

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{

	// get the width and height of "self" which is a TiUIView (DraggableView)
	
	width = frame.size.width;
	height = frame.size.height;

	// minTop and minLeft are the origin of the view
//	minTop = frame.origin.y;
//	minLeft = frame.origin.x;

}

// ========================================================================

#pragma mark touch events

// touchStart event
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	left = self.frame.origin.x;
	top = self.frame.origin.y;
	
	// get the center of the view
	beginCenter = self.center;
	
	
	touchStart = [touches anyObject];
	locationStart = [touchStart locationInView:self.superview];

	// get the touch point in relation to it's parent
	offsetX = locationStart.x - beginCenter.x;
	offsetY = locationStart.y - beginCenter.y;
	
	// boolean to see if the view has moved for the touchEnd event
	hasMoved = false;

	if([self.proxy _hasListeners:@"start"])
	{
		NSDictionary *tiProps = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithFloat:left], @"left",
									[NSNumber numberWithFloat:top], @"top",
									[self _center], @"center",
									nil];
		[self.proxy fireEvent:@"start" withObject:tiProps];
	}

}

// touchMove event
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// boolean to know if the view has moved. 
	hasMoved = true;
	
	// get the coordinates while moving around
	touchMove = [touches anyObject];
	location = [touchMove locationInView:self.superview];

	// get the center of the view to see in chich direction we're moving (before the move)
	oldLeft = self.center.x;
	oldTop = self.center.y;

	// in which axis to move
	if(axis && [axis isEqualToString:@"x"])
	{
		location.x -= offsetX;
		location.y = beginCenter.y;
	}
	else
	if(axis && [axis isEqualToString:@"y"])
	{
		location.y -= offsetY;
		location.x = beginCenter.x;
	}
	else 
	{
		location.x -= offsetX;
		location.y -= offsetY;
	}

	// relocate the view
	self.center = location;
	
	// get the center of the view to see in chich direction we're moving (after the move)
	newLeft = self.center.x;
	newTop = self.center.y;

	if([self.proxy _hasListeners:@"move"])
	{
		NSDictionary *tiProps = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithFloat:self.frame.origin.x], @"left",
									[NSNumber numberWithFloat:self.frame.origin.y], @"top",
									[self _center], @"center",
									nil];
		[self.proxy fireEvent:@"move" withObject:tiProps];
	}
}

// touchEnd event
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{	
	// get the coordinates of the view
	left = self.frame.origin.x;
	top = self.frame.origin.y;

	// do this is the view has moved:
	if(hasMoved == true)
	{
		if(adsorb == 1)
		{
			// adsorb corner
			if(left > maxLeft * 0.5)
			{
				left = maxLeft;
			}
			else
			{
				left = minLeft;
			}

			if(top > maxTop * 0.5)
			{
				top = maxTop;
			}
			else
			{
				top = minTop;
			}
		}
		else if(adsorb == 2)
		{
			// adsorb vertical
			if(left > maxLeft)
			{
				left = maxLeft;
			}
			else if(left < minLeft)
			{
				left = minLeft;
			}

			if(top > maxTop * 0.5)
			{
				top = maxTop;
			}
			else
			{
				top = minTop;
			}
		}
		else if(adsorb == 3)
		{
			// adsorb horizontal
			if(left > maxLeft * 0.5)
			{
				left = maxLeft;
			}
			else
			{
				left = minLeft;
			}

			if(top > maxTop)
			{
				top = maxTop;
			}
			else if(top < minTop)
			{
				top = minTop;
			}
		}
		else if(adsorb == 4)
		{
			// adsorb specified
		}
		else
		{
			// IF we have a maxLeft, reposition, reposition accordingly
			if(left > maxLeft)
			{
				left = maxLeft;
			}
			else if(left < minLeft)
			{
				left = minLeft;
			}

			// IF we have a maxTop, reposition accordingly
			if(top > maxTop)
			{
				top = maxTop;
			}
			else if(top < minTop)
			{
				top = minTop;
			}
		}
	}

	// animate the view
	[UIView beginAnimations:@"end_dragging" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(finishAnimation:finished:context:)];
	self.frame = CGRectMake(left, top, width, height);	
	[UIView commitAnimations];
	
	// reset the hasMoved flag
//	hasMoved = false;
}

- (void)finishAnimation:(NSString *)animationId finished:(BOOL)finished context:(void *)context
{
	if([self.proxy _hasListeners:@"end"])
	{
		NSDictionary *tiProps = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithFloat:self.frame.origin.x], @"left",
									[NSNumber numberWithFloat:self.frame.origin.y], @"top",
									[self _center], @"center",
									[NSNumber numberWithBool:hasMoved], @"hasMoved",
									nil];
		[self.proxy fireEvent:@"end" withObject:tiProps];								
	}

	hasMoved = false;	
}

// ========================================================================

#pragma mark JavaScript properties

-(void)setAxis_:(id)args
{
	ENSURE_SINGLE_ARG(args, NSString);
	axis = args;
}

-(void)setAdsorb_:(id)args
{
	ENSURE_SINGLE_ARG(args, NSNumber);
	adsorb = [TiUtils intValue:args];
}

-(void)setMaxTop_:(id)args
{
	ENSURE_SINGLE_ARG(args, NSNumber);
	maxTop = [TiUtils floatValue:args];
}

-(void)setMaxLeft_:(id)args
{
	ENSURE_SINGLE_ARG(args, NSNumber);
	maxLeft = [TiUtils floatValue:args];
}

-(void)setMinTop_:(id)args
{
	ENSURE_SINGLE_ARG(args, NSNumber);
	minTop = [TiUtils floatValue:args];
}

-(void)setMinLeft_:(id)args
{
	ENSURE_SINGLE_ARG(args, NSNumber);
	minLeft = [TiUtils floatValue:args];
}

@end
