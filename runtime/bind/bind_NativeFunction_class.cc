// Copyright (c) 2012, Peter Kümmel
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE

#include <dart_api.h>

#include <cstring>
#include <cstdio>

#include <vector>

//
// Use "NativeWrapperClass" to wrap a simple class with member functions.
//


//------------------------------------------------------------------
// Helper functions
//------------------------------------------------------------------


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
// Class to wrap
//------------------------------------------------------------------

class NumberArray
{
public:
    NumberArray(uint64_t size) { data.resize(size); }
    ~NumberArray() {}

    void setAt(uint64_t index, double value) { data[index] = value; }
    double getAt(uint64_t index) const       { return data[index]; }
    uint64_t getSize() const                 { return data.size(); }

private:
    std::vector<double> data;
};



//------------------------------------------------------------------
// Binding code
//------------------------------------------------------------------

namespace BindNumberArray
{
    void setAt(Dart_NativeArguments args);
    void getAt(Dart_NativeArguments args);
    void getSize(Dart_NativeArguments args);
    void newArray(Dart_NativeArguments args);
    void deleteArray(Dart_NativeArguments args);

    uint64_t toIndex(const Dart_Handle& handle, bool& ok);
    NumberArray* toNumberArray(const Dart_Handle& wrapper);

    Dart_NativeFunction numArrayResolver(Dart_Handle name, int arg_count);
}


//------------------------------------------------------------------
void BindNumberArray::newArray(Dart_NativeArguments args)
{
    Dart_Scope scope;

    Dart_Handle wrapper = Dart_GetNativeArgument(args, 0);
    if (!checkResult(wrapper)) {
        return;
    }

    Dart_Handle argSize = Dart_GetNativeArgument(args, 1);
    if (!Dart_IsInteger(argSize)) {
        return;
    }

    uint64_t arraySize = 0;
    Dart_Handle result = Dart_IntegerToUint64(argSize, &arraySize);
    if (!checkResult(result)) {
        return;
    }

    NumberArray* obj = new NumberArray(arraySize);

    Dart_Handle res = Dart_SetNativeInstanceField(wrapper, 0, reinterpret_cast<intptr_t>(obj));
    if (!checkResult(res)) {
        return;
    }

    Dart_SetReturnValue(args, wrapper);

    printf("NumberArray with size %i created.\n", (int)arraySize);
}


//------------------------------------------------------------------
NumberArray* BindNumberArray::toNumberArray(const Dart_Handle& wrapper)
{
    Dart_Handle lib = Dart_LookupLibrary(Dart_NewString("dart:bind"));
    if (!checkResult(lib)) {
        return 0;
    }

    Dart_Handle cls = Dart_GetClass(lib, Dart_NewString("NumberArrayPointer"));
    if (!checkResult(cls)) {
        return 0;
    }

    // check if NumberArrayPointer
    bool is_instance = false;
    Dart_Handle result = Dart_ObjectIsType(wrapper, cls, &is_instance);
    if (!is_instance || !checkResult(result)) {
        return 0;
    }

    intptr_t ptr = 0;
    result = Dart_GetNativeInstanceField(wrapper, 0, &ptr);
    if (!checkResult(result)) {
        return 0;
    }

    NumberArray* obj = reinterpret_cast<NumberArray*>(ptr);

    return obj;
}


//------------------------------------------------------------------
uint64_t BindNumberArray::toIndex(const Dart_Handle& handle, bool& ok)
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
void BindNumberArray::setAt(Dart_NativeArguments args)
{
    Dart_Scope scope;

    // instance
    NumberArray* obj = toNumberArray(Dart_GetNativeArgument(args, 0));
    if (!obj) {
        return;
    }

    // index
    bool ok;
    uint64_t index = toIndex(Dart_GetNativeArgument(args, 1), ok);
    if (!ok) {
        return;
    }
    if (index >= obj->getSize()) {
        printf("NumberArray::setAt(%i): wrong index.\n", (int)index);
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

    obj->setAt(index, value);

    printf("NumberArray::setAt(%i): %f.\n", (int)index, value);
}


//------------------------------------------------------------------
void BindNumberArray::getAt(Dart_NativeArguments args)
{
    Dart_Scope scope;

    // instance
    NumberArray* obj = toNumberArray(Dart_GetNativeArgument(args, 0));
    if (!obj) {
        return;
    }

    // index
    bool ok;
    uint64_t index = toIndex(Dart_GetNativeArgument(args, 1), ok);
    if (!ok) {
        return;
    }
    if (index >= obj->getSize()) {
        printf("NumberArray::getAt(%i): wrong index.\n", (int)index);
        return;
    }

    double value = obj->getAt(index);
    Dart_SetReturnValue(args, Dart_NewDouble(value));

    printf("NumberArray::getAt(%i): %f.\n", (int)index, value);
}


//------------------------------------------------------------------
void BindNumberArray::getSize(Dart_NativeArguments args)
{
    Dart_Scope scope;

    // instance
    NumberArray* obj = toNumberArray(Dart_GetNativeArgument(args, 0));
    if (!obj) {
        return;
    }

    Dart_SetReturnValue(args, Dart_NewInteger(obj->getSize()));

    printf("NumberArray::getSize: %i.\n", (int)obj->getSize());
}


//------------------------------------------------------------------
void BindNumberArray::deleteArray(Dart_NativeArguments args)
{
    Dart_Scope scope;

    // instance
    NumberArray* obj = toNumberArray(Dart_GetNativeArgument(args, 0));
    if (!obj) {
        return;
    }

    delete obj;

    printf("NumberArray deleted.\n");
}


//------------------------------------------------------------------
Dart_NativeFunction BindNumberArray::numArrayResolver(Dart_Handle name, int arg_count)
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
    } else if (!strcmp(function_name, "deleteArray")) {
        return &deleteArray;
    }

    return 0;
}



//------------------------------------------------------------------
int main()
{
    const char* script =
        "class NumberArray extends NumberArrayPointer                   \n"
        "{                                                              \n"
        "   NumberArray(var size) { newNumberArray(size); }             \n"
        "   newNumberArray(var size)     native \"newArray\";           \n"
        "   setAt(var index, var value)      native \"setAt\";          \n"
        "   getAt(var index)                 native \"getAt\";          \n"
        "   getSize()                        native \"getSize\";        \n"
        "   deleteArray()                    native \"deleteArray\";    \n"
        "                                                               \n"
        "   static foo() {                                              \n"
        "       NumberArray array = new NumberArray(12);                \n"
        "       var index = 11;                                         \n"
        "       array.setAt(index, 1.5);                                \n"
        "       array.setAt(13, 1.5);                                   \n"
        "       var d = array.getAt(index);                             \n"
        "       var size = array.getSize();                             \n"
        "       array.setAt(0, 1.0 * size);                             \n"
        "       array.deleteArray(); // no destructor?                  \n"
        "   }                                                           \n"
        "}                                                              \n"
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
    Dart_Handle url = Dart_NewString("dart:bind");
    Dart_Handle source = Dart_NewString(script);
    Dart_Handle lib = Dart_LoadScript(url, source, library_handler);
    if (!checkResult(lib)) {
        return 30;
    }

    if (!Dart_IsLibrary(lib)) {
        return 40;
    }

    Dart_Handle cls = Dart_CreateNativeWrapperClass(lib, Dart_NewString("NumberArrayPointer"), 1);
    if (!checkResult(cls)) {
        return 45;
    }

    Dart_Handle result = Dart_SetNativeResolver(lib, &BindNumberArray::numArrayResolver);
    if (!checkResult(result)) {
        return 50;
    }

    result = Dart_InvokeStatic(lib,
                                Dart_NewString("NumberArray"),
                                Dart_NewString("foo"),
                                0,
                                NULL);

    if (!checkResult(result)) {
        return 60;
    }


    return 0;
}



