//
//  MBLog.h
//  StratPad
//
//  Created by Julian Wood on 10-08-31.
//  Copyright 2010 Mobilesce Inc. All rights reserved.
//
// TRACE = 0
// DEBUG = 1
// INFO = 2
// WARN = 3
// ERROR = 4
//
// eg. if MB_LOG_LEVEL == 1, then only messages to debug (ie DLog) and higher will get printed
//
// MB_LOG_LEVEL is a User Defined Setting in the StratPad target, with differing values for debug, release
// That setting is picked up by the info.plist on preprocess, with a key of MBLogLevel
// That key is picked up by the app delegate from the infodictionary, and used to set the log level in the macro
// Allows us to change the value not only from a build setting, but also at runtime

extern int MB_LOG_LEVEL;