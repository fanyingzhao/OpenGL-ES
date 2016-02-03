//
//  GLKVC.m
//  纹理
//
//  Created by fanyingzhao on 16/2/1.
//  Copyright © 2016年 fyz. All rights reserved.
//

#import "GLKVC.h"

typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
}SceneVertex;

static SceneVertex vertices[] = {
    {{-0.8f,-0.5f,0.f},{0.0f,0.f}},
    {{0.8f,-0.5f,0.f},{1.0f,0.f}},
    {{-0.8f,0.5f,0.f},{0.0f,1.f}},
    
    {{0.8f,-0.5f,0.f},{1.0f,0.f}},
    {{0.8f,0.5f,0.f},{1.0f,1.0f}},
    {{-0.8f,0.5f,0.0f},{0.0f,1.0f}},
};

static const SceneVertex verticesTwo[] = {
    {{-0.8f,-0.5f,0.f},{0.0f,0.f}},
    {{0.8f,-0.5f,0.f},{1.0f,0.f}},
    {{-0.8f,0.5f,0.f},{0.0f,1.f}},
    
    {{0.8f,-0.5f,0.f},{1.0f,0.f}},
    {{0.8f,0.5f,0.f},{1.0f,1.0f}},
    {{-0.8f,0.5f,0.0f},{0.0f,1.0f}},
};

@interface GLKVC()
{
    GLuint _vertiesBufferID;
    CGFloat _offset;
}
@property (nonatomic, strong) GLKBaseEffect* baseEffect;
@property (nonatomic, strong) UISlider* slider;
@end

@implementation GLKVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self setOpenGL];
    [self.view addSubview:self.slider];
}

- (void)setOpenGL
{
    GLKView* view = (GLKView*)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    
    glClearColor(0.0f, 1.0f, 1.0f, 1.0f);
    
    glGenBuffers(1, &_vertiesBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, _vertiesBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, positionCoords));
    
    CGImageRef image = [UIImage imageNamed:@"test16Png.jpg"].CGImage;
    GLKTextureInfo* texture = [GLKTextureLoader textureWithCGImage:image options:nil error:nil];
    self.baseEffect.texture2d0.name = texture.name;
    self.baseEffect.texture2d0.target = texture.target;
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glTexParameteri(self.baseEffect.texture2d0.target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(self.baseEffect.texture2d0.target, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
    
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, textureCoords));
}

- (void)update
{
    for (int i = 0; i < 6; i ++) {
        vertices[i].textureCoords.s = verticesTwo[i].textureCoords.s + _offset;
    }
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.baseEffect prepareToDraw];
    glClear(GL_COLOR_BUFFER_BIT);
    
    glDrawArrays(GL_TRIANGLES, 0, sizeof(vertices));
}

#pragma mark - event
- (void)sliderChange:(UISlider*)slier
{
//    NSLog(@"%f",slier.value);
    _offset = slier.value;
}

#pragma mark - getter
- (UISlider *)slider
{
    if (!_slider) {
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(50, 440, 200, 100)];
        [_slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _slider;
}

@end
