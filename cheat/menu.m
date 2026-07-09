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

        // เรียกจัดเมนูให้อยู่กึ่งกลางครั้งแรกตอนสร้าง
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

        // ปรับขอบเขตการลากให้เหมาะสมกับความกว้างหน้าจอปัจจุบัน
        CGFloat maxX = hostSize.width; 
        if (maxX < halfW) {
            maxX = halfW;
        }
        newCenter.x = MAX(halfW, MIN(newCenter.x, maxX));

        self.center = newCenter;
        _initialTouchPoint = touchPoint;
    }
}

// จุดที่ 1: อัปเดตขนาดวิว ImGui และสั่งจัดตำแหน่งเมื่อมีการหมุนจอ
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imguiController.view.frame = self.bounds;
    [self centerMenu];
}

// จุดที่ 2: เขียนตรรกะการคำนวณหาจุดกึ่งกลางจอจริง (ดึงจากขนาดหน้าต่างแม่ หรือ หน้าจอหลัก)
- (void)centerMenu
{
    // ดึงขนาดขอบเขตหน้าจอหลัก ณ วินาทีนั้น ๆ (จะสลับสัดส่วน W/H ตามแนวตั้ง-นอนให้เองอัตโนมัติ)
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    // หาก MenuView ถูกใส่เข้าไปในเป้าหมายที่มีมุมมองจำกัด ให้ใช้ขนาดของ superview แทน (ถ้ามี)
    if (self.superview) {
        screenBounds = self.superview.bounds;
    }
    
    self.center = CGPointMake(screenBounds.size.width / 2.0f, screenBounds.size.height / 2.0f);
}

@end
