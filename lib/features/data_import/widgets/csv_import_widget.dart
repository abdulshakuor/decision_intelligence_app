import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File; // استخدام مشروط أو آمن
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class CsvImportWidget extends StatefulWidget {
  const CsvImportWidget({super.key});

  @override
  State<CsvImportWidget> createState() => _CsvImportWidgetState();
}

class _CsvImportWidgetState extends State<CsvImportWidget> {
  final _apiClient = ApiClient();
  String? _filePath;
  String? _fileName;
  List<List<String>> _previewData = [];
  List<String> _headers = [];
  bool _isLoading = false;
  bool _isUploading = false;
  Map<String, dynamic>? _importResult;
  String? _webFileContent; // لحفظ المحتوى على الويب

  final Map<String, String?> _columnMapping = {
    'SKU': null,
    'Name': null,
    'Description': null,
    'CostPrice': null,
    'SellingPrice': null,
    'CategoryId': null,
  };

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: kIsWeb, // ضروري للويب
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        String content = '';
        if (kIsWeb) {
          content = utf8.decode(result.files.single.bytes!);
          _webFileContent = content;
        } else {
          final file = File(result.files.single.path!);
          content = await file.readAsString(encoding: utf8);
        }

        final lines = const LineSplitter().convert(content);
        if (lines.isNotEmpty) {
          _headers = lines[0].split(',').map((h) => h.trim()).toList();
          _previewData = lines
              .skip(1)
              .take(5)
              .map(
                (line) => line.split(',').map((cell) => cell.trim()).toList(),
              )
              .toList();
        }

        setState(() {
          _filePath = kIsWeb ? null : result.files.single.path;
          _fileName = result.files.single.name;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('خطأ في قراءة الملف', isError: true);
      }
    }
  }

  Future<void> _importData() async {
    if (_columnMapping['SKU'] == null || _columnMapping['Name'] == null) {
      _showSnackBar('يجب ربط عمودي SKU والاسم على الأقل', isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      String content = '';
      if (kIsWeb) {
        content = _webFileContent!;
      } else {
        final file = File(_filePath!);
        content = await file.readAsString(encoding: utf8);
      }

      final lines = const LineSplitter().convert(content);
      final headers = lines[0].split(',').map((h) => h.trim()).toList();

      final products = <Map<String, dynamic>>[];

      for (var i = 1; i < lines.length; i++) {
        final cells = lines[i].split(',').map((c) => c.trim()).toList();
        if (cells.length < headers.length) continue;

        final product = <String, dynamic>{};

        _columnMapping.forEach((field, csvColumn) {
          if (csvColumn != null) {
            final colIndex = headers.indexOf(csvColumn);
            if (colIndex >= 0 && colIndex < cells.length) {
              final value = cells[colIndex];
              if (field == 'CostPrice' || field == 'SellingPrice') {
                product[field[0].toLowerCase() + field.substring(1)] =
                    double.tryParse(value) ?? 0;
              } else if (field == 'CategoryId') {
                product['categoryId'] = int.tryParse(value) ?? 1;
              } else {
                product[field[0].toLowerCase() + field.substring(1)] = value;
              }
            }
          }
        });

        if (product.isNotEmpty) products.add(product);
      }

      final response = await _apiClient.post(
        ApiConstants.importProducts,
        data: products,
      );

      setState(() {
        _importResult = response.data['data'];
        _isUploading = false;
      });

      _showSnackBar('تم الاستيراد بنجاح!');
    } catch (e) {
      setState(() => _isUploading = false);
      _showSnackBar('خطأ في الاستيراد: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const LinearProgressIndicator()
                  else
                    Text(
                      _fileName ?? 'اسحب ملف CSV هنا أو اضغط للاختيار',
                      style: const TextStyle(fontSize: 14),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.file_open),
                    label: const Text('اختيار ملف CSV'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_headers.isNotEmpty) ...[
            const Text(
              'معاينة البيانات',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: _headers
                    .map((h) => DataColumn(label: Text(h)))
                    .toList(),
                rows: _previewData
                    .map(
                      (row) => DataRow(
                        cells: row.map((cell) => DataCell(Text(cell))).toList(),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ربط الأعمدة',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: _columnMapping.keys.map((field) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              field,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_back,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _columnMapping[field],
                              decoration: const InputDecoration(isDense: true),
                              hint: const Text(
                                'اختر عمود',
                                style: TextStyle(fontSize: 12),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('-- لا شيء --'),
                                ),
                                ..._headers.map(
                                  (h) => DropdownMenuItem(
                                    value: h,
                                    child: Text(h),
                                  ),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _columnMapping[field] = v),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _importData,
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload),
                label: Text(
                  _isUploading ? 'جاري الاستيراد...' : 'بدء الاستيراد',
                ),
              ),
            ),
          ],
          if (_importResult != null) ...[
            const SizedBox(height: 16),
            _buildResultCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      color: AppColors.secondary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نتيجة الاستيراد',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _resultRow(
              'إجمالي المعالجة',
              '${_importResult!['totalProcessed']}',
            ),
            _resultRow(
              'تم إنشاؤها',
              '${_importResult!['created']}',
              color: AppColors.secondary,
            ),
            _resultRow(
              'تم تحديثها',
              '${_importResult!['updated']}',
              color: AppColors.primary,
            ),
            _resultRow(
              'أخطاء',
              '${_importResult!['errors']}',
              color: AppColors.danger,
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
