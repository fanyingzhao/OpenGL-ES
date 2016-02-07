//
//  FYUncaughtExceptionHandler.m
//  闪退
//
//  Created by mac on 15/10/20.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "FYUncaughtExceptionHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

static NSDateFormatter* formatter;

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

void handleException(NSException *exception);

@implementation FYUncaughtExceptionHandler

+ (void)load
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    signal(SIGHUP, signalHandler);
    signal(SIGINT, signalHandler);
    signal(SIGQUIT, signalHandler);
    signal(SIGABRT, signalHandler);
    signal(SIGILL, signalHandler);
    signal(SIGSEGV, signalHandler);
    signal(SIGFPE, signalHandler);
    signal(SIGBUS, signalHandler);
    signal(SIGPIPE, signalHandler);
    
    NSString* direction = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Crash"];
    [FYUncaughtExceptionHandler createDirectionWithUrl:direction];
}

void uncaughtExceptionHandler(NSException *exception)

{
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH-mm-ss"];
    
    // 异常的堆栈信息
    NSArray *stackArray = [exception callStackSymbols];
    
    // 出现异常的原因
    NSString *reason = [exception reason];
    
    // 异常名称
    NSString *name = [exception name];
    
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception reason：%@\nException name：%@\nException stack：%@",name, reason, stackArray];
    
    NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:stackArray];
    
    [tmpArr insertObject:reason atIndex:0];
    
    
    [exceptionInfo writeToFile:[FYUncaughtExceptionHandler crashDirector] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

void signalHandler(int signal)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSMutableDictionary *userInfo =
    [NSMutableDictionary
     dictionaryWithObject:[NSNumber numberWithInt:signal]
     forKey:UncaughtExceptionHandlerSignalKey];
    
    NSArray *callStack = [FYUncaughtExceptionHandler backtrace];
    [userInfo
     setObject:callStack
     forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[FYUncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:) withObject:[NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName reason:[NSString stringWithFormat:NSLocalizedString(@"Signal %d was raised.", nil),signal]
      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey]] waitUntilDone:YES];
    
    [userInfo  setObject:callStack  forKey:UncaughtExceptionHandlerAddressesKey];
}

+ (NSArray *)backtrace
{
    void* callstack[128];
    
    int frames = backtrace(callstack, 128);
    
    char **strs = backtrace_symbols(callstack,frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    
    for (int i=0;i<frames;i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    
    free(strs);

    return backtrace;
}

- (void)handleException:(NSException*)exception
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSArray *callStack = [FYUncaughtExceptionHandler backtrace];
    NSMutableDictionary *userInfo =
    [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo
     setObject:callStack
     forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[FYUncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException
      exceptionWithName:[exception name]
      reason:[exception reason]
      userInfo:userInfo]
     waitUntilDone:YES];
}

#pragma mark - helper
+ (NSString*)crashDirector
{
    NSBundle* bundle = [NSBundle mainBundle];
    NSDictionary* info = [bundle infoDictionary];
    NSString* prodName = [info objectForKey:@"CFBundleName"];
    
    NSString* date = [FYUncaughtExceptionHandler currentTime];
    NSString* time = [[date componentsSeparatedByString:@" "] lastObject];
    
    NSArray* timeArray = [time componentsSeparatedByString:@"-"];
    NSString* hour = [timeArray firstObject];
    NSString* min = [timeArray objectAtIndex:1];
    NSString* sec = [timeArray lastObject];
    NSString* resTime = [NSString stringWithFormat:@"%@h %@m %@s",hour,min,sec];
    
    return [NSString stringWithFormat:@"%@/%@(%@).txt",[FYUncaughtExceptionHandler createCurrentDateDirection],prodName,resTime];
}

+ (NSString*)createCurrentDateDirection
{
    NSString* cash = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Crash"];
    
    NSString* date = [FYUncaughtExceptionHandler currentTime];
    NSString* currentDate = [FYUncaughtExceptionHandler currentDate:date];
    NSString* direction = [cash stringByAppendingString:[NSString stringWithFormat:@"/%@",currentDate]];
    
    [FYUncaughtExceptionHandler createDirectionWithUrl:direction];
    
    return direction;
}

+ (NSString*)currentDate:(NSString*)date
{
    if ([FYUncaughtExceptionHandler checkStringIsValid:date]) {
        
        NSArray* array = [date componentsSeparatedByString:@" "];
        return [array firstObject];
    }
    
    return nil;
}

+ (BOOL)checkStringIsValid:(NSString*)string
{
    return ((nil == string) || [string isEqual:[NSNull null]] || [string isEqualToString:@"(null)"] || [string isEqualToString:@""])?nil:string;
}

+ (void)createDirectionWithUrl:(NSString*)urlString
{
    NSFileManager* file = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL result = [file fileExistsAtPath:urlString isDirectory:&isDir];
    
    if (!(isDir && result)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:urlString withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (NSString*)currentTime
{
    return [formatter stringFromDate:[NSDate date]];
}
@end
