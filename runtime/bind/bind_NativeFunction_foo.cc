// Copyright (c) 2011, Peter Kümmel
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE

#include <dart_api.h>

#include <cstring>
#include <cstdio>


//------------------------------------------------------------------
void foo(Dart_NativeArguments args)
{
    printf("Hello embedded world\n");
}


//------------------------------------------------------------------
struct Dart_Scope
{
    Dart_Scope()  { Dart_EnterScope(); }
    ~Dart_Scope() { Dart_ExitScope(); }
};


//------------------------------------------------------------------
bool checkResult(const Dart_Handle& result)
{
    if (Dart_IsError(result)) {
        printf("-- Error: %s\n", Dart_GetError(result));
        return false;
    }
    return true;
}



//------------------------------------------------------------------
static Dart_Handle libraryHandler(Dart_LibraryTag tag,
                                  Dart_Handle library,
                                  Dart_Handle url)
{
  if (tag == kCanonicalizeUrl) {
    return url;
  }
  return Dart_True() ; //???
}



//------------------------------------------------------------------
static Dart_NativeFunction resolveFoo(Dart_Handle name, int arg_count)
{
    return &foo;
}


//------------------------------------------------------------------
int main()
{
    const char* script =
        "class Foo "
        "{"
        "  static function() native \"foo\";  "
        "}"
        ;


    if (!Dart_SetVMFlags(0, 0)) {
        return 10;
    }

    if (!Dart_Initialize(0, 0)) {
        return 20;
    }

    // create an isolate
    char* err;
    Dart_Isolate isolate = Dart_CreateIsolate(0, 0, &err);
    if (isolate == 0) {
        return 21;
    }
    Dart_Scope isolate_scope;

    // Load
    Dart_Handle url = Dart_NewString("dart:test");
    Dart_Handle source = Dart_NewString(script);
    Dart_Handle lib = Dart_LoadScript(url, source, libraryHandler);
    if (!checkResult(lib)) {
        return 30;
    }

    if (!Dart_IsLibrary(lib)) {
        return 40;
    }

    Dart_Handle result = Dart_SetNativeResolver(lib, &resolveFoo);
    if (!checkResult(result)) {
        return 50;
    }

    result = Dart_InvokeStatic(lib,
                                Dart_NewString("Foo"),
                                Dart_NewString("function"),
                                0,
                                NULL);

    if (!checkResult(result)) {
        return 60;
    }

    return 0;
}



