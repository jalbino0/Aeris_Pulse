
import 'package:flutter_test/flutter_test.dart';
import 'package:aeris_pulse/core/domain/qualidade_ar_br.dart';

void main() {
  group('Classificação brasileira de qualidade do ar', () {
    test('MP2,5 respeita os limites brasileiros', () {
      expect(
        QualidadeArBr.classificarMedia(PoluenteBr.mp25, 15),
        FaixaQualidadeAr.boa,
      );

      expect(
        QualidadeArBr.classificarMedia(PoluenteBr.mp25, 15.1),
        FaixaQualidadeAr.moderada,
      );

      expect(
        QualidadeArBr.classificarMedia(PoluenteBr.mp25, 75),
        FaixaQualidadeAr.ruim,
      );

      expect(
        QualidadeArBr.classificarMedia(PoluenteBr.mp25, 126),
        FaixaQualidadeAr.pessima,
      );
    });

    test('MP10 respeita os limites brasileiros', () {
      expect(
        QualidadeArBr.classificarMedia(PoluenteBr.mp10, 45),
        FaixaQualidadeAr.boa,
      );

      expect(
        QualidadeArBr.classificarMedia(PoluenteBr.mp10, 100),
        FaixaQualidadeAr.moderada,
      );

      expect(
        QualidadeArBr.classificarMedia(PoluenteBr.mp10, 150.1),
        FaixaQualidadeAr.muitoRuim,
      );
    });

    test('Ozônio utiliza os limites de 8 horas', () {
      expect(
        QualidadeArBr.classificarMedia(PoluenteBr.ozonio, 100),
        FaixaQualidadeAr.boa,
      );

      expect(
        QualidadeArBr.classificarMedia(PoluenteBr.ozonio, 130),
        FaixaQualidadeAr.moderada,
      );

      expect(
        QualidadeArBr.classificarMedia(PoluenteBr.ozonio, 201),
        FaixaQualidadeAr.pessima,
      );
    });

    test('Média de MP2,5 requer 24 amostras', () {
      final amostras = List<double>.filled(24, 20);

      expect(
        QualidadeArBr.calcularMedia(PoluenteBr.mp25, amostras),
        20,
      );

      expect(
        QualidadeArBr.classificarAmostras(
          PoluenteBr.mp25,
          amostras,
        ),
        FaixaQualidadeAr.moderada,
      );
    });

    test('Média de ozônio requer 8 amostras', () {
      final amostras = List<double>.filled(8, 80);

      expect(
        QualidadeArBr.calcularMedia(
          PoluenteBr.ozonio,
          amostras,
        ),
        80,
      );
    });

    test('Rejeita dados incompletos e inválidos', () {
      expect(
        () => QualidadeArBr.calcularMedia(
          PoluenteBr.mp25,
          List<double>.filled(23, 15),
        ),
        throwsArgumentError,
      );

      expect(
        () => QualidadeArBr.classificarMedia(
          PoluenteBr.mp10,
          -1,
        ),
        throwsArgumentError,
      );
    });
  });
}
