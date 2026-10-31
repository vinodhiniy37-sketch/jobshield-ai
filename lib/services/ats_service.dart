import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/resume_analysis_model.dart';
import '../models/job_match_model.dart';

class AtsService {
  // Analyzes resume text or file input for ATS Compatibility
  AtsResumeAnalysis analyzeResume({
    required String fileName,
    required String rawContent,
    Uint8List? fileBytes,
  }) {
    final text = rawContent.toLowerCase();
    
    // Check key sections
    final hasContact = text.contains('@') || text.contains('phone') || text.contains('email') || text.contains('mobile') || text.contains('+');
    final hasSummary = text.contains('summary') || text.contains('objective') || text.contains('profile') || text.contains('about');
    final hasEducation = text.contains('education') || text.contains('degree') || text.contains('university') || text.contains('college') || text.contains('b.tech') || text.contains('b.e') || text.contains('bsc');
    final hasSkills = text.contains('skills') || text.contains('technologies') || text.contains('competencies') || text.contains('tools');
    final hasExperience = text.contains('experience') || text.contains('work history') || text.contains('internship') || text.contains('employment');
    final hasProjects = text.contains('projects') || text.contains('key projects') || text.contains('portfolio');
    final hasCertifications = text.contains('certifications') || text.contains('certificates') || text.contains('licenses');

    // Section Completeness Calculation
    int missingCount = 0;
    final List<String> missingSections = [];
    if (!hasContact) { missingSections.add('Contact Details'); missingCount++; }
    if (!hasSummary) { missingSections.add('Professional Summary'); missingCount++; }
    if (!hasEducation) { missingSections.add('Education Section'); missingCount++; }
    if (!hasSkills) { missingSections.add('Technical Skills'); missingCount++; }
    if (!hasExperience) { missingSections.add('Work Experience / Internships'); missingCount++; }
    if (!hasProjects) { missingSections.add('Projects'); missingCount++; }
    if (!hasCertifications) { missingSections.add('Certifications & Achievements'); missingCount++; }

    int sectionCompletenessScore = ((7 - missingCount) / 7 * 100).round().clamp(20, 100);

    // Skill extraction
    final techKeywords = [
      'python', 'java', 'javascript', 'typescript', 'dart', 'flutter', 'react', 'node', 'sql', 'mysql',
      'mongodb', 'html', 'css', 'git', 'github', 'aws', 'docker', 'rest api', 'firebase', 'c++', 'c#',
      'machine learning', 'ai', 'data structures', 'algorithms', 'agile', 'scrum', 'linux', 'figma'
    ];
    final List<String> detectedSkills = [];
    for (final kw in techKeywords) {
      if (text.contains(kw)) {
        detectedSkills.add(kw[0].toUpperCase() + kw.substring(1));
      }
    }

    int keywordScore = (detectedSkills.length * 8).clamp(30, 95);
    int formattingScore = (text.contains('tables') || text.contains('image')) ? 60 : 85;
    int contentScore = (hasProjects && hasSkills && hasEducation) ? 88 : 65;
    int readabilityScore = (rawContent.length > 200 && rawContent.length < 3500) ? 90 : 70;

    int overallScore = ((sectionCompletenessScore * 0.25) +
            (keywordScore * 0.25) +
            (formattingScore * 0.20) +
            (contentScore * 0.20) +
            (readabilityScore * 0.10))
        .round()
        .clamp(15, 98);

    final List<AtsSectionScore> sectionScores = [
      AtsSectionScore(
        title: 'Contact Information',
        score: hasContact ? 95 : 30,
        status: hasContact ? 'Good' : 'Needs Improvement',
        feedback: hasContact ? 'Valid email and contact reference detected.' : 'Ensure mobile phone and email are prominently placed at top.',
      ),
      AtsSectionScore(
        title: 'Structure & Headings',
        score: hasSummary && hasSkills && hasEducation ? 90 : 60,
        status: hasSummary && hasSkills && hasEducation ? 'Good' : 'Needs Improvement',
        feedback: 'Standard ATS-parsable section headings are recommended.',
      ),
      AtsSectionScore(
        title: 'Keywords & Skills',
        score: keywordScore,
        status: keywordScore >= 70 ? 'Good' : 'Needs Improvement',
        feedback: 'Identified ${detectedSkills.length} core technical keywords.',
      ),
      AtsSectionScore(
        title: 'Projects & Experience',
        score: hasProjects ? 85 : 45,
        status: hasProjects ? 'Good' : 'Missing',
        feedback: hasProjects ? 'Projects section is formatted.' : 'Add 2-3 technical projects with measurable outcomes.',
      ),
      AtsSectionScore(
        title: 'Formatting & Layout',
        score: formattingScore,
        status: formattingScore >= 80 ? 'Good' : 'Needs Improvement',
        feedback: 'Clean single-column formatting parses best across enterprise ATS scanners.',
      ),
    ];

    final List<String> strengths = [];
    if (hasSkills && detectedSkills.isNotEmpty) strengths.add('Strong technical skills list (${detectedSkills.take(4).join(', ')})');
    if (hasEducation) strengths.add('Clear education credentials section');
    if (hasProjects) strengths.add('Relevant project portfolio highlighted');
    if (hasContact) strengths.add('Clear contact information placed');

    final List<String> weaknesses = [];
    if (!text.contains('%') && !text.contains('increase') && !text.contains('reduced') && !text.contains('built')) {
      weaknesses.add('Missing measurable metric achievements (e.g. "improved performance by 25%")');
    }
    if (detectedSkills.length < 5) {
      weaknesses.add('Low technical keyword density for automated resume filters');
    }
    if (!hasSummary) {
      weaknesses.add('Professional summary or objective section is missing');
    }

    final List<String> recommendations = [
      'Use standard bullet points with active action verbs (e.g. Developed, Architected, Optimized).',
      'Incorporate industry-standard keywords aligned with target job titles.',
      'Avoid graphics, complex multi-column tables, or non-standard fonts to prevent parsing errors.',
    ];

    return AtsResumeAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
      overallScore: overallScore,
      keywordScore: keywordScore,
      formattingScore: formattingScore,
      contentScore: contentScore,
      readabilityScore: readabilityScore,
      sectionCompletenessScore: sectionCompletenessScore,
      sectionScores: sectionScores,
      strengths: strengths,
      weaknesses: weaknesses,
      missingSections: missingSections,
      recommendations: recommendations,
      detectedSkills: detectedSkills,
      parsingNote: 'Estimated ATS compatibility score based on standard ATS parser heuristic analysis.',
      createdAt: DateTime.now(),
    );
  }

  // Matches resume content against job description
  AtsJobMatch matchJobDescription({
    required String resumeText,
    required String jobTitle,
    required String companyName,
    required String jobDescription,
  }) {
    final resumeLower = resumeText.toLowerCase();
    final jdLower = jobDescription.toLowerCase();

    final techKeywords = [
      'python', 'java', 'javascript', 'typescript', 'dart', 'flutter', 'react', 'node', 'express',
      'sql', 'mysql', 'postgresql', 'mongodb', 'firebase', 'html', 'css', 'git', 'github', 'aws',
      'azure', 'gcp', 'docker', 'kubernetes', 'rest api', 'graphql', 'c++', 'c#', 'spring boot',
      'machine learning', 'ai', 'data science', 'agile', 'scrum', 'jira', 'linux', 'figma', 'unit testing'
    ];

    final List<String> requiredInJd = [];
    for (final kw in techKeywords) {
      if (jdLower.contains(kw)) {
        requiredInJd.add(kw);
      }
    }

    final List<String> matchedSkills = [];
    final List<String> missingSkills = [];
    final List<String> partialMatches = [];

    for (final skill in requiredInJd) {
      final skillDisplay = skill[0].toUpperCase() + skill.substring(1);
      if (resumeLower.contains(skill)) {
        matchedSkills.add(skillDisplay);
      } else {
        missingSkills.add(skillDisplay);
      }
    }

    // Calculate match score
    int totalReq = requiredInJd.length;
    int matchScore = 70;
    if (totalReq > 0) {
      matchScore = ((matchedSkills.length / totalReq) * 100).round().clamp(15, 98);
    }

    final List<String> importantKeywords = requiredInJd.take(6).map((k) => k[0].toUpperCase() + k.substring(1)).toList();
    final List<String> experienceGaps = [];
    if (missingSkills.isNotEmpty) {
      experienceGaps.add('Missing key technologies required in job posting: ${missingSkills.take(3).join(', ')}');
    }
    if (jdLower.contains('years') && !resumeLower.contains('years')) {
      experienceGaps.add('Job specifies explicit years of experience requirements.');
    }

    final List<String> recommendedChanges = [];
    if (missingSkills.isNotEmpty) {
      recommendedChanges.add('If you have hands-on experience with ${missingSkills.first}, add relevant project bullets to your resume.');
    }
    recommendedChanges.add('Mirror key phrases from the job description in your Skills and Project section.');
    recommendedChanges.add('Highlight problem-solving experience directly relevant to $jobTitle.');

    return AtsJobMatch(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      jobTitle: jobTitle.isEmpty ? 'Target Role' : jobTitle,
      companyName: companyName.isEmpty ? 'Target Employer' : companyName,
      jobDescription: jobDescription,
      matchScore: matchScore,
      matchedSkills: matchedSkills,
      missingSkills: missingSkills,
      partialMatches: partialMatches,
      importantKeywords: importantKeywords,
      experienceGaps: experienceGaps,
      recommendedChanges: recommendedChanges,
      createdAt: DateTime.now(),
    );
  }
}
