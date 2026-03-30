// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:measure_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.Launching lib\main.dart on Windows in debug mode...
    // Building Windows application...
    // lib/main.dart(2,8): error G4D3F0F07: Dart library 'dart:html' is not available on this platform. [C:\Users\vanve\StudioProjects\measure_app\build\windows\x64\flutter\flutter_assemble.vcxproj]
    // C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Microsoft\VC\v160\Microsoft.CppCommon.targets(241,5): error MSB8066: Custom build for 'C:\Users\vanve\StudioProjects\measure_app\build\windows\x64\CMakeFiles\40fdb968b1a013697aee8bdec47bb864\flutter_windows.dll.rule;C:\Users\vanve\StudioProjects\measure_app\build\windows\x64\CMakeFiles\4e506e893d7b63672b8bafc8877f536b\flutter_assemble.rule' exited with code 1. [C:\Users\vanve\StudioProjects\measure_app\build\windows\x64\flutter\flutter_assemble.vcxproj]
    // Error: Build process failed.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
