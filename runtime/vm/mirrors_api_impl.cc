// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/dart_mirrors_api.h"

#include "platform/assert.h"
#include "vm/class_finalizer.h"
#include "vm/dart.h"
#include "vm/dart_api_impl.h"
#include "vm/dart_api_state.h"
#include "vm/dart_entry.h"
#include "vm/exceptions.h"
#include "vm/growable_array.h"
#include "vm/object.h"
#include "vm/resolver.h"
#include "vm/stack_frame.h"
#include "vm/symbols.h"

namespace dart {


// --- Classes and Interfaces Reflection ---

DART_EXPORT Dart_Handle Dart_TypeName(Dart_Handle object) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(object));
  if (obj.IsType()) {
    const Class& cls = Class::Handle(Type::Cast(obj).type_class());
    return Api::NewHandle(isolate, cls.UserVisibleName());
  } else {
    RETURN_TYPE_ERROR(isolate, object, Class/Type);
  }
}


DART_EXPORT Dart_Handle Dart_QualifiedTypeName(Dart_Handle object) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(object));
  if (obj.IsType() || obj.IsClass()) {
    const Class& cls = (obj.IsType()) ?
        Class::Handle(Type::Cast(obj).type_class()) : Class::Cast(obj);
    return Dart_NewStringFromCString(cls.ToCString());
  } else {
    RETURN_TYPE_ERROR(isolate, object, Class/Type);
  }
}


// --- Function and Variable Reflection ---

// Outside of the vm, we expose setter names with a trailing '='.
static bool HasExternalSetterSuffix(const String& name) {
  return name.CharAt(name.Length() - 1) == '=';
}


static RawString* RemoveExternalSetterSuffix(const String& name) {
  ASSERT(HasExternalSetterSuffix(name));
  return String::SubString(name, 0, name.Length() - 1);
}


DART_EXPORT Dart_Handle Dart_GetFunctionNames(Dart_Handle target) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(target));
  if (obj.IsError()) {
    return target;
  }

  const GrowableObjectArray& names =
      GrowableObjectArray::Handle(isolate, GrowableObjectArray::New());
  Function& func = Function::Handle();
  String& name = String::Handle();

  if (obj.IsType()) {
    const Class& cls = Class::Handle(Type::Cast(obj).type_class());
    const Error& error = Error::Handle(isolate, cls.EnsureIsFinalized(isolate));
    if (!error.IsNull()) {
      return Api::NewHandle(isolate, error.raw());
    }
    const Array& func_array = Array::Handle(cls.functions());

    // Some special types like 'dynamic' have a null functions list.
    if (!func_array.IsNull()) {
      for (intptr_t i = 0; i < func_array.Length(); ++i) {
        func ^= func_array.At(i);

        // Skip implicit getters and setters.
        if (func.kind() == RawFunction::kImplicitGetter ||
            func.kind() == RawFunction::kImplicitSetter ||
            func.kind() == RawFunction::kImplicitStaticFinalGetter ||
            func.kind() == RawFunction::kStaticInitializer ||
            func.kind() == RawFunction::kMethodExtractor ||
            func.kind() == RawFunction::kNoSuchMethodDispatcher) {
          continue;
        }

        name = func.UserVisibleName();
        names.Add(name);
      }
    }
  } else if (obj.IsLibrary()) {
    const Library& lib = Library::Cast(obj);
    DictionaryIterator it(lib);
    Object& obj = Object::Handle();
    while (it.HasNext()) {
      obj = it.GetNext();
      if (obj.IsFunction()) {
        func ^= obj.raw();
        name = func.UserVisibleName();
        names.Add(name);
      }
    }
  } else {
    return Api::NewError(
        "%s expects argument 'target' to be a class or library.",
        CURRENT_FUNC);
  }
  return Api::NewHandle(isolate, Array::MakeArray(names));
}


DART_EXPORT Dart_Handle Dart_LookupFunction(Dart_Handle target,
                                            Dart_Handle function_name) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(target));
  if (obj.IsError()) {
    return target;
  }
  const String& func_name = Api::UnwrapStringHandle(isolate, function_name);
  if (func_name.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function_name, String);
  }

  Function& func = Function::Handle(isolate);
  String& tmp_name = String::Handle(isolate);
  if (obj.IsType()) {
    const Class& cls = Class::Handle(Type::Cast(obj).type_class());

    // Case 1.  Lookup the unmodified function name.
    func = cls.LookupFunctionAllowPrivate(func_name);

    // Case 2.  Lookup the function without the external setter suffix
    // '='.  Make sure to do this check after the regular lookup, so
    // that we don't interfere with operator lookups (like ==).
    if (func.IsNull() && HasExternalSetterSuffix(func_name)) {
      tmp_name = RemoveExternalSetterSuffix(func_name);
      tmp_name = Field::SetterName(tmp_name);
      func = cls.LookupFunctionAllowPrivate(tmp_name);
    }

    // Case 3.  Lookup the funciton with the getter prefix prepended.
    if (func.IsNull()) {
      tmp_name = Field::GetterName(func_name);
      func = cls.LookupFunctionAllowPrivate(tmp_name);
    }

    // Case 4.  Lookup the function with a . appended to find the
    // unnamed constructor.
    if (func.IsNull()) {
      tmp_name = String::Concat(func_name, Symbols::Dot());
      func = cls.LookupFunctionAllowPrivate(tmp_name);
    }
  } else if (obj.IsLibrary()) {
    const Library& lib = Library::Cast(obj);

    // Case 1.  Lookup the unmodified function name.
    func = lib.LookupFunctionAllowPrivate(func_name);

    // Case 2.  Lookup the function without the external setter suffix
    // '='.  Make sure to do this check after the regular lookup, so
    // that we don't interfere with operator lookups (like ==).
    if (func.IsNull() && HasExternalSetterSuffix(func_name)) {
      tmp_name = RemoveExternalSetterSuffix(func_name);
      tmp_name = Field::SetterName(tmp_name);
      func = lib.LookupFunctionAllowPrivate(tmp_name);
    }

    // Case 3.  Lookup the function with the getter prefix prepended.
    if (func.IsNull()) {
      tmp_name = Field::GetterName(func_name);
      func = lib.LookupFunctionAllowPrivate(tmp_name);
    }
  } else {
    return Api::NewError(
        "%s expects argument 'target' to be a class or library.",
        CURRENT_FUNC);
  }

#if defined(DEBUG)
  if (!func.IsNull()) {
    // We only provide access to a subset of function kinds.
    RawFunction::Kind func_kind = func.kind();
    ASSERT(func_kind == RawFunction::kRegularFunction ||
           func_kind == RawFunction::kGetterFunction ||
           func_kind == RawFunction::kSetterFunction ||
           func_kind == RawFunction::kConstructor);
  }
#endif
  return Api::NewHandle(isolate, func.raw());
}


DART_EXPORT Dart_Handle Dart_FunctionName(Dart_Handle function) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Function& func = Api::UnwrapFunctionHandle(isolate, function);
  if (func.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function, Function);
  }
  return Api::NewHandle(isolate, func.UserVisibleName());
}


DART_EXPORT Dart_Handle Dart_FunctionOwner(Dart_Handle function) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Function& func = Api::UnwrapFunctionHandle(isolate, function);
  if (func.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function, Function);
  }
  if (func.IsNonImplicitClosureFunction()) {
    RawFunction* parent_function = func.parent_function();
    return Api::NewHandle(isolate, parent_function);
  }
  const Class& owner = Class::Handle(func.Owner());
  ASSERT(!owner.IsNull());
  if (owner.IsTopLevel()) {
    // Top-level functions are implemented as members of a hidden class. We hide
    // that class here and instead answer the library.
#if defined(DEBUG)
    const Library& lib = Library::Handle(owner.library());
    if (lib.IsNull()) {
      ASSERT(owner.IsDynamicClass() || owner.IsVoidClass());
    }
#endif
    return Api::NewHandle(isolate, owner.library());
  } else {
    return Api::NewHandle(isolate, owner.RareType());
  }
}


DART_EXPORT Dart_Handle Dart_FunctionIsStatic(Dart_Handle function,
                                              bool* is_static) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (is_static == NULL) {
    RETURN_NULL_ERROR(is_static);
  }
  const Function& func = Api::UnwrapFunctionHandle(isolate, function);
  if (func.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function, Function);
  }
  *is_static = func.is_static();
  return Api::Success();
}


DART_EXPORT Dart_Handle Dart_FunctionIsConstructor(Dart_Handle function,
                                                   bool* is_constructor) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (is_constructor == NULL) {
    RETURN_NULL_ERROR(is_constructor);
  }
  const Function& func = Api::UnwrapFunctionHandle(isolate, function);
  if (func.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function, Function);
  }
  *is_constructor = func.kind() == RawFunction::kConstructor;
  return Api::Success();
}


DART_EXPORT Dart_Handle Dart_FunctionIsGetter(Dart_Handle function,
                                              bool* is_getter) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (is_getter == NULL) {
    RETURN_NULL_ERROR(is_getter);
  }
  const Function& func = Api::UnwrapFunctionHandle(isolate, function);
  if (func.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function, Function);
  }
  *is_getter = func.IsGetterFunction();
  return Api::Success();
}


DART_EXPORT Dart_Handle Dart_FunctionIsSetter(Dart_Handle function,
                                              bool* is_setter) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (is_setter == NULL) {
    RETURN_NULL_ERROR(is_setter);
  }
  const Function& func = Api::UnwrapFunctionHandle(isolate, function);
  if (func.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function, Function);
  }
  *is_setter = (func.kind() == RawFunction::kSetterFunction);
  return Api::Success();
}


// --- Libraries Reflection ---

DART_EXPORT Dart_Handle Dart_LibraryName(Dart_Handle library) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Library& lib = Api::UnwrapLibraryHandle(isolate, library);
  if (lib.IsNull()) {
    RETURN_TYPE_ERROR(isolate, library, Library);
  }
  const String& name = String::Handle(isolate, lib.name());
  ASSERT(!name.IsNull());
  return Api::NewHandle(isolate, name.raw());
}

DART_EXPORT Dart_Handle Dart_LibraryGetClassNames(Dart_Handle library) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Library& lib = Api::UnwrapLibraryHandle(isolate, library);
  if (lib.IsNull()) {
    RETURN_TYPE_ERROR(isolate, library, Library);
  }

  const GrowableObjectArray& names =
      GrowableObjectArray::Handle(isolate, GrowableObjectArray::New());
  ClassDictionaryIterator it(lib);
  Class& cls = Class::Handle();
  String& name = String::Handle();
  while (it.HasNext()) {
    cls = it.GetNextClass();
    if (cls.IsSignatureClass()) {
      if (!cls.IsCanonicalSignatureClass()) {
        // This is a typedef.  Add it to the list of class names.
        name = cls.UserVisibleName();
        names.Add(name);
      } else {
        // Skip canonical signature classes.  These are not named.
      }
    } else {
      name = cls.UserVisibleName();
      names.Add(name);
    }
  }
  return Api::NewHandle(isolate, Array::MakeArray(names));
}


// --- Closures Reflection ---

DART_EXPORT Dart_Handle Dart_ClosureFunction(Dart_Handle closure) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Instance& closure_obj = Api::UnwrapInstanceHandle(isolate, closure);
  if (closure_obj.IsNull() || !closure_obj.IsClosure()) {
    RETURN_TYPE_ERROR(isolate, closure, Instance);
  }

  ASSERT(ClassFinalizer::AllClassesFinalized());

  RawFunction* rf = Closure::function(closure_obj);
  return Api::NewHandle(isolate, rf);
}

}  // namespace dart
