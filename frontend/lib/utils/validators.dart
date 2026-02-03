class Validators {
  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }

    // Remove caracteres não numéricos
    final cpf = value.replaceAll(RegExp(r'\D'), '');

    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    // Verifica CPFs com números iguais (ex: 111.111.111-11)
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) {
      return 'CPF inválido';
    }

    // Validação dos dígitos verificadores
    if (!_validateCPFDigits(cpf)) {
      return 'CPF inválido';
    }

    return null;
  }

  static String? validateCNPJ(String? value) {
    if (value == null || value.isEmpty) {
      return 'CNPJ é obrigatório';
    }

    // Remove caracteres não numéricos
    final cnpj = value.replaceAll(RegExp(r'\D'), '');

    if (cnpj.length != 14) {
      return 'CNPJ deve ter 14 dígitos';
    }

    // Verifica CNPJs com números iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) {
      return 'CNPJ inválido';
    }

    // Validação dos dígitos verificadores
    if (!_validateCNPJDigits(cnpj)) {
      return 'CNPJ inválido';
    }

    return null;
  }

  static String? validateDocumento(String? value) {
    if (value == null || value.isEmpty) {
      return 'Documento é obrigatório';
    }

    final cleanValue = value.replaceAll(RegExp(r'\D'), '');

    if (cleanValue.length == 11) {
      return validateCPF(value);
    } else if (cleanValue.length == 14) {
      return validateCNPJ(value);
    } else {
      return 'Documento inválido';
    }
  }

  // Algoritmo de validação do CPF
  static bool _validateCPFDigits(String cpf) {
    List<int> numbers = cpf.split('').map(int.parse).toList();

    // Primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += numbers[i] * (10 - i);
    }
    int remainder = sum % 11;
    int digit1 = remainder < 2 ? 0 : 11 - remainder;

    if (numbers[9] != digit1) return false;

    // Segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += numbers[i] * (11 - i);
    }
    remainder = sum % 11;
    int digit2 = remainder < 2 ? 0 : 11 - remainder;

    return numbers[10] == digit2;
  }

  // Algoritmo de validação do CNPJ
  static bool _validateCNPJDigits(String cnpj) {
    List<int> numbers = cnpj.split('').map(int.parse).toList();

    // Primeiro dígito verificador
    int sum = 0;
    int weight = 5;
    for (int i = 0; i < 12; i++) {
      sum += numbers[i] * weight;
      weight--;
      if (weight < 2) weight = 9;
    }
    int remainder = sum % 11;
    int digit1 = remainder < 2 ? 0 : 11 - remainder;

    if (numbers[12] != digit1) return false;

    // Segundo dígito verificador
    sum = 0;
    weight = 6;
    for (int i = 0; i < 13; i++) {
      sum += numbers[i] * weight;
      weight--;
      if (weight < 2) weight = 9;
    }
    remainder = sum % 11;
    int digit2 = remainder < 2 ? 0 : 11 - remainder;

    return numbers[13] == digit2;
  }
}
