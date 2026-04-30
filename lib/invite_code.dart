import 'dart:math';

/// Short, human-friendly invite codes (avoid ambiguous characters).
String generateInviteCode({int length = 8}) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rnd = Random.secure();
  return List.generate(length, (_) => chars[rnd.nextInt(chars.length)]).join();
}
