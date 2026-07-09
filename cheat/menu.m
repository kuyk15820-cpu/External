#import "menu.h"
#import "Esp/ImGuiDrawView.h"

//Remade by andrdev
//Remade by https://t.me/andrdevv
//Remade by https://github.com/andrd3v

@implementation MenuView {
    CGPoint _initialTouchPoint;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;

        self.imguiController = [[ImGuiDrawView alloc] init];
        UIView *imguiView = self.imguiController.view;
        imguiView.frame = self.bounds;
        imguiView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imguiView.backgroundColor = [UIColor clearColor];
        [self addSubview:imguiView];

        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:panGesture];

        [self centerMenu];
    }
    return self;
}

- (void)hideMenu
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = NO;
        self.hidden = YES;
    }];
}

- (void)showMenu
{
    self.hidden = NO;
    self.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    CGPoint touchPoint = [gesture locationInView:self.superview];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _initialTouchPoint = touchPoint;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat deltaX = touchPoint.x - _initialTouchPoint.x;
        CGFloat deltaY = touchPoint.y - _initialTouchPoint.y;

        UIView *hostView = self.superview ?: self;
        CGSize hostSize = hostView.bounds.size;

        CGPoint newCenter = CGPointMake(self.center.x + deltaX, self.center.y + deltaY);

        CGFloat halfW = CGRectGetWidth(self.bounds) / 2.0;
        CGFloat halfH = CGRectGetHeight(self.bounds) / 2.0;

        newCenter.y = MAX(halfH, MIN(newCenter.y, hostSize.height - halfH));


        CGFloat maxX = hostSize.width * 0.5f;
        if (maxX < halfW) {
            maxX = halfW;
        }
        newCenter.x = MAX(halfW, MIN(newCenter.x, maxX));

        self.center = newCenter;
        _initialTouchPoint = touchPoint;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imguiController.view.frame = self.bounds;
}

- (void)centerMenu
{

}

@end
