// windows/runner/main.cpp

#include "flutter_window.h"
#include "utils.h"

#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <iostream>

#include <flutter/standard_method_codec.h>
#include <flutter/method_channel.h>

using namespace flutter;

void RegisterCameraPlugin(BinaryMessenger* messenger) {
  auto channel = std::make_unique<MethodChannel<EncodableValue>>(
    messenger, "camera_plugin",
    &StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
    [](const MethodCall<EncodableValue>& call, std::unique_ptr<MethodResult<EncodableValue>> result) {
      if (call.method_name().compare("hasCamera") == 0) {
        // Add your logic to check if camera is available
        result->Success(EncodableValue(true));
      } else if (call.method_name().compare("captureImage") == 0) {
        // Add your code to capture an image using Windows API
        // For example, you might use Media Foundation APIs here
        // Return the path to the captured image or error
        result->Success(EncodableValue("path/to/captured/image.jpg"));
      } else {
        result->NotImplemented();
      }
    });
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev, _In_ wchar_t* command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM libraries
  CoInitializeEx(nullptr, COINIT_MULTITHREADED);

  // Create the Flutter window
  FlutterWindow window(instance);
  window.SetQuitOnClose(true);

  RegisterCameraPlugin(window.GetPlatformMessenger());

  // Run the message loop
  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  // Uninitialize COM libraries
  CoUninitialize();
  return EXIT_SUCCESS;
}
