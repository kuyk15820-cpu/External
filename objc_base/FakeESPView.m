#import "FakeESPView.h"

@implementation FakeESPView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return nil;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return NO;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) {
        return;
    }

    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);

    NSInteger boxCount = 5;
    CGFloat boxWidth = 50.0;
    CGFloat boxHeight = 80.0;
    CGFloat centerY = height * 0.4;

    UIColor *greenColor = [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1.0f];
    CGContextSetStrokeColorWithColor(context, greenColor.CGColor);
    CGContextSetLineWidth(context, 2.0);

    for (NSInteger index = 0; index < boxCount; index++) {
        CGFloat centerX = (width / (boxCount + 1)) * (index + 1);
        CGRect boxRect = CGRectMake(centerX - boxWidth / 2.0,
                                    centerY - boxHeight / 2.0,
                                    boxWidth,
                                    boxHeight);

        CGContextStrokeRect(context, boxRect);

        CGPoint fromPoint = CGPointMake(width * 0.5, height);
        CGPoint toPoint = CGPointMake(centerX, CGRectGetMaxY(boxRect));

        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y);
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y);
        CGContextStrokePath(context);
    }
}

@end
