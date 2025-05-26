import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/money_input_formatter.dart';
import '../theme/app_colors.dart';

class CustomMoneyField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function(double)? onAmountChanged;
  final String? Function(String?)? validator;
  final double? minAmount;
  final double? maxAmount;
  final bool enabled;
  final bool required;

  const CustomMoneyField({
    super.key,
    required this.controller,
    this.label = 'Valor (R\$)',
    this.hintText,
    this.onChanged,
    this.onAmountChanged,
    this.validator,
    this.minAmount = 0.01,
    this.maxAmount = 999999.99,
    this.enabled = true,
    this.required = true,
  });

  @override
  State<CustomMoneyField> createState() => _CustomMoneyFieldState();
}

class _CustomMoneyFieldState extends State<CustomMoneyField> {
  late final MoneyInputFormatter _formatter;
  double? _lastAmount;

  @override
  void initState() {
    super.initState();
    _formatter = MoneyInputFormatter();
    
    // Listener para detectar mudanças no valor
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final currentAmount = MoneyInputFormatter.parseAmount(widget.controller.text);
    
    // Só chamar callback se o valor realmente mudou
    if (_lastAmount != currentAmount) {
      _lastAmount = currentAmount;
      
      // Chamar callbacks
      widget.onChanged?.call(widget.controller.text);
      widget.onAmountChanged?.call(currentAmount);
      
      print('💰 Valor alterado: R\$ ${currentAmount.toStringAsFixed(2)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _formatter,
          ],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: widget.enabled 
                ? (isDark ? Colors.white : Colors.black87)
                : Colors.grey,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText ?? 'R\$ 0,00',
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.attach_money,
                color: widget.enabled ? AppColors.primary : Colors.grey,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : Colors.black12,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : Colors.black12,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: widget.enabled 
                ? (isDark ? Colors.black12 : Colors.white)
                : (isDark ? Colors.black26 : Colors.grey[100]),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            // ✅ HELPER TEXT INFORMATIVO
            helperText: widget.enabled ? _getHelperText() : null,
            helperStyle: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          validator: widget.validator ?? _defaultValidator,
        ),
        
        // ✅ INDICADOR VISUAL DO VALOR ATUAL
        if (widget.enabled && widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildAmountIndicator(),
          ),
      ],
    );
  }

  /// ✅ VALIDADOR PADRÃO MELHORADO
  String? _defaultValidator(String? value) {
    if (widget.required && (value == null || value.trim().isEmpty)) {
      return 'Informe o valor';
    }

    if (value != null && value.isNotEmpty) {
      final amount = MoneyInputFormatter.parseAmount(value);
      
      if (amount <= 0) {
        return 'Valor deve ser maior que zero';
      }
      
      if (widget.minAmount != null && amount < widget.minAmount!) {
        return 'Valor mínimo: ${MoneyInputFormatter.formatAmount(widget.minAmount!)}';
      }
      
      if (widget.maxAmount != null && amount > widget.maxAmount!) {
        return 'Valor máximo: ${MoneyInputFormatter.formatAmount(widget.maxAmount!)}';
      }
    }

    return null;
  }

  /// ✅ TEXTO DE AJUDA DINÂMICO
  String? _getHelperText() {
    if (widget.minAmount != null && widget.maxAmount != null) {
      return 'Entre ${MoneyInputFormatter.formatAmount(widget.minAmount!)} e ${MoneyInputFormatter.formatAmount(widget.maxAmount!)}';
    } else if (widget.minAmount != null) {
      return 'Mínimo: ${MoneyInputFormatter.formatAmount(widget.minAmount!)}';
    } else if (widget.maxAmount != null) {
      return 'Máximo: ${MoneyInputFormatter.formatAmount(widget.maxAmount!)}';
    }
    return null;
  }

  /// ✅ INDICADOR VISUAL DO VALOR
  Widget _buildAmountIndicator() {
    final amount = MoneyInputFormatter.parseAmount(widget.controller.text);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color indicatorColor;
    IconData indicatorIcon;
    String indicatorText;
    
    if (amount <= 0) {
      indicatorColor = AppColors.error;
      indicatorIcon = Icons.error_outline;
      indicatorText = 'Valor inválido';
    } else if (widget.minAmount != null && amount < widget.minAmount!) {
      indicatorColor = AppColors.warning;
      indicatorIcon = Icons.warning_amber;
      indicatorText = 'Abaixo do mínimo';
    } else if (widget.maxAmount != null && amount > widget.maxAmount!) {
      indicatorColor = AppColors.error;
      indicatorIcon = Icons.error_outline;
      indicatorText = 'Acima do máximo';
    } else {
      indicatorColor = AppColors.success;
      indicatorIcon = Icons.check_circle_outline;
      indicatorText = 'Valor válido';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: indicatorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            indicatorIcon,
            size: 16,
            color: indicatorColor,
          ),
          const SizedBox(width: 6),
          Text(
            indicatorText,
            style: TextStyle(
              fontSize: 12,
              color: indicatorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '• ${MoneyInputFormatter.formatAmount(amount)}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ MÉTODOS PÚBLICOS PARA CONTROLE EXTERNO
  void setAmount(double amount) {
    widget.controller.text = MoneyInputFormatter.formatAmount(amount);
  }

  double getCurrentAmount() {
    return MoneyInputFormatter.parseAmount(widget.controller.text);
  }

  void clear() {
    widget.controller.clear();
  }

  bool isValid() {
    return _defaultValidator(widget.controller.text) == null;
  }
}