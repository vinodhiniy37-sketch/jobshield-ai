enum CoverLetterTone {
  professional,
  confident,
  concise,
  friendly,
}

extension CoverLetterToneExtension on CoverLetterTone {
  String get label {
    switch (this) {
      case CoverLetterTone.professional:
        return 'Professional';
      case CoverLetterTone.confident:
        return 'Confident';
      case CoverLetterTone.concise:
        return 'Concise';
      case CoverLetterTone.friendly:
        return 'Friendly';
    }
  }
}

class GeneratedCoverLetter {
  final String id;
  final String companyName;
  final String jobTitle;
  final CoverLetterTone tone;
  final String salutation;
  final String openingParagraph;
  final String skillsExperienceParagraph;
  final String suitabilityParagraph;
  final String candidateInterestParagraph;
  final String closingParagraph;
  final String fullText;
  final DateTime createdAt;

  GeneratedCoverLetter({
    required this.id,
    required this.companyName,
    required this.jobTitle,
    required this.tone,
    required this.salutation,
    required this.openingParagraph,
    required this.skillsExperienceParagraph,
    required this.suitabilityParagraph,
    required this.candidateInterestParagraph,
    required this.closingParagraph,
    required this.fullText,
    required this.createdAt,
  });
}
