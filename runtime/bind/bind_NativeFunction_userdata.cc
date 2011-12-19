// Copyright (c) 2011, Peter Kümmel
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE

#include <dart_api.h>

#include <cstring>
#include <cstdio>


//------------------------------------------------------------------
class NumArray
{
public:
    NumArray() : size(1) {}
    uint64_t size;
    double values[1];

private:
    NumArray(const NumArray&);
    NumArray& operator=(const NumArray&);
};


//------------------------------------------------------------------
static NumArray* lastCreatedArray = 0;


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
void newArray(Dart_NativeArguments args)
{
    Dart_Scope scope;

    Dart_Handle argSize = Dart_GetNativeArgument(args, 0);
    if (!Dart_IsInteger(argSize)) {
        return;
    }

    uint64_t arraySize = 0;
    Dart_Handle result = Dart_IntegerToUint64(argSize, &arraySize);
    if (!checkResult(result)) {
        return;
    }

    uint64_t numberOfBytes = sizeof(NumArray) + (arraySize - 1)*sizeof(double);
    NumArray* numArray = (NumArray *)new char [numberOfBytes];
    lastCreatedArray = numArray;
    numArray->size = arraySize;

    // no userdata in Dart
    //char check_pointer_size[ (sizeof(NumArray*) == sizeof(int) ? 1 : -1) ]; (void)check_pointer_size;
    int64_t ptr = reinterpret_cast<int64_t>(numArray);

    Dart_SetReturnValue(args, Dart_NewInteger(ptr));

    printf("newArray: array of size %i created.\n", (int)arraySize);
}


//------------------------------------------------------------------
NumArray* toNumArray(const Dart_Handle& handle)
{
    if (!Dart_IsInteger(handle)) {
        return 0 ;
    }
    uint64_t ptr = 0;
    Dart_Handle result = Dart_IntegerToUint64(handle, &ptr);
    if (!checkResult(result)) {
        return 0;
    }
    // no userdata in Dart
    NumArray* numArray = reinterpret_cast<NumArray*>(ptr);

    return numArray;
}


//------------------------------------------------------------------
uint64_t toIndex(const Dart_Handle& handle, bool& ok)
{
    if (!Dart_IsInteger(handle)) {
        ok = false;
        return 0;
    }
    uint64_t index = 0;
    Dart_Handle result = Dart_IntegerToUint64(handle, &index);
    if (!checkResult(result)) {
        ok = false;
        return 0 ;
    }

    ok = true;
    return index;
}


//------------------------------------------------------------------
void setAt(Dart_NativeArguments args)
{
    Dart_Scope scope;

    // NumArray
    NumArray* numArray = toNumArray(Dart_GetNativeArgument(args, 0));
    if (!numArray) {
        return;
    }

    // index
    bool ok;
    uint64_t index = toIndex(Dart_GetNativeArgument(args, 1), ok);
    if (!ok) {
        return;
    }

    // value
    Dart_Handle argValue = Dart_GetNativeArgument(args, 2);
    if (!Dart_IsDouble(argValue)) {
        return;
    }
    double value = 0;
    Dart_Handle result = Dart_DoubleValue(argValue, &value);
    if (!checkResult(result)) {
        return;
    }

    numArray->values[index] = value;

    printf("setAt: array->value[%i] = %f.\n", (int)index, value);
}


//------------------------------------------------------------------
static void getAt(Dart_NativeArguments args)
{
    Dart_Scope scope;

    // NumArray
    NumArray* numArray = toNumArray(Dart_GetNativeArgument(args, 0));
    if (!numArray) {
        return;
    }

    // index
    bool ok;
    uint64_t index = toIndex(Dart_GetNativeArgument(args, 1), ok);
    if (!ok) {
        return;
    }

    if (index > numArray->size) {
        return;
    }

    double value = numArray->values[index];
    Dart_SetReturnValue(args, Dart_NewDouble(value));

    printf("getAt: return array->value[%i]  (%f).\n", (int)index, value);
}


//------------------------------------------------------------------
static void getSize(Dart_NativeArguments args)
{
    Dart_Scope scope;

    // NumArray
    NumArray* numArray = toNumArray(Dart_GetNativeArgument(args, 0));
    if (!numArray) {
        return;
    }


    Dart_SetReturnValue(args, Dart_NewInteger(numArray->size));

    printf("getSize: return array->size   (%i).\n", (int)numArray->size);
}


//------------------------------------------------------------------
static Dart_Handle library_handler(Dart_LibraryTag tag,
                                   Dart_Handle library,
                                   Dart_Handle url)
{
  if (tag == kCanonicalizeUrl) {
    return url;
  }
  return Dart_True() ; //???
}


//------------------------------------------------------------------
static Dart_NativeFunction numArrayResolver(Dart_Handle name, int arg_count)
{
    const char* function_name = 0;
    Dart_Handle result = Dart_StringToCString(name, &function_name);
    if (!checkResult(result)) {
        return 0; //??? lets crash
    }

    if (!strcmp(function_name, "newArray")) {
        return &newArray;
    } else if (!strcmp(function_name, "setAt")) {
        return &setAt;
    } else if (!strcmp(function_name, "getAt")) {
        return &getAt;
    } else if (!strcmp(function_name, "getSize")) {
        return &getSize;
    }

    return 0;
}



//------------------------------------------------------------------
int main()
{
    const char* script =
        "class NumArray                                                             \n"
        "{                                                                          \n"
        "   static newArray(var size)                       native \"newArray\";    \n"
        "   static setAt(var array, var index, var value)   native \"setAt\";       \n"
        "   static getAt(var array, var index)              native \"getAt\";       \n"
        "   static getSize(var array)                       native \"getSize\";     \n"
        "                                                                           \n"
        "   static foo() {                                                          \n"
        "       var array = NumArray.newArray(12);                                  \n"
        "       setAt(array, 3, 1.5);                                               \n"
        "       var d = getAt(array, 3);                                            \n"
        "       var size = getSize(array);                                          \n"
        "       setAt(array, 0, 1.0 * size);                                        \n"
        "   }                                                                       \n"
        "}                                                                          \n"
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
    Dart_Handle url = Dart_NewString("dart:bind;");
    Dart_Handle source = Dart_NewString(script);
    Dart_Handle lib = Dart_LoadScript(url, source, library_handler);
    if (!checkResult(lib)) {
        return 30;
    }

    if (!Dart_IsLibrary(lib)) {
        return 40;
    }

    Dart_Handle result = Dart_SetNativeResolver(lib, &numArrayResolver);
    if (!checkResult(result)) {
        return 50;
    }

    result = Dart_InvokeStatic(lib,
                                Dart_NewString("NumArray"),
                                Dart_NewString("foo"),
                                0,
                                NULL);

    if (!checkResult(result)) {
        return 60;
    }

    if (lastCreatedArray) {
      if (lastCreatedArray->values[0] == 12) {
        printf("NumArray successfully manipulated by Dart.\n");
      } else {
        printf("Error when accessing NumArray from Dart.\n");
      }
    }
    return 0;
}



