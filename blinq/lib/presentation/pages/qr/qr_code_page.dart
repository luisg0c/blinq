import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/usecases/generate_qr_usecase.dart';
import '../../../domain/usecases/parse_qr_usecase.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/money_input_formatter.dart';

class QrCodePage extends StatefulWidget {
  const QrCodePage({super.key});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Controllers para geração
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Estado
  String? _generatedQrData;
  bool _isScanning = false;
  bool _isGenerating = false;
  MobileScannerController? _scannerController;

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
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      appBar: _buildAppBar(context, isDark),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReceiveTab(context, isDark),
          _buildPayTab(context, isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
      ),
      title: Text(
        'QR Code PIX',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      centerTitle: true,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
        tabs: const [
          Tab(text: 'Receber', icon: Icon(Icons.qr_code)),
          Tab(text: 'Pagar', icon: Icon(Icons.qr_code_scanner)),
        ],
      ),
    );
  }

  /// ✅ ABA PARA GERAR QR CODE (RECEBER)
  Widget _buildReceiveTab(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final backgroundColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.qr_code,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gerar QR Code para receber',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crie um QR Code para que outros usuários possam te pagar facilmente',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Campo valor
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [MoneyInputFormatter()],
              style: TextStyle(color: textColor, fontSize: 18),
              decoration: InputDecoration(
                labelText: 'Valor (R\$)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.attach_money, color: AppColors.primary),
                filled: true,
                fillColor: backgroundColor,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o valor';
                }
                
                final cleanValue = value
                    .replaceAll('R\$', '')
                    .replaceAll(' ', '')
                    .replaceAll('.', '')
                    .replaceAll(',', '.');
                
                final amount = double.tryParse(cleanValue);
                
                if (amount == null || amount <= 0) {
                  return 'Valor deve ser maior que zero';
                }
                
                if (amount > 50000) {
                  return 'Valor máximo: R\$ 50.000,00';
                }
                
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Campo descrição
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.description, color: AppColors.primary),
                filled: true,
                fillColor: backgroundColor,
                hintText: 'Ex: Almoço, Gasolina, Presente...',
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botão gerar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateQrCode,
                icon: _isGenerating 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.qr_code, color: Colors.white),
                label: Text(
                  _isGenerating ? 'Gerando...' : 'Gerar QR Code',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // QR Code gerado
            if (_generatedQrData != null) ...[
              Container(
                width: double.infinity,
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
                      foregroundColor: Colors.black,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'QR Code gerado com sucesso! 🎉',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mostre este código para receber o pagamento',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() => _generatedQrData = null);
                              _amountController.clear();
                              _descriptionController.clear();
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Novo QR'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implementar compartilhamento
                              Get.snackbar('Em breve', 'Funcionalidade de compartilhamento');
                            },
                            icon: const Icon(Icons.share, size: 16, color: Colors.white),
                            label: const Text('Compartilhar', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// ✅ ABA PARA ESCANEAR QR CODE (PAGAR)
  Widget _buildPayTab(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final backgroundColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA);
    
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Escaneie o QR Code para pagar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Aponte a câmera para um QR Code Blinq',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isScanning ? null : _startScanning,
                  icon: Icon(
                    _isScanning ? Icons.stop : Icons.qr_code_scanner,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isScanning ? 'Parar Scanner' : 'Abrir Scanner',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isScanning ? AppColors.error : AppColors.primary,
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
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: _onQrCodeDetected,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner_outlined,
                    size: 80,
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Toque em "Abrir Scanner" para começar',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// ✅ GERAR QR CODE
  Future<void> _generateQrCode() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isGenerating = true);
    
    try {
      // Converter valor
      final amountText = _amountController.text;
      final cleanValue = amountText
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      
      final amount = double.tryParse(cleanValue);
      if (amount == null || amount <= 0) {
        throw Exception('Valor inválido');
      }

      // Obter email do usuário logado
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email == null) {
        throw Exception('Usuário não autenticado');
      }

      // Gerar QR Code
      final generateQrUseCase = GenerateQrUseCase();
      final qrData = generateQrUseCase.execute(
        email: user!.email!,
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
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      Get.snackbar(
        'Erro',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  /// ✅ INICIAR SCANNER
  Future<void> _startScanning() async {
    // Verificar permissão de câmera
    final permission = await Permission.camera.request();
    
    if (permission != PermissionStatus.granted) {
      Get.snackbar(
        'Permissão necessária',
        'Permita o acesso à câmera para escanear QR Codes',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isScanning = true;
      _scannerController = MobileScannerController();
    });
  }

  /// ✅ DETECTAR QR CODE
  void _onQrCodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isNotEmpty && _isScanning) {
      final qrData = barcodes.first.rawValue;
      
      if (qrData != null) {
        setState(() {
          _isScanning = false;
        });
        
        _scannerController?.dispose();
        _scannerController = null;

        _processQrCode(qrData);
      }
    }
  }

  /// ✅ PROCESSAR QR CODE LIDO
  void _processQrCode(String qrData) {
    try {
      print('📱 Processando QR Code: $qrData');
      
      final parseQrUseCase = ParseQrUseCase();
      final parsedData = parseQrUseCase.execute(qrData);

      // Mostrar dados do QR Code
      Get.dialog(
        AlertDialog(
          title: const Text('QR Code Detectado! 🎯'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📧 Destinatário: ${parsedData.email}'),
              Text('💰 Valor: R\$ ${parsedData.amount.toStringAsFixed(2)}'),
              if (parsedData.description != null)
                Text('📝 Descrição: ${parsedData.description}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                
                // Navegar para transferência com dados preenchidos
                Get.toNamed(
                  AppRoutes.transfer,
                  arguments: {
                    'recipient': parsedData.email,
                    'amount': parsedData.amount,
                    'description': parsedData.description,
                    'fromQrCode': true,
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Pagar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

    } catch (e) {
      print('❌ Erro ao processar QR Code: $e');
      
      Get.snackbar(
        'QR Code inválido',
        'Este QR Code não é válido para pagamentos Blinq',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}