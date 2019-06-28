#if TARGET_OS_SIMULATOR
@interface UIKeyboardTaskQueue : NSObject
/*
 Hint for key typing:  https://github.com/wix/Detox/pull/1480/files
 Maybe, if we do not need FB keyboard or can replave it with official APIs, we can re-implement them as this way.
 */

- (void)performTask:(void (^)(id ctx))arg1;
- (void)waitUntilAllTasksAreFinished;
@end

/**
 * iOS-Runtime-Headers/PrivateFrameworks/UIKitCore.framework/UIKeyboardImpl.h
 */
@interface UIKeyboardImpl
+ (instancetype)sharedInstance;
/**
 * Modify software keyboard condition on simulators for over Xcode 6
 * This setting is global. The change applies to all instances of UIKeyboardImpl.
 *
 * Idea: https://chromium.googlesource.com/chromium/src/base/+/ababb4cf8b6049a642a2f361b1006a07561c2d96/test/test_support_ios.mm#41
 *
 * @param enabled Whether turn setAutomaticMinimizationEnabled on
 */
- (void)setAutomaticMinimizationEnabled:(BOOL)enabled;


/*
 Hint for key typing:  https://github.com/wix/Detox/pull/1480/files
 Maybe, if we do not need FB keyboard or can replave it with official APIs, we can re-implement them as this way.
 */
@property(readonly, nonatomic) UIKeyboardTaskQueue *taskQueue;
- (void)handleKeyWithString:(id)arg1 forKeyEvent:(id)arg2 executionContext:(id)arg3;
- (void)setShift:(_Bool)arg1 autoshift:(_Bool)arg2;
@end

#endif  // TARGET_IPHONE_SIMULATOR
