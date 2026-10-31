import '../models/cover_letter_model.dart';
import '../models/career_profile_model.dart';

class CoverLetterService {
  GeneratedCoverLetter generateCoverLetter({
    required CareerProfile profile,
    required String companyName,
    required String jobTitle,
    required String jobDescription,
    required CoverLetterTone tone,
    int variation = 0,
  }) {
    final name = profile.fullName.isNotEmpty ? profile.fullName : 'Candidate';
    final company = companyName.isNotEmpty ? companyName : 'Hiring Manager';
    final role = jobTitle.isNotEmpty ? jobTitle : 'Position';
    final skillsText = profile.skills.isNotEmpty ? profile.skills.take(4).join(', ') : 'Software Development, Mobile Engineering, and Problem Solving';
    final educationText = profile.education.isNotEmpty ? profile.education : 'Computer Science and Engineering background';

    String salutation = variation % 2 == 0 ? 'Dear Hiring Manager at $company,' : 'To the Hiring Team at $company,';
    String opening = '';
    String skillsParagraph = '';
    String suitability = '';
    String interest = '';
    String closing = '';

    switch (tone) {
      case CoverLetterTone.confident:
        opening = 'I am writing to express my strong interest in the $role position at $company. With a solid foundation in $educationText and expertise in $skillsText, I am confident in my ability to contribute immediately to your team\'s technical objectives.';
        skillsParagraph = 'Throughout my academic and project work, I have focused on building scalable, reliable applications. My hands-on experience includes developing full-stack projects using $skillsText, adhering to clean architecture standards, and optimizing performance.';
        suitability = 'The requirements for the $role role align directly with my technical capabilities and technical problem-solving mindset.';
        interest = 'I admire $company\'s commitment to innovation and look forward to leveraging my skills to build high-impact products.';
        closing = 'Thank you for considering my application. I look forward to the opportunity to discuss how my background aligns with your team\'s goals.\n\nSincerely,\n$name';
        break;

      case CoverLetterTone.concise:
        opening = 'Please accept this application for the $role position at $company. I bring a strong background in $educationText along with practical experience in $skillsText.';
        skillsParagraph = 'Key technical highlights from my portfolio include engineering cross-platform applications and integrating cloud backend services.';
        suitability = 'My technical toolkit ($skillsText) directly addresses the core competencies outlined in your job posting.';
        interest = 'I am excited about $company\'s direction and eager to contribute to your upcoming engineering roadmap.';
        closing = 'I look forward to connecting regarding next steps.\n\nBest regards,\n$name';
        break;

      case CoverLetterTone.friendly:
        opening = 'I was thrilled to come across the $role opening at $company! As a dedicated developer with a background in $educationText, I would love the chance to bring my passion for $skillsText to your engineering team.';
        skillsParagraph = 'I enjoy transforming complex requirements into smooth, user-friendly software experiences. My recent projects feature interactive mobile apps, real-time database integrations, and clean user interfaces.';
        suitability = 'I am drawn to $company because of your reputation for technical excellence and collaborative culture.';
        interest = 'Given my background in $skillsText, I am enthusiastic about the value I can bring to the $role role.';
        closing = 'Warm regards,\n$name';
        break;

      case CoverLetterTone.professional:
      default:
        opening = 'I am writing to apply for the $role position at $company as advertised. Holding a degree/background in $educationText, I have developed technical proficiency in $skillsText.';
        skillsParagraph = 'My technical experience encompasses software design, API integration, and collaborative project development. I have successfully delivered software projects utilizing modern frameworks and industry-standard version control workflows.';
        suitability = 'Based on the responsibilities described for the $role position, my skill set in $skillsText represents a strong technical match.';
        interest = 'I am particularly interested in $company due to your leadership in software innovation and technological rigor.';
        closing = 'Thank you for your time and consideration. I welcome the opportunity for an interview to further discuss my qualifications.\n\nSincerely,\n$name';
        break;
    }

    final fullText = '$salutation\n\n$opening\n\n$skillsParagraph\n\n$suitability $interest\n\n$closing';

    return GeneratedCoverLetter(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      companyName: company,
      jobTitle: role,
      tone: tone,
      salutation: salutation,
      openingParagraph: opening,
      skillsExperienceParagraph: skillsParagraph,
      suitabilityParagraph: suitability,
      candidateInterestParagraph: interest,
      closingParagraph: closing,
      fullText: fullText,
      createdAt: DateTime.now(),
    );
  }
}
