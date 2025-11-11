// lib/view/widgets/procuracao_signature_button.dart
import 'package:con_cidadania/utils/colors.dart';
import 'package:flutter/material.dart';

class ProcuracaoSignatureButton extends StatelessWidget {
  final VoidCallback onTap;

  const ProcuracaoSignatureButton({Key? key, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Um Card para manter a consistência visual com os DocumentUploadCards
    return Card(
      elevation: 2.0,
      // Cor de fundo amarela
      color: Colors.amber.shade500,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        // Borda amarela para destacar
        side: BorderSide(color: Colors.amber.shade500, width: 1),
      ),
      margin: EdgeInsets.only(
        bottom: 16.0,
      ), // Margem para separar dos outros itens
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        // Ícone
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.draw_outlined, // Ícone de assinatura
            color: AppColors.darkGreen, // Cor de alto contraste
          ),
        ),
        // Texto Principal
        title: Text(
          "Assinar Procuração",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.lightGrey,
          ),
        ),
        // Subtítulo para reforçar a ação
        subtitle: Text(
          "Ação necessária",
          style: TextStyle(
            color: AppColors.lightGrey,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        // Ícone de seta (padrão da UI)
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.lightGrey,
        ),
      ),
    );
  }
}
