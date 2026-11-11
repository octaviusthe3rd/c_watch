import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selected tab of the main shell: 0 = Home, 1 = Reports, 2 = Profile.
final shellIndexProvider = StateProvider<int>((ref) => 0);