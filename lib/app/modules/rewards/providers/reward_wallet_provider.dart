import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RewardEntry {
  const RewardEntry({required this.points, required this.date});

  final int points;
  final DateTime date;

  Map<String, Object> toJson() => {
    'points': points,
    'date': date.toIso8601String(),
  };

  factory RewardEntry.fromJson(Map<String, dynamic> json) => RewardEntry(
    points: (json['points'] as num).toInt(),
    date: DateTime.parse(json['date'] as String),
  );
}

class RewardWallet {
  const RewardWallet({this.balance = 0, this.history = const []});

  final int balance;
  final List<RewardEntry> history;

  factory RewardWallet.fromJson(Map<String, dynamic> json) => RewardWallet(
    balance: (json['balance'] as num?)?.toInt() ?? 0,
    history: ((json['history'] as List?) ?? const [])
        .whereType<Map>()
        .map((entry) => RewardEntry.fromJson(Map<String, dynamic>.from(entry)))
        .toList(),
  );

  Map<String, Object> toJson() => {
    'balance': balance,
    'history': history.map((entry) => entry.toJson()).toList(),
  };
}

final rewardWalletProvider =
    AsyncNotifierProvider<RewardWalletNotifier, RewardWallet>(
      RewardWalletNotifier.new,
    );

class RewardWalletNotifier extends AsyncNotifier<RewardWallet> {
  static const _storageKey = 'calendario_reward_wallet_v1';
  late SharedPreferences _preferences;

  @override
  Future<RewardWallet> build() async {
    _preferences = await SharedPreferences.getInstance();
    final raw = _preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const RewardWallet();
    try {
      return RewardWallet.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const RewardWallet();
    }
  }

  Future<void> addPoints(int points) async {
    if (points <= 0) return;
    final current = state.asData?.value ?? await future;
    final next = RewardWallet(
      balance: current.balance + points,
      history: [
        RewardEntry(points: points, date: DateTime.now()),
        ...current.history,
      ].take(100).toList(),
    );
    state = AsyncData(next);
    await _preferences.setString(_storageKey, jsonEncode(next.toJson()));
  }
}
