library indexed_db;

import 'dart:async';
import 'dart:html';
import 'dart:html_common';
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// DO NOT EDIT
// Auto-generated dart:svg library.





class _KeyRangeFactoryProvider {

  static KeyRange createKeyRange_only(/*Key*/ value) =>
      _only(_class(), _translateKey(value));

  static KeyRange createKeyRange_lowerBound(
      /*Key*/ bound, [bool open = false]) =>
      _lowerBound(_class(), _translateKey(bound), open);

  static KeyRange createKeyRange_upperBound(
      /*Key*/ bound, [bool open = false]) =>
      _upperBound(_class(), _translateKey(bound), open);

  static KeyRange createKeyRange_bound(/*Key*/ lower, /*Key*/ upper,
      [bool lowerOpen = false, bool upperOpen = false]) =>
      _bound(_class(), _translateKey(lower), _translateKey(upper),
             lowerOpen, upperOpen);

  static var _cachedClass;

  static _class() {
    if (_cachedClass != null) return _cachedClass;
    return _cachedClass = _uncachedClass();
  }

  static _uncachedClass() =>
    JS('var',
       '''window.webkitIDBKeyRange || window.mozIDBKeyRange ||
          window.msIDBKeyRange || window.IDBKeyRange''');

  static _translateKey(idbkey) => idbkey;  // TODO: fixme.

  static KeyRange _only(cls, value) =>
       JS('KeyRange', '#.only(#)', cls, value);

  static KeyRange _lowerBound(cls, bound, open) =>
       JS('KeyRange', '#.lowerBound(#, #)', cls, bound, open);

  static KeyRange _upperBound(cls, bound, open) =>
       JS('KeyRange', '#.upperBound(#, #)', cls, bound, open);

  static KeyRange _bound(cls, lower, upper, lowerOpen, upperOpen) =>
       JS('KeyRange', '#.bound(#, #, #, #)',
          cls, lower, upper, lowerOpen, upperOpen);
}

// Conversions for IDBKey.
//
// Per http://www.w3.org/TR/IndexedDB/#key-construct
//
// "A value is said to be a valid key if it is one of the following types: Array
// JavaScript objects [ECMA-262], DOMString [WEBIDL], Date [ECMA-262] or float
// [WEBIDL]. However Arrays are only valid keys if every item in the array is
// defined and is a valid key (i.e. sparse arrays can not be valid keys) and if
// the Array doesn't directly or indirectly contain itself. Any non-numeric
// properties are ignored, and thus does not affect whether the Array is a valid
// key. Additionally, if the value is of type float, it is only a valid key if
// it is not NaN, and if the value is of type Date it is only a valid key if its
// [[PrimitiveValue]] internal property, as defined by [ECMA-262], is not NaN."

// What is required is to ensure that an Lists in the key are actually
// JavaScript arrays, and any Dates are JavaScript Dates.


/**
 * Converts a native IDBKey into a Dart object.
 *
 * May return the original input.  May mutate the original input (but will be
 * idempotent if mutation occurs).  It is assumed that this conversion happens
 * on native IDBKeys on all paths that return IDBKeys from native DOM calls.
 *
 * If necessary, JavaScript Dates are converted into Dart Dates.
 */
_convertNativeToDart_IDBKey(nativeKey) {
  containsDate(object) {
    if (isJavaScriptDate(object)) return true;
    if (object is List) {
      for (int i = 0; i < object.length; i++) {
        if (containsDate(object[i])) return true;
      }
    }
    return false;  // number, string.
  }
  if (containsDate(nativeKey)) {
    throw new UnimplementedError('Key containing Date');
  }
  // TODO: Cache conversion somewhere?
  return nativeKey;
}

/**
 * Converts a Dart object into a valid IDBKey.
 *
 * May return the original input.  Does not mutate input.
 *
 * If necessary, [dartKey] may be copied to ensure all lists are converted into
 * JavaScript Arrays and Dart Dates into JavaScript Dates.
 */
_convertDartToNative_IDBKey(dartKey) {
  // TODO: Implement.
  return dartKey;
}



/// May modify original.  If so, action is idempotent.
_convertNativeToDart_IDBAny(object) {
  return convertNativeToDart_AcceptStructuredClone(object, mustCopy: false);
}


const String _idbKey = '=List|=Object|num|String';  // TODO(sra): Add Date.
const _annotation_Creates_IDBKey = const Creates(_idbKey);
const _annotation_Returns_IDBKey = const Returns(_idbKey);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/// @docsEditable true
@DomName('IDBCursor')
class Cursor native "*IDBCursor" {

  /// @docsEditable true
  @DomName('IDBCursor.direction')
  final String direction;

  /// @docsEditable true
  @DomName('IDBCursor.key') @_annotation_Creates_IDBKey @_annotation_Returns_IDBKey
  final Object key;

  /// @docsEditable true
  @DomName('IDBCursor.primaryKey')
  final Object primaryKey;

  /// @docsEditable true
  @DomName('IDBCursor.source')
  final dynamic source;

  /// @docsEditable true
  @DomName('IDBCursor.advance')
  void advance(int count) native;

  /// @docsEditable true
  void continueFunction([/*IDBKey*/ key]) {
    if (?key) {
      var key_1 = _convertDartToNative_IDBKey(key);
      _continueFunction_1(key_1);
      return;
    }
    _continueFunction_2();
    return;
  }
  @JSName('continue')
  @DomName('IDBCursor.continue')
  void _continueFunction_1(key) native;
  @JSName('continue')
  @DomName('IDBCursor.continue')
  void _continueFunction_2() native;

  /// @docsEditable true
  @DomName('IDBCursor.delete')
  Request delete() native;

  /// @docsEditable true
  Request update(/*any*/ value) {
    var value_1 = convertDartToNative_SerializedScriptValue(value);
    return _update_1(value_1);
  }
  @JSName('update')
  @DomName('IDBCursor.update')
  Request _update_1(value) native;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/// @docsEditable true
@DomName('IDBCursorWithValue')
class CursorWithValue extends Cursor native "*IDBCursorWithValue" {

  /// @docsEditable true
  @DomName('IDBCursorWithValue.value') @annotation_Creates_SerializedScriptValue @annotation_Returns_SerializedScriptValue
  final Object value;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('IDBDatabase')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX, '15')
@SupportedBrowser(SupportedBrowser.IE, '10')
@Experimental()
class Database extends EventTarget native "*IDBDatabase" {

  Transaction transaction(storeName_OR_storeNames, String mode) {
    if (mode != 'readonly' && mode != 'readwrite') {
      throw new ArgumentError(mode);
    }

    // TODO(sra): Ensure storeName_OR_storeNames is a string or List<String>,
    // and copy to JavaScript array if necessary.

    // Try and create a transaction with a string mode.  Browsers that expect a
    // numeric mode tend to convert the string into a number.  This fails
    // silently, resulting in zero ('readonly').
    return _transaction(storeName_OR_storeNames, mode);
  }

  @JSName('transaction')
  Transaction _transaction(stores, mode) native;


  static const EventStreamProvider<Event> abortEvent = const EventStreamProvider<Event>('abort');

  static const EventStreamProvider<Event> errorEvent = const EventStreamProvider<Event>('error');

  static const EventStreamProvider<UpgradeNeededEvent> versionChangeEvent = const EventStreamProvider<UpgradeNeededEvent>('versionchange');

  /// @docsEditable true
  @DomName('EventTarget.addEventListener, EventTarget.removeEventListener, EventTarget.dispatchEvent')
  DatabaseEvents get on =>
    new DatabaseEvents(this);

  /// @docsEditable true
  @DomName('IDBDatabase.name')
  final String name;

  /// @docsEditable true
  @DomName('IDBDatabase.objectStoreNames')
  @Returns('DomStringList') @Creates('DomStringList')
  final List<String> objectStoreNames;

  /// @docsEditable true
  @DomName('IDBDatabase.version')
  final dynamic version;

  /// @docsEditable true
  @JSName('addEventListener')
  @DomName('IDBDatabase.addEventListener')
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native;

  /// @docsEditable true
  @DomName('IDBDatabase.close')
  void close() native;

  /// @docsEditable true
  ObjectStore createObjectStore(String name, [Map options]) {
    if (?options) {
      var options_1 = convertDartToNative_Dictionary(options);
      return _createObjectStore_1(name, options_1);
    }
    return _createObjectStore_2(name);
  }
  @JSName('createObjectStore')
  @DomName('IDBDatabase.createObjectStore')
  ObjectStore _createObjectStore_1(name, options) native;
  @JSName('createObjectStore')
  @DomName('IDBDatabase.createObjectStore')
  ObjectStore _createObjectStore_2(name) native;

  /// @docsEditable true
  @DomName('IDBDatabase.deleteObjectStore')
  void deleteObjectStore(String name) native;

  /// @docsEditable true
  @JSName('dispatchEvent')
  @DomName('IDBDatabase.dispatchEvent')
  bool $dom_dispatchEvent(Event evt) native;

  /// @docsEditable true
  @JSName('removeEventListener')
  @DomName('IDBDatabase.removeEventListener')
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native;

  Stream<Event> get onAbort => abortEvent.forTarget(this);

  Stream<Event> get onError => errorEvent.forTarget(this);

  Stream<UpgradeNeededEvent> get onVersionChange => versionChangeEvent.forTarget(this);
}

/// @docsEditable true
class DatabaseEvents extends Events {
  /// @docsEditable true
  DatabaseEvents(EventTarget _ptr) : super(_ptr);

  /// @docsEditable true
  EventListenerList get abort => this['abort'];

  /// @docsEditable true
  EventListenerList get error => this['error'];

  /// @docsEditable true
  EventListenerList get versionChange => this['versionchange'];
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('IDBFactory')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX, '15')
@SupportedBrowser(SupportedBrowser.IE, '10')
@Experimental()
class IdbFactory native "*IDBFactory" {
  /**
   * Checks to see if Indexed DB is supported on the current platform.
   */
  static bool get supported {
    return JS('bool',
        '!!(window.indexedDB || '
        'window.webkitIndexedDB || '
        'window.mozIndexedDB)');
  }


  /// @docsEditable true
  int cmp(/*IDBKey*/ first, /*IDBKey*/ second) {
    var first_1 = _convertDartToNative_IDBKey(first);
    var second_2 = _convertDartToNative_IDBKey(second);
    return _cmp_1(first_1, second_2);
  }
  @JSName('cmp')
  @DomName('IDBFactory.cmp')
  int _cmp_1(first, second) native;

  /// @docsEditable true
  @DomName('IDBFactory.deleteDatabase')
  VersionChangeRequest deleteDatabase(String name) native;

  /// @docsEditable true
  @DomName('IDBFactory.open') @Returns('Request') @Creates('Request') @Creates('Database')
  OpenDBRequest open(String name, [int version]) native;

  /// @docsEditable true
  @DomName('IDBFactory.webkitGetDatabaseNames')
  Request webkitGetDatabaseNames() native;

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/// @docsEditable true
@DomName('IDBIndex')
class Index native "*IDBIndex" {

  /// @docsEditable true
  @DomName('IDBIndex.keyPath')
  final dynamic keyPath;

  /// @docsEditable true
  @DomName('IDBIndex.multiEntry')
  final bool multiEntry;

  /// @docsEditable true
  @DomName('IDBIndex.name')
  final String name;

  /// @docsEditable true
  @DomName('IDBIndex.objectStore')
  final ObjectStore objectStore;

  /// @docsEditable true
  @DomName('IDBIndex.unique')
  final bool unique;

  /// @docsEditable true
  Request count([key_OR_range]) {
    if (!?key_OR_range) {
      return _count_1();
    }
    if ((key_OR_range is KeyRange || key_OR_range == null)) {
      return _count_2(key_OR_range);
    }
    if (?key_OR_range) {
      var key_1 = _convertDartToNative_IDBKey(key_OR_range);
      return _count_3(key_1);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }
  @JSName('count')
  @DomName('IDBIndex.count')
  Request _count_1() native;
  @JSName('count')
  @DomName('IDBIndex.count')
  Request _count_2(KeyRange range) native;
  @JSName('count')
  @DomName('IDBIndex.count')
  Request _count_3(key) native;

  /// @docsEditable true
  Request get(key) {
    if ((key is KeyRange || key == null)) {
      return _get_1(key);
    }
    if (?key) {
      var key_1 = _convertDartToNative_IDBKey(key);
      return _get_2(key_1);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }
  @JSName('get')
  @DomName('IDBIndex.get') @Returns('Request') @Creates('Request') @annotation_Creates_SerializedScriptValue
  Request _get_1(KeyRange key) native;
  @JSName('get')
  @DomName('IDBIndex.get') @Returns('Request') @Creates('Request') @annotation_Creates_SerializedScriptValue
  Request _get_2(key) native;

  /// @docsEditable true
  Request getKey(key) {
    if ((key is KeyRange || key == null)) {
      return _getKey_1(key);
    }
    if (?key) {
      var key_1 = _convertDartToNative_IDBKey(key);
      return _getKey_2(key_1);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }
  @JSName('getKey')
  @DomName('IDBIndex.getKey') @Returns('Request') @Creates('Request') @annotation_Creates_SerializedScriptValue @Creates('ObjectStore')
  Request _getKey_1(KeyRange key) native;
  @JSName('getKey')
  @DomName('IDBIndex.getKey') @Returns('Request') @Creates('Request') @annotation_Creates_SerializedScriptValue @Creates('ObjectStore')
  Request _getKey_2(key) native;

  /// @docsEditable true
  Request openCursor([key_OR_range, String direction]) {
    if (!?key_OR_range &&
        !?direction) {
      return _openCursor_1();
    }
    if ((key_OR_range is KeyRange || key_OR_range == null) &&
        !?direction) {
      return _openCursor_2(key_OR_range);
    }
    if ((key_OR_range is KeyRange || key_OR_range == null)) {
      return _openCursor_3(key_OR_range, direction);
    }
    if (?key_OR_range &&
        !?direction) {
      var key_1 = _convertDartToNative_IDBKey(key_OR_range);
      return _openCursor_4(key_1);
    }
    if (?key_OR_range) {
      var key_2 = _convertDartToNative_IDBKey(key_OR_range);
      return _openCursor_5(key_2, direction);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }
  @JSName('openCursor')
  @DomName('IDBIndex.openCursor') @Returns('Request') @Creates('Request') @Creates('Cursor')
  Request _openCursor_1() native;
  @JSName('openCursor')
  @DomName('IDBIndex.openCursor') @Returns('Request') @Creates('Request') @Creates('Cursor')
  Request _openCursor_2(KeyRange range) native;
  @JSName('openCursor')
  @DomName('IDBIndex.openCursor') @Returns('Request') @Creates('Request') @Creates('Cursor')
  Request _openCursor_3(KeyRange range, direction) native;
  @JSName('openCursor')
  @DomName('IDBIndex.openCursor') @Returns('Request') @Creates('Request') @Creates('Cursor')
  Request _openCursor_4(key) native;
  @JSName('openCursor')
  @DomName('IDBIndex.openCursor') @Returns('Request') @Creates('Request') @Creates('Cursor')
  Request _openCursor_5(key, direction) native;

  /// @docsEditable true
  Request openKeyCursor([key_OR_range, String direction]) {
    if (!?key_OR_range &&
        !?direction) {
      return _openKeyCursor_1();
    }
    if ((key_OR_range is KeyRange || key_OR_range == null) &&
        !?direction) {
      return _openKeyCursor_2(key_OR_range);
    }
    if ((key_OR_range is KeyRange || key_OR_range == null)) {
      return _openKeyCursor_3(key_OR_range, direction);
    }
    if (?key_OR_range &&
        !?direction) {
      var key_1 = _convertDartToNative_IDBKey(key_OR_range);
      return _openKeyCursor_4(key_1);
    }
    if (?key_OR_range) {
      var key_2 = _convertDartToNative_IDBKey(key_OR_range);
      return _openKeyCursor_5(key_2, direction);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }
  @JSName('openKeyCursor')
  @DomName('IDBIndex.openKeyCursor') @Returns('Request') @Creates('Request') @Creates('Cursor')
  Request _openKeyCursor_1() native;
  @JSName('openKeyCursor')
  @DomName('IDBIndex.openKeyCursor') @Returns('Request') @Creates('Request') @Creates('Cursor')
  Request _openKeyCursor_2(KeyRange range) native;
  @JSName('openKeyCursor')
  @DomName('IDBIndex.openKeyCursor') @Returns('Request') @Creates('Request') @Creates('Cursor')
  Request _openKeyCursor_3(KeyRange range, direction) native;
  @JSName('openKeyCursor')
  @DomName('IDBIndex.openKeyCursor') @Returns('Request') @Creates('Request') @Creates('Cursor')
  Request _openKeyCursor_4(key) native;
  @JSName('openKeyCursor')
  @DomName('IDBIndex.openKeyCursor') @Returns('Request') @Creates('Request') @Creates('Cursor')
  Request _openKeyCursor_5(key, direction) native;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/// @docsEditable true
@DomName('IDBKey')
class Key native "*IDBKey" {
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('IDBKeyRange')
class KeyRange native "*IDBKeyRange" {
  @DomName('IDBKeyRange.only')
  factory KeyRange.only(/*Key*/ value) =>
      _KeyRangeFactoryProvider.createKeyRange_only(value);

  @DomName('IDBKeyRange.lowerBound')
  factory KeyRange.lowerBound(/*Key*/ bound, [bool open = false]) =>
      _KeyRangeFactoryProvider.createKeyRange_lowerBound(bound, open);

  @DomName('IDBKeyRange.upperBound')
  factory KeyRange.upperBound(/*Key*/ bound, [bool open = false]) =>
      _KeyRangeFactoryProvider.createKeyRange_upperBound(bound, open);

  @DomName('KeyRange.bound')
  factory KeyRange.bound(/*Key*/ lower, /*Key*/ upper,
                            [bool lowerOpen = false, bool upperOpen = false]) =>
      _KeyRangeFactoryProvider.createKeyRange_bound(
          lower, upper, lowerOpen, upperOpen);


  /// @docsEditable true
  dynamic get lower => _convertNativeToDart_IDBKey(this._lower);
  @JSName('lower')
  @DomName('IDBKeyRange.lower')
  final dynamic _lower;

  /// @docsEditable true
  @DomName('IDBKeyRange.lowerOpen')
  final bool lowerOpen;

  /// @docsEditable true
  dynamic get upper => _convertNativeToDart_IDBKey(this._upper);
  @JSName('upper')
  @DomName('IDBKeyRange.upper')
  final dynamic _upper;

  /// @docsEditable true
  @DomName('IDBKeyRange.upperOpen')
  final bool upperOpen;

  /// @docsEditable true
  static KeyRange bound_(/*IDBKey*/ lower, /*IDBKey*/ upper, [bool lowerOpen, bool upperOpen]) {
    if (?upperOpen) {
      var lower_1 = _convertDartToNative_IDBKey(lower);
      var upper_2 = _convertDartToNative_IDBKey(upper);
      return _bound__1(lower_1, upper_2, lowerOpen, upperOpen);
    }
    if (?lowerOpen) {
      var lower_3 = _convertDartToNative_IDBKey(lower);
      var upper_4 = _convertDartToNative_IDBKey(upper);
      return _bound__2(lower_3, upper_4, lowerOpen);
    }
    var lower_5 = _convertDartToNative_IDBKey(lower);
    var upper_6 = _convertDartToNative_IDBKey(upper);
    return _bound__3(lower_5, upper_6);
  }
  @JSName('bound')
  @DomName('IDBKeyRange.bound')
  static KeyRange _bound__1(lower, upper, lowerOpen, upperOpen) native;
  @JSName('bound')
  @DomName('IDBKeyRange.bound')
  static KeyRange _bound__2(lower, upper, lowerOpen) native;
  @JSName('bound')
  @DomName('IDBKeyRange.bound')
  static KeyRange _bound__3(lower, upper) native;

  /// @docsEditable true
  static KeyRange lowerBound_(/*IDBKey*/ bound, [bool open]) {
    if (?open) {
      var bound_1 = _convertDartToNative_IDBKey(bound);
      return _lowerBound__1(bound_1, open);
    }
    var bound_2 = _convertDartToNative_IDBKey(bound);
    return _lowerBound__2(bound_2);
  }
  @JSName('lowerBound')
  @DomName('IDBKeyRange.lowerBound')
  static KeyRange _lowerBound__1(bound, open) native;
  @JSName('lowerBound')
  @DomName('IDBKeyRange.lowerBound')
  static KeyRange _lowerBound__2(bound) native;

  /// @docsEditable true
  static KeyRange only_(/*IDBKey*/ value) {
    var value_1 = _convertDartToNative_IDBKey(value);
    return _only__1(value_1);
  }
  @JSName('only')
  @DomName('IDBKeyRange.only')
  static KeyRange _only__1(value) native;

  /// @docsEditable true
  static KeyRange upperBound_(/*IDBKey*/ bound, [bool open]) {
    if (?open) {
      var bound_1 = _convertDartToNative_IDBKey(bound);
      return _upperBound__1(bound_1, open);
    }
    var bound_2 = _convertDartToNative_IDBKey(bound);
    return _upperBound__2(bound_2);
  }
  @JSName('upperBound')
  @DomName('IDBKeyRange.upperBound')
  static KeyRange _upperBound__1(bound, open) native;
  @JSName('upperBound')
  @DomName('IDBKeyRange.upperBound')
  static KeyRange _upperBound__2(bound) native;

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/// @docsEditable true
@DomName('IDBObjectStore')
class ObjectStore native "*IDBObjectStore" {

  /// @docsEditable true
  @DomName('IDBObjectStore.autoIncrement')
  final bool autoIncrement;

  /// @docsEditable true
  @DomName('IDBObjectStore.indexNames')
  @Returns('DomStringList') @Creates('DomStringList')
  final List<String> indexNames;

  /// @docsEditable true
  @DomName('IDBObjectStore.keyPath')
  final dynamic keyPath;

  /// @docsEditable true
  @DomName('IDBObjectStore.name')
  final String name;

  /// @docsEditable true
  @DomName('IDBObjectStore.transaction')
  final Transaction transaction;

  /// @docsEditable true
  Request add(/*any*/ value, [/*IDBKey*/ key]) {
    if (?key) {
      var value_1 = convertDartToNative_SerializedScriptValue(value);
      var key_2 = _convertDartToNative_IDBKey(key);
      return _add_1(value_1, key_2);
    }
    var value_3 = convertDartToNative_SerializedScriptValue(value);
    return _add_2(value_3);
  }
  @JSName('add')
  @DomName('IDBObjectStore.add') @Returns('Request') @Creates('Request') @_annotation_Creates_IDBKey
  Request _add_1(value, key) native;
  @JSName('add')
  @DomName('IDBObjectStore.add') @Returns('Request') @Creates('Request') @_annotation_Creates_IDBKey
  Request _add_2(value) native;

  /// @docsEditable true
  @DomName('IDBObjectStore.clear')
  Request clear() native;

  /// @docsEditable true
  Request count([key_OR_range]) {
    if (!?key_OR_range) {
      return _count_1();
    }
    if ((key_OR_range is KeyRange || key_OR_range == null)) {
      return _count_2(key_OR_range);
    }
    if (?key_OR_range) {
      var key_1 = _convertDartToNative_IDBKey(key_OR_range);
      return _count_3(key_1);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }
  @JSName('count')
  @DomName('IDBObjectStore.count')
  Request _count_1() native;
  @JSName('count')
  @DomName('IDBObjectStore.count')
  Request _count_2(KeyRange range) native;
  @JSName('count')
  @DomName('IDBObjectStore.count')
  Request _count_3(key) native;

  /// @docsEditable true
  Index createIndex(String name, keyPath, [Map options]) {
    if ((keyPath is List<String> || keyPath == null) &&
        !?options) {
      return _createIndex_1(name, keyPath);
    }
    if ((keyPath is List<String> || keyPath == null)) {
      var options_1 = convertDartToNative_Dictionary(options);
      return _createIndex_2(name, keyPath, options_1);
    }
    if ((keyPath is String || keyPath == null) &&
        !?options) {
      return _createIndex_3(name, keyPath);
    }
    if ((keyPath is String || keyPath == null)) {
      var options_2 = convertDartToNative_Dictionary(options);
      return _createIndex_4(name, keyPath, options_2);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }
  @JSName('createIndex')
  @DomName('IDBObjectStore.createIndex')
  Index _createIndex_1(name, List<String> keyPath) native;
  @JSName('createIndex')
  @DomName('IDBObjectStore.createIndex')
  Index _createIndex_2(name, List<String> keyPath, options) native;
  @JSName('createIndex')
  @DomName('IDBObjectStore.createIndex')
  Index _createIndex_3(name, String keyPath) native;
  @JSName('createIndex')
  @DomName('IDBObjectStore.createIndex')
  Index _createIndex_4(name, String keyPath, options) native;

  /// @docsEditable true
  Request delete(key_OR_keyRange) {
    if ((key_OR_keyRange is KeyRange || key_OR_keyRange == null)) {
      return _delete_1(key_OR_keyRange);
    }
    if (?key_OR_keyRange) {
      var key_1 = _convertDartToNative_IDBKey(key_OR_keyRange);
      return _delete_2(key_1);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }
  @JSName('delete')
  @DomName('IDBObjectStore.delete')
  Request _delete_1(KeyRange keyRange) native;
  @JSName('delete')
  @DomName('IDBObjectStore.delete')
  Request _delete_2(key) native;

  /// @docsEditable true
  @DomName('IDBObjectStore.deleteIndex')
  void deleteIndex(String name) native;

  /// @docsEditable true
  Request getObject(key) {
    if ((key is KeyRange || key == null)) {
      return _getObject_1(key);
    }
    if (?key) {
      var key_1 = _convertDartToNative_IDBKey(key);
      return _getObject_2(key_1);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }
  @JSName('get')
  @DomName('IDBObjectStore.get') @Returns('Request') @Creates('Request') @annotation_Creates_SerializedScriptValue
  Request _getObject_1(KeyRange key) native;
  @JSName('get')
  @DomName('IDBObjectStore.get') @Returns('Request') @Creates('Request') @annotation_Creates_SerializedScriptValue
  Request _getObject_2(key) native;

  /// @docsEditable true
  @DomName('IDBObjectStore.index')
  Index index(String name) native;

  /// @docsEditable true
  Request openCursor([key_OR_range, String direction]) {
    if (!?key_OR_range &&
        !?direction) {
      return _openCursor_1();
    }
    if ((key_OR_range is KeyRange || key_OR_range == null) &&
        !?direction) {
      return _openCursor_2(key_OR_range);
    }
    if ((key_OR_range is KeyRange || key_OR_range == null)) {
      return _openCursor_3(key_OR_range, direction);
    }
    if (?key_OR_range &&
        !?direction) {
      var key_1 = _convertDartToNative_IDBKey(key_OR_range);
      return _openCursor_4(key_1);
    }
    if (?key_OR_range) {
      var key_2 = _convertDartToNative_IDBKey(key_OR_range);
      return _openCursor_5(key_2, direction);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }
  @JSName('openCursor')
  @DomName('IDBObjectStore.openCursor') @Returns('Request') @Creates('Request') @Creates('Cursor')
  Request _openCursor_1() native;
  @JSName('openCursor')
  @DomName('IDBObjectStore.openCursor') @Returns('Request') @Creates('Request') @Creates('Cursor')
  Request _openCursor_2(KeyRange range) native;
  @JSName('openCursor')
  @DomName('IDBObjectStore.openCursor') @Returns('Request') @Creates('Request') @Creates('Cursor')
  Request _openCursor_3(KeyRange range, direction) native;
  @JSName('openCursor')
  @DomName('IDBObjectStore.openCursor') @Returns('Request') @Creates('Request') @Creates('Cursor')
  Request _openCursor_4(key) native;
  @JSName('openCursor')
  @DomName('IDBObjectStore.openCursor') @Returns('Request') @Creates('Request') @Creates('Cursor')
  Request _openCursor_5(key, direction) native;

  /// @docsEditable true
  Request put(/*any*/ value, [/*IDBKey*/ key]) {
    if (?key) {
      var value_1 = convertDartToNative_SerializedScriptValue(value);
      var key_2 = _convertDartToNative_IDBKey(key);
      return _put_1(value_1, key_2);
    }
    var value_3 = convertDartToNative_SerializedScriptValue(value);
    return _put_2(value_3);
  }
  @JSName('put')
  @DomName('IDBObjectStore.put') @Returns('Request') @Creates('Request') @_annotation_Creates_IDBKey
  Request _put_1(value, key) native;
  @JSName('put')
  @DomName('IDBObjectStore.put') @Returns('Request') @Creates('Request') @_annotation_Creates_IDBKey
  Request _put_2(value) native;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/// @docsEditable true
@DomName('IDBOpenDBRequest')
class OpenDBRequest extends Request implements EventTarget native "*IDBOpenDBRequest" {

  static const EventStreamProvider<Event> blockedEvent = const EventStreamProvider<Event>('blocked');

  static const EventStreamProvider<VersionChangeEvent> upgradeNeededEvent = const EventStreamProvider<VersionChangeEvent>('upgradeneeded');

  /// @docsEditable true
  @DomName('EventTarget.addEventListener, EventTarget.removeEventListener, EventTarget.dispatchEvent')
  OpenDBRequestEvents get on =>
    new OpenDBRequestEvents(this);

  Stream<Event> get onBlocked => blockedEvent.forTarget(this);

  Stream<VersionChangeEvent> get onUpgradeNeeded => upgradeNeededEvent.forTarget(this);
}

/// @docsEditable true
class OpenDBRequestEvents extends RequestEvents {
  /// @docsEditable true
  OpenDBRequestEvents(EventTarget _ptr) : super(_ptr);

  /// @docsEditable true
  EventListenerList get blocked => this['blocked'];

  /// @docsEditable true
  EventListenerList get upgradeNeeded => this['upgradeneeded'];
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/// @docsEditable true
@DomName('IDBRequest')
class Request extends EventTarget native "*IDBRequest" {

  static const EventStreamProvider<Event> errorEvent = const EventStreamProvider<Event>('error');

  static const EventStreamProvider<Event> successEvent = const EventStreamProvider<Event>('success');

  /// @docsEditable true
  @DomName('EventTarget.addEventListener, EventTarget.removeEventListener, EventTarget.dispatchEvent')
  RequestEvents get on =>
    new RequestEvents(this);

  /// @docsEditable true
  @DomName('IDBRequest.error')
  final DomError error;

  /// @docsEditable true
  @DomName('IDBRequest.readyState')
  final String readyState;

  /// @docsEditable true
  dynamic get result => _convertNativeToDart_IDBAny(this._result);
  @JSName('result')
  @DomName('IDBRequest.result') @Creates('Null')
  final dynamic _result;

  /// @docsEditable true
  @DomName('IDBRequest.source') @Creates('Null')
  final dynamic source;

  /// @docsEditable true
  @DomName('IDBRequest.transaction')
  final Transaction transaction;

  /// @docsEditable true
  @DomName('IDBRequest.webkitErrorMessage')
  final String webkitErrorMessage;

  /// @docsEditable true
  @JSName('addEventListener')
  @DomName('IDBRequest.addEventListener')
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native;

  /// @docsEditable true
  @JSName('dispatchEvent')
  @DomName('IDBRequest.dispatchEvent')
  bool $dom_dispatchEvent(Event evt) native;

  /// @docsEditable true
  @JSName('removeEventListener')
  @DomName('IDBRequest.removeEventListener')
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native;

  Stream<Event> get onError => errorEvent.forTarget(this);

  Stream<Event> get onSuccess => successEvent.forTarget(this);
}

/// @docsEditable true
class RequestEvents extends Events {
  /// @docsEditable true
  RequestEvents(EventTarget _ptr) : super(_ptr);

  /// @docsEditable true
  EventListenerList get error => this['error'];

  /// @docsEditable true
  EventListenerList get success => this['success'];
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/// @docsEditable true
@DomName('IDBTransaction')
class Transaction extends EventTarget native "*IDBTransaction" {

  static const EventStreamProvider<Event> abortEvent = const EventStreamProvider<Event>('abort');

  static const EventStreamProvider<Event> completeEvent = const EventStreamProvider<Event>('complete');

  static const EventStreamProvider<Event> errorEvent = const EventStreamProvider<Event>('error');

  /// @docsEditable true
  @DomName('EventTarget.addEventListener, EventTarget.removeEventListener, EventTarget.dispatchEvent')
  TransactionEvents get on =>
    new TransactionEvents(this);

  /// @docsEditable true
  @DomName('IDBTransaction.db')
  final Database db;

  /// @docsEditable true
  @DomName('IDBTransaction.error')
  final DomError error;

  /// @docsEditable true
  @DomName('IDBTransaction.mode')
  final String mode;

  /// @docsEditable true
  @DomName('IDBTransaction.webkitErrorMessage')
  final String webkitErrorMessage;

  /// @docsEditable true
  @DomName('IDBTransaction.abort')
  void abort() native;

  /// @docsEditable true
  @JSName('addEventListener')
  @DomName('IDBTransaction.addEventListener')
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native;

  /// @docsEditable true
  @JSName('dispatchEvent')
  @DomName('IDBTransaction.dispatchEvent')
  bool $dom_dispatchEvent(Event evt) native;

  /// @docsEditable true
  @DomName('IDBTransaction.objectStore')
  ObjectStore objectStore(String name) native;

  /// @docsEditable true
  @JSName('removeEventListener')
  @DomName('IDBTransaction.removeEventListener')
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native;

  Stream<Event> get onAbort => abortEvent.forTarget(this);

  Stream<Event> get onComplete => completeEvent.forTarget(this);

  Stream<Event> get onError => errorEvent.forTarget(this);
}

/// @docsEditable true
class TransactionEvents extends Events {
  /// @docsEditable true
  TransactionEvents(EventTarget _ptr) : super(_ptr);

  /// @docsEditable true
  EventListenerList get abort => this['abort'];

  /// @docsEditable true
  EventListenerList get complete => this['complete'];

  /// @docsEditable true
  EventListenerList get error => this['error'];
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/// @docsEditable true
@DomName('IDBVersionChangeEvent')
class UpgradeNeededEvent extends Event native "*IDBVersionChangeEvent" {

  /// @docsEditable true
  @DomName('IDBUpgradeNeededEvent.newVersion')
  final int newVersion;

  /// @docsEditable true
  @DomName('IDBUpgradeNeededEvent.oldVersion')
  final int oldVersion;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/// @docsEditable true
@DomName('IDBVersionChangeEvent')
class VersionChangeEvent extends Event native "*IDBVersionChangeEvent" {

  /// @docsEditable true
  @DomName('IDBVersionChangeEvent.version')
  final String version;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/// @docsEditable true
@DomName('IDBVersionChangeRequest')
class VersionChangeRequest extends Request implements EventTarget native "*IDBVersionChangeRequest" {

  static const EventStreamProvider<Event> blockedEvent = const EventStreamProvider<Event>('blocked');

  /// @docsEditable true
  @DomName('EventTarget.addEventListener, EventTarget.removeEventListener, EventTarget.dispatchEvent')
  VersionChangeRequestEvents get on =>
    new VersionChangeRequestEvents(this);

  Stream<Event> get onBlocked => blockedEvent.forTarget(this);
}

/// @docsEditable true
class VersionChangeRequestEvents extends RequestEvents {
  /// @docsEditable true
  VersionChangeRequestEvents(EventTarget _ptr) : super(_ptr);

  /// @docsEditable true
  EventListenerList get blocked => this['blocked'];
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/// @docsEditable true
@DomName('IDBAny')
class _Any native "*IDBAny" {
}
