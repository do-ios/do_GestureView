//
//  do_GestureView_View.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_GestureView_UIView.h"

#import "doInvokeResult.h"
#import "doUIModuleHelper.h"
#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"

@interface do_GestureView_UIView()<UIGestureRecognizerDelegate>

@end

@implementation do_GestureView_UIView{
    UIPanGestureRecognizer *pan;
    UITapGestureRecognizer *tap;
    UISwipeGestureRecognizer *left;
    UISwipeGestureRecognizer *right;
    UISwipeGestureRecognizer *up;
    UISwipeGestureRecognizer *down;
//    UILongPressGestureRecognizer *longPress;
    
    BOOL _isLongTouch;
}
#pragma mark - doIUIModuleView协议方法（必须）
//销毁所有的全局对象
- (void) OnDispose
{
    //自定义的全局属性,view-model(UIModel)类销毁时会递归调用<子view-model(UIModel)>的该方法，将上层的引用切断。所以如果self类有非原生扩展，需主动调用view-model(UIModel)的该方法。(App || Page)-->强引用-->view-model(UIModel)-->强引用-->view
    [self removeGestureRecognizer:pan];
    [self removeGestureRecognizer:tap];
    [self removeGestureRecognizer:left];
    [self removeGestureRecognizer:right];
    [self removeGestureRecognizer:up];
    [self removeGestureRecognizer:down];
//    [self removeGestureRecognizer:longPress];
}
//实现布局
- (void) OnRedraw
{
    //实现布局相关的修改,如果添加了非原生的view需要主动调用该view的OnRedraw，递归完成布局。view(OnRedraw)<显示布局>-->调用-->view-model(UIModel)<OnRedraw>
    
    //重新调整视图的x,y,w,h
    [doUIModuleHelper OnRedraw:_model];
}
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    _model = (typeof(_model)) _doUIModule;
    self.backgroundColor = [UIColor clearColor];
    
    //pan
    pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    pan.delegate = self;
    pan.cancelsTouchesInView = NO;
    //tap
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
    tap.cancelsTouchesInView = NO;

    //swipe
    left = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe: )];
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:left];
    left.delegate = self;
    left.cancelsTouchesInView = NO;

    right = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe: )];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:right];
    right.delegate = self;
    right.cancelsTouchesInView = NO;
    
    up = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe: )];
    up.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:up];
    up.delegate = self;
    up.cancelsTouchesInView = NO;
    
    down = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe: )];
    down.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:down];
    down.delegate = self;
    down.cancelsTouchesInView = NO;
    //longPress
//    longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
}
#pragma mark -私有方法

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(point.x/_model.XZoom) forKey:@"x"];
    [dict setObject:@(point.y/_model.YZoom) forKey:@"y"];
    doInvokeResult *invokeResult = [[doInvokeResult alloc]init];
    [invokeResult SetResultNode:dict];
    
    [self performSelector:@selector(longPress:) withObject:invokeResult afterDelay:.5];
    
    [_model.EventCenter FireEvent:@"touchDown" :invokeResult];
}
//- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self];
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setObject:@(point.x/_model.XZoom) forKey:@"x"];
//    [dict setObject:@(point.y/_model.YZoom) forKey:@"y"];
//    doInvokeResult *invokeResult = [[doInvokeResult alloc]init];
//    [invokeResult SetResultNode:dict];
//    [_model.EventCenter FireEvent:@"cancle" :invokeResult];
//}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _isLongTouch = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(point.x/_model.XZoom) forKey:@"x"];
    [dict setObject:@(point.y/_model.YZoom) forKey:@"y"];
    doInvokeResult *invokeResult = [[doInvokeResult alloc]init];
    [invokeResult SetResultNode:dict];
    [_model.EventCenter FireEvent:@"touchUp" :invokeResult];
}
//拖动
- (void)pan:(UIPanGestureRecognizer *)gesture
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (_isLongTouch) {
        return;
    }
    [self getPointWithGesture:gesture withEventName:@"move"];
}
//点击
- (void)tap:(UITapGestureRecognizer *)gesture
{
    if (_isLongTouch) {
        return;
    }
    [self getPointWithGesture:gesture withEventName:@"touch"];
}
//轻扫
- (void)swipe:(UISwipeGestureRecognizer *)gesture
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (_isLongTouch) {
        return;
    }
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    NSString *directionX = @"0";
    NSString *directionY= @"0";
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionRight:
            directionX = @"1";
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            directionX = @"-1";
            break;
        case UISwipeGestureRecognizerDirectionUp:
            directionY = @"-1";
            break;
        case UISwipeGestureRecognizerDirectionDown:
            directionY = @"1";
            break;
        default:
            break;
    }
    [node setObject:directionX forKey:@"velocityX"];
    [node setObject:directionY forKey:@"velocityY"];
    doInvokeResult *invokeResult = [[doInvokeResult alloc]init];
    [invokeResult SetResultNode:node];
    [_model.EventCenter FireEvent:@"fling" :invokeResult];
}
//长按
- (void)longPress:(doInvokeResult *)p
{
    _isLongTouch = YES;
    [_model.EventCenter FireEvent:@"longTouch" :p];
}


//得到点击的点
- (void) getPointWithGesture:(UIGestureRecognizer *)gesture withEventName:(NSString *)name
{
    CGPoint point = [gesture locationInView:self];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(point.x/_model.XZoom) forKey:@"x"];
    [dict setObject:@(point.y/_model.YZoom) forKey:@"y"];
    doInvokeResult *invokeResult = [[doInvokeResult alloc]init];
    [invokeResult SetResultNode:dict];
    [self fireEvent:name withInvokeResult:invokeResult];
}
//触发事件
- (void)fireEvent:(NSString *)name withInvokeResult:(doInvokeResult *)result;
{
    [_model.EventCenter FireEvent:name :result];
}

#pragma mark -
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] || ![otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}
#pragma mark - TYPEID_IView协议方法（必须）
#pragma mark - Changed_属性
/*
 如果在Model及父类中注册过 "属性"，可用这种方法获取
 NSString *属性名 = [(doUIModule *)_model GetPropertyValue:@"属性名"];
 
 获取属性最初的默认值
 NSString *属性名 = [(doUIModule *)_model GetProperty:@"属性名"].DefaultValue;
 */

#pragma mark - doIUIModuleView协议方法（必须）<大部分情况不需修改>
- (BOOL) OnPropertiesChanging: (NSMutableDictionary *) _changedValues
{
    //属性改变时,返回NO，将不会执行Changed方法
    return YES;
}
- (void) OnPropertiesChanged: (NSMutableDictionary*) _changedValues
{
    //_model的属性进行修改，同时调用self的对应的属性方法，修改视图
    [doUIModuleHelper HandleViewProperChanged: self :_model : _changedValues ];
}
- (BOOL) InvokeSyncMethod: (NSString *) _methodName : (NSDictionary *)_dicParas :(id<doIScriptEngine>)_scriptEngine : (doInvokeResult *) _invokeResult
{
    //同步消息
    return [doScriptEngineHelper InvokeSyncSelector:self : _methodName :_dicParas :_scriptEngine :_invokeResult];
}
- (BOOL) InvokeAsyncMethod: (NSString *) _methodName : (NSDictionary *) _dicParas :(id<doIScriptEngine>) _scriptEngine : (NSString *) _callbackFuncName
{
    //异步消息
    return [doScriptEngineHelper InvokeASyncSelector:self : _methodName :_dicParas :_scriptEngine: _callbackFuncName];
}
- (doUIModule *) GetModel
{
    //获取model对象
    return _model;
}

@end
