// Copyright (c) 2011, Peter Kümmel
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE

#include <dart_api.h>

#include <cstring>
#include <cstdio>


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
int main()
{
    const char* script =

"#import('dart:io'); \n"

"class FileHandler { \n"
"  FileHandler() { \n"
"  \n"
"  } \n"
"  void onRequest(HttpRequest request, HttpResponse response, [String fileName = null]){ \n"
" \n"
"    final int BUFFER_SIZE = 4096; \n"
"    if (fileName == null) { \n"
"      fileName = request.path.substring(1); \n"
"    } \n"
"    File file = new File(fileName); \n"
"    if (file.existsSync()) { \n"
"      String mimeType = \"text/html; charset=UTF-8\"; \n"
"      int lastDot = fileName.lastIndexOf(\".\", fileName.length); \n"
"      if (lastDot != -1) { \n"
"        String extension = fileName.substring(lastDot); \n"
"        if (extension == \".css\") { mimeType = \"text/css\"; } \n"
"        if (extension == \".js\")  { mimeType = \"application/javascript\"; } \n"
"        if (extension == \".ico\") { mimeType = \"image/vnd.microsoft.icon\"; } \n"
"        if (extension == \".png\") { mimeType = \"image/png\"; } \n"
"      } \n"
"      response.headers.set(\"Content-Type\", mimeType); \n"
"      // Get the length of the file for setting the Content-Length header. \n"
"      RandomAccessFile openedFile = file.openSync(); \n"
"      response.contentLength = openedFile.lengthSync(); \n"
"      openedFile.closeSync(); \n"
"      // Pipe the file content into the response. \n"
"      file.openInputStream().pipe(response.outputStream); \n"
"    } else { \n"
"      print(\"File not found: $fileName\"); \n"
"      new NotFoundHandler().onRequest(request, response); \n"
"    } \n"
"  } \n"
"} \n"


"class NotFoundHandler { \n"
"  NotFoundHandler(){ \n"
"  } \n"
"  List<int> _notFoundPage; \n"
"  static final String notFoundPageHtml = \"\"\" \n"
"<html><head> \n"
"<title>404 Not Found</title> \n"
"</head><body> \n"
"<h1>Not Found</h1> \n"
"<p>The requested URL was not found on this server.</p> \n"
"</body></html>\"\"\"; \n"
"  void onRequest(HttpRequest request, HttpResponse response){ \n"
" \n"
"    if (_notFoundPage == null) { \n"
"      _notFoundPage = notFoundPageHtml.charCodes(); \n"
"    } \n"
"    response.statusCode = HttpStatus.NOT_FOUND; \n"
"    response.headers.set(\"Content-Type\", \"text/html; charset=UTF-8\"); \n"
"    response.contentLength = _notFoundPage.length; \n"
"    response.outputStream.write(_notFoundPage); \n"
"    response.outputStream.close(); \n"
"  } \n"
"} \n"


"void main() { \n"
"    FileHandler fileHandler = new FileHandler(); \n"
"    HttpServer httpServer = new HttpServer(); \n"
"    httpServer.addRequestHandler((req) => req.path == \"/\", (req,resp) => \n"
"    fileHandler.onRequest(req,resp,'static/index.html'));  \n"
"    httpServer.listen('127.0.0.1', 3000);  \n"
"    } \n";


    if (!Dart_SetVMFlags(0, 0)) {
        return 10;
    }

    if (!Dart_Initialize(0, 0, 0)) {
        return 20;
    }

    // create an isolate
    char* err;
    Dart_Isolate isolate = Dart_CreateIsolate(0, 0, 0, 0, &err);
    if (isolate == 0) {
        return 21;
    }
    Dart_Scope isolate_scope;

    // Load
    Dart_Handle url = Dart_NewString("minimal_http_server");
    Dart_Handle source = Dart_NewString(script);
    //Dart_Handle import_map = Dart_NewList(0);
    Dart_SetLibraryTagHandler(library_handler);
    Dart_Handle lib = Dart_LoadScript(url, source);
    if (!checkResult(lib)) {
        return 30;
    }

    if (!Dart_IsLibrary(lib)) {
        return 40;
    }

    Dart_Handle result = Dart_Invoke(lib,
                         Dart_NewString("main"),
                         0,
                         NULL);

    if (!checkResult(result)) {
        return 60;
    }

    return 0;
}



