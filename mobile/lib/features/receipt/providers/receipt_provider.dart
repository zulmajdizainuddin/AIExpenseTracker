import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/receipt_repository.dart';
import '../models/receipt_model.dart';

typedef ScanResult = ({ReceiptModel receipt, AiReceiptData aiData});

final scanReceiptProvider = AsyncNotifierProvider<ScanReceiptNotifier, ScanResult?>(
  ScanReceiptNotifier.new,
);

class ScanReceiptNotifier extends AsyncNotifier<ScanResult?> {
  @override
  Future<ScanResult?> build() async => null;

  Future<void> scan(File imageFile) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(receiptRepositoryProvider).scanReceipt(imageFile),
    );
  }

  void reset() => state = const AsyncData(null);
}
