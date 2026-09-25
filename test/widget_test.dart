// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll gestures.
// You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:ai_hustle_os/main.dart';
import 'package:ai_hustle_os/core/di/service_locator.dart';

void main() {
  // Set up service locator before running tests
  setUp(() async {
    // Initialize service locator with mock implementations for testing
    await ServiceLocator.setup();
  });

  testWidgets('App loads and shows splash screen then redirects to login', (WidgetTester tester) async {
    print('=== STARTING TEST ===');

    // Build our app
    print('Building app...');
    await tester.pumpWidget(const AIHustleOSApp());
    print('App built');

    // Wait for the splash screen to appear (should be visible immediately)
    print('Pumping...');
    await tester.pump();
    print('Pumped');

    // Verify we see the splash screen content
    print('Checking for splash screen text...');
    final appTitleFinder = find.text('AI HustleOS');
    final appSubtitleFinder = find.text('Your AI-powered business manager');

    print('App title finder: $appTitleFinder');
    print('App subtitle finder: $appSubtitleFinder');

    expect(appTitleFinder, findsOneWidget, reason: 'Should find app title');
    expect(appSubtitleFinder, findsOneWidget, reason: 'Should find app subtitle');
    print('Splash screen text verified');

    // Debug: Let's see what text we have after seeing splash screen
    print('Getting all text after splash screen verification:');
    final textFinders = find.textContaining('');
    final textElements = textFinders.evaluate();
    for (final element in textElements) {
      if (element.widget is Text) {
        final textWidget = element.widget as Text;
        print('Text: "${textWidget.data}"');
      }
    }

    // Wait for the splash screen delay (2 seconds) and then some more time for navigation
    print('Waiting for splash screen delay and navigation...');
    await tester.pumpAndSettle(const Duration(seconds: 5));
    print('Done waiting');

    // Debug: Let's see what text we have after the delay
    print('Getting all text after delay:');
    final textFindersAfterDelay = find.textContaining('');
    final textElementsAfterDelay = textFindersAfterDelay.evaluate();
    for (final element in textElementsAfterDelay) {
      if (element.widget is Text) {
        final textWidget = element.widget as Text;
        print('Text: "${textWidget.data}"');
      }
    }

    // After the delay, we should be redirected to login page since we're not logged in
    print('Checking for login page text...');
    final welcomeBackFinder = find.text('Welcome Back');
    final signInFinder = find.text('Sign in to continue to AI HustleOS');

    print('Welcome back finder: $welcomeBackFinder');
    print('Sign in finder: $signInFinder');

    expect(welcomeBackFinder, findsOneWidget, reason: 'Should find welcome text after redirect');
    expect(signInFinder, findsOneWidget, reason: 'Should find sign-in text after redirect');
    print('Login page text verified');

    print('=== TEST COMPLETED SUCCESSFULLY ===');
  });
}