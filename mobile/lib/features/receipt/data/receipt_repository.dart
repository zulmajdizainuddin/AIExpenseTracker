import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/receipt_model.dart';

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository(ref.watch(dioClientProvider));
});

class ReceiptRepository {
  ReceiptRepository(this._client);
  final DioClient _client;

  Future<({ReceiptModel receipt, AiReceiptData aiData})> scanReceipt(File image) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      });

      final res = await _client.post('/receipts/scan', data: formData);
      final data = res.data['data'];

      return (
        receipt: ReceiptModel.fromJson(data['receipt']),
        aiData:  AiReceiptData.fromJson(data['ai_data']),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
