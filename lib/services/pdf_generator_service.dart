// lib/services/pdf_generator_service.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:con_cidadania/model/lawsuit_model.dart';
import 'package:con_cidadania/model/user_model.dart';
import 'package:intl/intl.dart';

class PdfGeneratorService {
  // Modelo da Procuração
  Future<Uint8List> generateProcuracao(Lawsuit lawsuit, AppUser user) async {
    final pdf = pw.Document();
    final dataAtual = DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR')
        .format(DateTime.now());

    // Qualificação do usuário
    String qualificacao =
        "${user.firstName} ${user.lastName}, ${user.nationality}, ${user.civilStatus}, ${user.profession}, "
        "portador(a) do RG nº ${user.rg} e inscrito(a) no CPF sob o nº ${user.cpf}, "
        "residente e domiciliado(a) à ${user.street}, nº ${user.number}, ${user.neighborhood}, ${user.city}/${user.state}, CEP: ${user.postalCode}";

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(40),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "PROCURAÇÃO \"AD JUDICIA ET EXTRA\"",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 16),
                ),
              ),
              pw.SizedBox(height: 30),

              // OUTORGANTE
              pw.Paragraph(
                style: const pw.TextStyle(lineSpacing: 5),
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                        text: "OUTORGANTE: ",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.TextSpan(
                        text: qualificacao,
                        style: const pw.TextStyle(fontSize: 12)),
                  ],
                ).toPlainText(),
              ),
              pw.SizedBox(height: 20),

              // OUTORGADO (Genérico para a plataforma)
              pw.Paragraph(
                style: const pw.TextStyle(lineSpacing: 5),
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                        text: "OUTORGADO: ",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.TextSpan(
                        text:
                            "Os advogados associados à plataforma Conexão Cidadania, "
                            "com poderes específicos para representar o outorgante perante os órgãos do Poder Judiciário.",
                        style: const pw.TextStyle(fontSize: 12)),
                  ],
                ).toPlainText(),
              ),
              pw.SizedBox(height: 20),

              // PODERES
              pw.Paragraph(
                style: const pw.TextStyle(lineSpacing: 5),
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                        text: "PODERES: ",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.TextSpan(
                        text:
                            "Pelo presente instrumento, o(a) OUTORGANTE nomeia e constitui o(a) OUTORGADO(A) como seu(sua) bastante procurador(a), "
                            "conferindo-lhe os poderes da cláusula 'ad judicia et extra', para o foro em geral, para propor a Ação de ${lawsuit.name}, "
                            "podendo, portanto, em nome do(a) OUTORGANTE, praticar todos os atos necessários ao bom e fiel cumprimento deste mandato, "
                            "incluindo, mas não se limitando a, contestar, transigir, desistir, firmar compromissos, receber e dar quitação, "
                            "representar perante qualquer Juízo ou Tribunal.",
                        style: const pw.TextStyle(fontSize: 12)),
                  ],
                ).toPlainText(),
              ),
              pw.SizedBox(height: 30),

              // LOCAL E DATA
              pw.Center(
                child: pw.Text(
                  "${user.city}, $dataAtual.",
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 60),

              // ASSINATURA
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Container(width: 250, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 5),
                    pw.Text("${user.firstName} ${user.lastName}",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text("OUTORGANTE",
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  // Modelo da Petição Inicial
  Future<Uint8List> generatePeticao(Lawsuit lawsuit, AppUser user) async {
    final pdf = pw.Document();

    // Qualificação do usuário
    String qualificacaoAutor =
        "${user.firstName} ${user.lastName}, ${user.nationality}, ${user.civilStatus}, ${user.profession}, "
        "portador(a) do RG nº ${user.rg} e inscrito(a) no CPF sob o nº ${user.cpf}, "
        "residente e domiciliado(a) à ${user.street}, nº ${user.number}, ${user.neighborhood}, ${user.city}/${user.state}, CEP: ${user.postalCode}, "
        "e-mail: ${user.email}";

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(40),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // ENDEREÇAMENTO
            pw.Text(
              "EXCELENTÍSSIMO SENHOR DOUTOR JUIZ DE DIREITO DA VARA DE FAZENDA PÚBLICA DA COMARCA DE ${user.city.toUpperCase()} - ${user.state.toUpperCase()}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 30),

            // AUTOR
            pw.Paragraph(
              style: const pw.TextStyle(lineSpacing: 5, fontSize: 12),
              text: qualificacaoAutor,
            ),
            pw.SizedBox(height: 10),
            pw.Paragraph(
                text:
                    "vem, respeitosamente, perante Vossa Excelência, por meio de seus procuradores infra-assinados (procuração anexa), propor a presente"),
            pw.SizedBox(height: 20),

            // TÍTULO DA AÇÃO
            pw.Center(
              child: pw.Text(
                "AÇÃO DE OBRIGAÇÃO DE FAZER\n(COM PEDIDO DE TUTELA DE URGÊNCIA)\n"
                "referente a ${lawsuit.name.toUpperCase()}",
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 20),

            // RÉU (Genérico)
            pw.Paragraph(
                text:
                    "em face do MUNICÍPIO DE ${user.city.toUpperCase()}, pessoa jurídica de direito público, "
                    "com sede na Prefeitura Municipal, localizada em [Endereço da Prefeitura], pelos fatos e fundamentos a seguir expostos:",
                style: const pw.TextStyle(lineSpacing: 5, fontSize: 12)),
            pw.SizedBox(height: 20),

            // DOS FATOS (Genérico)
            pw.Text("I - DOS FATOS",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Paragraph(
              text:
                  "O(A) Autor(a) necessita urgentemente da prestação de serviço referente a ${lawsuit.name}.\n\n"
                  "Apesar de ter buscado a via administrativa (conforme documentos anexos), "
                  "o(a) Autor(a) teve seu direito negado ou postergado, não restando outra alternativa senão a busca da tutela jurisdicional.",
              style: const pw.TextStyle(lineSpacing: 5, fontSize: 12),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 20),

            // DO DIREITO (Genérico)
            pw.Text("II - DO DIREITO",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Paragraph(
              text:
                  "A Constituição Federal, em seu artigo 196, estabelece que a saúde (ou educação, etc.) é direito de todos e dever do Estado, "
                  "garantido mediante políticas sociais e econômicas que visem à redução do risco de doença e de outros agravos e ao acesso universal e igualitário às ações e serviços para sua promoção, proteção e recuperação.",
              style: const pw.TextStyle(lineSpacing: 5, fontSize: 12),
              textAlign: pw.TextAlign.justify,
            ),

            // DO PEDIDO
            pw.Text("III - DO PEDIDO",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Paragraph(
              text: "Diante do exposto, requer a Vossa Excelência: "
                  "\na) A concessão da tutela de urgência, 'inaudita altera pars', para determinar que o Réu forneça imediatamente [objeto da ação]; "
                  "\nb) A citação do Réu para, querendo, contestar a presente ação; "
                  "\nc) A total procedência da ação, confirmando a tutela de urgência e condenando o Réu a [objeto da ação]; "
                  "\nd) A condenação do Réu ao pagamento das custas processuais e honorários advocatícios.",
              style: const pw.TextStyle(lineSpacing: 5, fontSize: 12),
            ),
            pw.SizedBox(height: 20),

            pw.Paragraph(
                text:
                    "Dá-se à causa o valor de R\$ 1.000,00 (mil reais), para fins meramente fiscais.",
                style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 10),
            pw.Paragraph(
                text: "Nestes termos,\nPede deferimento.",
                style: const pw.TextStyle(fontSize: 12)),

            pw.SizedBox(height: 30),
            pw.Center(
                child: pw.Text(
                    "${user.city}, ${DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR').format(DateTime.now())}.")),
            pw.SizedBox(height: 20),
            pw.Center(
                child: pw.Text("[Nome do Advogado(a)]\n[OAB/UF Nº XXX.XXX]",
                    textAlign: pw.TextAlign.center)),
          ];
        },
      ),
    );
    return pdf.save();
  }
}
