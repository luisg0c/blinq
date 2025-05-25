import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/usecases/generate_qr_usecase.dart';
import '../../../domain/usecases/parse_qr_usecase.dart';
import '../../../routes/app_routes.dart';

class QrCodePage extends StatefulWidget {
  const QrCodePage({super.key});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _generatedQrData;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      appBar: AppBar(
        title: const Text('QR Code PIX'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Receber', icon: Icon(Icons.qr_code)),
            Tab(text: 'Pagar', icon: Icon(Icons.qr_code_scanner)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReceiveTab(context, isDark),
          _buildPayTab(context, isDark),
        ],
      ),
    );
  }

  Widget _buildReceiveTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          // Título
          Text(
            'Gerar QR Code para receber',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Campo valor
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Valor (R\$)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Campo descrição
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descrição (opcional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Botão gerar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _generateQrCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Gerar QR Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // QR Code gerado
          if (_generatedQrData != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: _generatedQrData!,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mostre este QR Code para receber o pagamento',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPayTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Escaneie o QR Code para pagar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startScanning,
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  label: const Text(
                    'Abrir Scanner',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Scanner area
        if (_isScanning)
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: MobileScanner(
                  onDetect: _onQrCodeDetected,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _generateQrCode() {
    final amount = double.tryParse(_amountController.text);
    
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Erro',
        'Informe um valor válido',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    // Usar email fixo do usuário logado (você pode pegar do Firebase Auth)
    const userEmail = 'usuario@blinq.com'; // TODO: Pegar do usuário logado
    
    final generateQrUseCase = GenerateQrUseCase();
    final qrData = generateQrUseCase.execute(
      email: userEmail,
      amount: amount,
      description: _descriptionController.text.isNotEmpty 
          ? _descriptionController.text 
          : null,
    );

    setState(() {
      _generatedQrData = qrData;
    });

    Get.snackbar(
      'Sucesso! 📱',
      'QR Code gerado com sucesso',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  Future<void> _startScanning() async {
    // Verificar permissão de câmera
    final permission = await Permission.camera.request();
    
    if (permission != PermissionStatus.granted) {
      Get.snackbar(
        'Permissão necessária',
        'Permita o acesso à câmera para escanear QR Codes',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isScanning = true;
    });
  }

  void _onQrCodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isNotEmpty) {
      final qrData = barcodes.first.rawValue;
      
      if (qrData != null) {
        setState(() {
          _isScanning = false;
        });

        _processQrCode(qrData);
      }
    }
  }

  void _processQrCode(String qrData) {
    try {
      final parseQrUseCase = ParseQrUseCase();
      final parsedData = parseQrUseCase.execute(qrData);

      // Navegar para tela de transferência com dados preenchidos
      Get.toNamed(
        AppRoutes.transfer,
        arguments: {
          'recipient': parsedData.email,
          'amount': parsedData.amount,
          'description': parsedData.description,
          'fromQrCode': true,
        },
      );

    } catch (e) {
      Get.snackbar(
        'QR Code inválido',
        'Este QR Code não é válido para pagamentos Blinq',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }
}