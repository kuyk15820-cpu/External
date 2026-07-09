//Require standard library
#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>
#import <Foundation/Foundation.h>
// Minimal forward declarations for MTKView to avoid pulling in full MetalKit headers
@class MTKView;

@protocol MTKViewDelegate <NSObject>
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size;
- (void)drawInMTKView:(MTKView *)view;
@end

@interface MTKView : UIView
@property (nullable, nonatomic, strong) id<MTLDevice> device;
@property (nullable, nonatomic, weak) id<MTKViewDelegate> delegate;
@property (nonatomic) MTLClearColor clearColor;
@property (nullable, nonatomic, readonly) id<CAMetalDrawable> currentDrawable;
@property (nullable, nonatomic, readonly) MTLRenderPassDescriptor *currentRenderPassDescriptor;
@property (nonatomic) NSInteger preferredFramesPerSecond;
@end

//Imgui library
#import "Esp/CaptainHook.h"
#import "Esp/ImGuiDrawView.h"
#import "IMGUI/imgui.h"
#import "IMGUI/imgui_impl_metal.h"
#import "IMGUI/Honkai.h"

// Bridge to HUD layer to toggle ESP overlay visibility, HUD overlay, and hide menu.
extern "C" void HUDSetESPEnabled(bool enabled);
extern "C" void HUDSetOverlayEnabled(bool enabled);
extern "C" void HUDHideMenu(void);

// Bridge to HUD layer to toggle ESP overlay visibility and hide menu.
extern "C" void HUDSetESPEnabled(bool enabled);
extern "C" void HUDHideMenu(void);

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kScale [UIScreen mainScreen].scale

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@end

@implementation ImGuiDrawView

//I usually let the function for hooking in here...
void (*huy)(void *instance);
void _huy(void *instance)
{
    huy(instance);
}

static bool MenDeal = true;


- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];


    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];

    if (!self.device) {
        abort();
    }

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;

    ImGui::StyleColorsLight();
    
    ImFont* font = io.Fonts->AddFontFromMemoryCompressedTTF((void*)Honkai_compressed_data, Honkai_compressed_size, 45.0f, NULL, io.Fonts->GetGlyphRangesDefault());
    
    ImGui_ImplMetal_Init(_device);


    return self;
}

+ (void)showChange:(BOOL)open
{
    MenDeal = open;
}

- (MTKView *)mtkView
{
    return (MTKView *)self.view;
}

- (void)loadView
{

    UIWindow *window = [UIApplication sharedApplication].keyWindow ?: [UIApplication sharedApplication].windows.firstObject;
    CGFloat w = window.bounds.size.width;
    CGFloat h = window.bounds.size.height;
    self.view = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.mtkView.clipsToBounds = YES;

}



#pragma mark - Interaction

- (void)updateIOWithTouchEvent:(UIEvent *)event
{
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);

    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches)
    {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled)
        {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}



#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(MTKView*)view
{
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;

    CGFloat framebufferScale = view.window.screen.scale ?: UIScreen.mainScreen.scale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 120);
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    
    // ----------------------------------------------------
    // ตัวแปรฟังก์ชันเดิม
    // ----------------------------------------------------
    static bool espEnabled = false;
    static bool overlayEnabled = false;
    static bool show_s0_active = false;
    
    // ----------------------------------------------------
    // เพิ่มตัวแปร Demo สำหรับ Checkbox และ Slider
    // ----------------------------------------------------
    static bool demo_checkbox1 = false;
    static bool demo_checkbox2 = false;
    static bool demo_checkbox3 = false;
    static bool demo_checkbox4 = false;
    
    static float demo_slider_float1 = 0.0f;
    static float demo_slider_float2 = 100.0f;
    static int demo_slider_int1 = 0;
    static int demo_slider_int2 = 10;
        
    if (MenDeal == true) {
        [self.view setUserInteractionEnabled:YES];
    } else if (MenDeal == false) {
        [self.view setUserInteractionEnabled:NO];
    }

    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil)
    {
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"ImGui Jane"];

        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();
        

        ImFont* font = ImGui::GetFont();
        font->Scale = 15.f / font->FontSize;

        // ปรับขนาดหน้าต่างเริ่มต้นให้ยาวขึ้นเพื่อรองรับฟังชั่นที่เพิ่มเข้ามาเยอะๆ
        float windowW = 400.0f;
        float windowH = 260.0f;

        if (windowW > io.DisplaySize.x) windowW = io.DisplaySize.x;
        if (windowH > io.DisplaySize.y) windowH = io.DisplaySize.y;

        float x = (io.DisplaySize.x - windowW) * 0.5f;
        float y = (io.DisplaySize.y - windowH) * 0.5f;

        ImGui::SetNextWindowPos(ImVec2(x, y), ImGuiCond_Always);
        ImGui::SetNextWindowSize(ImVec2(windowW, windowH), ImGuiCond_Always);
        
        if (MenDeal == true)
        {
            // 1. ส่ง &MenDeal เพื่อให้ปุ่ม X กลับมาแสดง
            // 2. ใส่ Flag ImGuiWindowFlags_NoResize เพื่อปิดการลากขยายขนาดเมนู
            ImGui::Begin("MGZ Lite (1.2.9CN) - F1X3R", &MenDeal, ImGuiWindowFlags_NoResize);
            
            // ฟังก์ชันเดิมของคุณ
            /*ImGui::Checkbox("Draw Esp", &espEnabled);
            HUDSetESPEnabled(espEnabled);

            ImGui::Separator();*/ // เส้นคั่นแบ่งโซนให้ดูสวยงาม            
            // เพิ่ม Checkbox Demo อีกเยอะๆตามคำขอ
            ImGui::Checkbox("No Skill CD", &demo_checkbox1);
            ImGui::Checkbox("Speed Attack", &demo_checkbox2);
            ImGui::Checkbox("Speed Hack", &demo_checkbox3);
            ImGui::Checkbox("Teleport to Item (Beta)", &demo_checkbox4);

ImGui::Checkbox("Monster Not Attack", &demo_checkbox3);

            /*ImGui::Separator();
            ImGui::Text("--- Demo Sliders ---");*/

            // เพิ่ม Slider Demo สำหรับค่าทศนิยม (Float) และจำนวนเต็ม (Int)
            /*ImGui::SliderFloat("Fly High", &demo_slider_float1, 0.0f, 24.0f, "%.1f");
            ImGui::SliderFloat("Fly Speed", &demo_slider_float2, 1.0f, 7.0f, "%.1f");
            ImGui::SliderInt("Max Distance", &demo_slider_int1, 0, 500);
            ImGui::SliderInt("Line Thickness", &demo_slider_int2, 1, 10);*/

ImGui::Separator();

ImGui::Text("Expiry date: 23-07-2026 19:32:20 (2647128139");

            // [ลบปุ่ม Hide Menu เดิมออกเรียบร้อยแล้ว]

            ImGui::End();
            
            // เช็คเพิ่ม: ถ้าผู้ใช้กดปุ่ม X บนเมนู (ทำให้ MenDeal กลายเป็น false) ให้เรียกซ่อน HUD ด้วย
            if (!MenDeal) {
                HUDHideMenu();
            }
        }

        ImDrawList* draw_list = ImGui::GetBackgroundDrawList();
        (void)draw_list;

        ImGui::Render();
        ImDrawData* draw_data = ImGui::GetDrawData();
        ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
      
        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];

        [commandBuffer presentDrawable:view.currentDrawable];
    }

    [commandBuffer commit];
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size
{
    
}

@end
