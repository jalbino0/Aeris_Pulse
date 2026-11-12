enum PoluenteBr { mp25, mp10, ozonio }

enum FaixaQualidadeAr {
  boa('Boa'),
  moderada('Moderada'),
  ruim('Ruim'),
  muitoRuim('Muito ruim'),
  pessima('Péssima');

  const FaixaQualidadeAr(this.nome);

  final String nome;
}

class QualidadeArBr {
  static int janelaHoras(PoluenteBr poluente) {
    return switch (poluente) {
      PoluenteBr.mp25 => 24,
      PoluenteBr.mp10 => 24,
      PoluenteBr.ozonio => 8,
    };
  }

  static double calcularMedia(PoluenteBr poluente, List<double> concentracoes) {
    final quantidade = janelaHoras(poluente);

    if (concentracoes.length != quantidade) {
      throw ArgumentError('São necessárias $quantidade amostras horárias.');
    }

    if (concentracoes.any((valor) => !valor.isFinite || valor < 0)) {
      throw ArgumentError('Concentrações inválidas.');
    }

    final soma = concentracoes.reduce((anterior, atual) => anterior + atual);

    return soma / quantidade;
  }

  static FaixaQualidadeAr classificarMedia(
    PoluenteBr poluente,
    double concentracao,
  ) {
    if (!concentracao.isFinite || concentracao < 0) {
      throw ArgumentError('Concentração inválida.');
    }

    final limites = switch (poluente) {
      PoluenteBr.mp25 => [15.0, 50.0, 75.0, 125.0],
      PoluenteBr.mp10 => [45.0, 100.0, 150.0, 250.0],
      PoluenteBr.ozonio => [100.0, 130.0, 160.0, 200.0],
    };

    if (concentracao <= limites[0]) {
      return FaixaQualidadeAr.boa;
    }

    if (concentracao <= limites[1]) {
      return FaixaQualidadeAr.moderada;
    }

    if (concentracao <= limites[2]) {
      return FaixaQualidadeAr.ruim;
    }

    if (concentracao <= limites[3]) {
      return FaixaQualidadeAr.muitoRuim;
    }

    return FaixaQualidadeAr.pessima;
  }

  static FaixaQualidadeAr classificarAmostras(
    PoluenteBr poluente,
    List<double> concentracoes,
  ) {
    final media = calcularMedia(poluente, concentracoes);

    return classificarMedia(poluente, media);
  }
}
