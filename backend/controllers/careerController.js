const CareerProfile = require('../models/CareerProfile');

// @desc    Get or initialize user's Career Profile
// @route   GET /api/career/profile
// @access  Private
const getCareerProfile = async (req, res) => {
  try {
    let profile = await CareerProfile.findOne({ userId: req.user.id });
    if (!profile) {
      profile = await CareerProfile.create({
        userId: req.user.id,
        fullName: req.user.name || 'Candidate',
        email: req.user.email || '',
        phone: req.user.phone || '',
        location: req.user.location || '',
        headline: 'Computer Science Engineering Student | Full-Stack & AI Developer',
        summary: 'Passionate software developer specializing in mobile & web application development, cloud databases, and AI security systems.',
        education: 'B.E. Computer Science & Engineering',
        skills: ['Flutter', 'Dart', 'Node.js', 'Express', 'MongoDB', 'Python', 'REST API', 'Git', 'SQL', 'Firebase'],
        projects: [
          'JobShield AI — Recruitment Fraud Detection & Career Intelligence Platform',
          'Smart Attendance & Face Analytics Portal',
        ],
        experience: ['Software Engineering Intern (Summer 2025)'],
        certifications: ['Full-Stack Developer Specialization', 'Cloud Computing Fundamentals'],
        preferredRole: 'Software Developer / Flutter Engineer',
        preferredLocation: 'Remote / Hybrid',
      });
    }
    return res.json({ success: true, profile });
  } catch (error) {
    console.error('getCareerProfile error:', error);
    return res.status(500).json({ success: false, message: 'Server error retrieving career profile' });
  }
};

// @desc    Update user's Career Profile
// @route   PUT /api/career/profile
// @access  Private
const updateCareerProfile = async (req, res) => {
  try {
    let profile = await CareerProfile.findOne({ userId: req.user.id });
    if (!profile) {
      profile = new CareerProfile({ userId: req.user.id });
    }

    const {
      fullName,
      email,
      phone,
      location,
      headline,
      summary,
      education,
      skills,
      experience,
      projects,
      certifications,
      resumeText,
      resumeFileName,
      resumeUrl,
      linkedinUrl,
      preferredRole,
      preferredLocation,
    } = req.body;

    if (fullName !== undefined) profile.fullName = fullName;
    if (email !== undefined) profile.email = email;
    if (phone !== undefined) profile.phone = phone;
    if (location !== undefined) profile.location = location;
    if (headline !== undefined) profile.headline = headline;
    if (summary !== undefined) profile.summary = summary;
    if (education !== undefined) profile.education = education;
    if (skills !== undefined) profile.skills = Array.isArray(skills) ? skills : skills.split(',').map(s => s.trim()).filter(Boolean);
    if (experience !== undefined) profile.experience = Array.isArray(experience) ? experience : [experience];
    if (projects !== undefined) profile.projects = Array.isArray(projects) ? projects : [projects];
    if (certifications !== undefined) profile.certifications = Array.isArray(certifications) ? certifications : [certifications];
    if (resumeText !== undefined) profile.resumeText = resumeText;
    if (resumeFileName !== undefined) profile.resumeFileName = resumeFileName;
    if (resumeUrl !== undefined) profile.resumeUrl = resumeUrl;
    if (linkedinUrl !== undefined) profile.linkedinUrl = linkedinUrl;
    if (preferredRole !== undefined) profile.preferredRole = preferredRole;
    if (preferredLocation !== undefined) profile.preferredLocation = preferredLocation;

    profile.updatedAt = new Date();
    await profile.save();

    return res.json({ success: true, message: 'Career profile updated successfully', profile });
  } catch (error) {
    console.error('updateCareerProfile error:', error);
    return res.status(500).json({ success: false, message: 'Server error updating career profile' });
  }
};

// @desc    ATS Resume Scanner
// @route   POST /api/career/ats-scan
// @access  Private
const scanResumeAts = async (req, res) => {
  try {
    const { rawContent, fileName } = req.body;
    const text = (rawContent || '').toLowerCase();

    if (!rawContent || rawContent.trim().length === 0) {
      return res.status(400).json({ success: false, message: 'Please provide resume text content to analyze' });
    }

    // Section presence checks
    const hasContact = text.includes('@') || text.includes('phone') || text.includes('email') || text.includes('mobile') || text.includes('+');
    const hasSummary = text.includes('summary') || text.includes('objective') || text.includes('profile') || text.includes('about');
    const hasEducation = text.includes('education') || text.includes('degree') || text.includes('university') || text.includes('college') || text.includes('b.tech') || text.includes('b.e') || text.includes('b.sc') || text.includes('cgpa');
    const hasSkills = text.includes('skills') || text.includes('technologies') || text.includes('competencies') || text.includes('tools');
    const hasExperience = text.includes('experience') || text.includes('work history') || text.includes('internship') || text.includes('employment');
    const hasProjects = text.includes('projects') || text.includes('portfolio') || text.includes('key projects');
    const hasCertifications = text.includes('certifications') || text.includes('certificates') || text.includes('licenses') || text.includes('courses');

    const missingSections = [];
    if (!hasContact) missingSections.push('Contact Details');
    if (!hasSummary) missingSections.push('Professional Summary');
    if (!hasEducation) missingSections.push('Education');
    if (!hasSkills) missingSections.push('Technical Skills');
    if (!hasExperience) missingSections.push('Experience / Internships');
    if (!hasProjects) missingSections.push('Projects');
    if (!hasCertifications) missingSections.push('Certifications');

    const sectionCompletenessScore = Math.round(((7 - missingSections.length) / 7) * 100);

    // Common skills detection
    const catalog = [
      'python', 'java', 'javascript', 'typescript', 'dart', 'flutter', 'react', 'node', 'express',
      'sql', 'mysql', 'mongodb', 'html', 'css', 'git', 'github', 'aws', 'docker', 'rest api',
      'firebase', 'c++', 'c#', 'machine learning', 'data structures', 'algorithms', 'linux', 'figma'
    ];
    const detectedSkills = [];
    catalog.forEach(kw => {
      if (text.includes(kw)) {
        detectedSkills.push(kw.charAt(0).toUpperCase() + kw.slice(1));
      }
    });

    const keywordScore = Math.min(95, Math.max(35, detectedSkills.length * 8));
    const formattingScore = (text.includes('table') || text.includes('column')) ? 68 : 88;
    const contentScore = (hasProjects && hasSkills && hasEducation) ? 90 : 65;
    const readabilityScore = (rawContent.length > 250 && rawContent.length < 4000) ? 92 : 70;

    const overallScore = Math.round(
      (sectionCompletenessScore * 0.25) +
      (keywordScore * 0.25) +
      (formattingScore * 0.20) +
      (contentScore * 0.20) +
      (readabilityScore * 0.10)
    );

    const sectionScores = [
      {
        title: 'Contact Information',
        score: hasContact ? 95 : 30,
        status: hasContact ? 'Good' : 'Needs Improvement',
        feedback: hasContact ? 'Valid contact details detected.' : 'Add your email and phone number at the top of your resume.',
      },
      {
        title: 'Structure & Standard Headings',
        score: missingSections.length <= 1 ? 92 : 65,
        status: missingSections.length <= 1 ? 'Good' : 'Needs Improvement',
        feedback: missingSections.length === 0 ? 'Clear standardized sections detected.' : `Missing sections: ${missingSections.join(', ')}`,
      },
      {
        title: 'Keywords & Competencies',
        score: keywordScore,
        status: keywordScore >= 70 ? 'Good' : 'Needs Improvement',
        feedback: `Identified ${detectedSkills.length} industry technical keywords.`,
      },
      {
        title: 'Projects & Practical Experience',
        score: hasProjects ? 88 : 45,
        status: hasProjects ? 'Good' : 'Needs Improvement',
        feedback: hasProjects ? 'Projects section is clearly delineated.' : 'Add 2-3 technical projects with specific metrics.',
      },
      {
        title: 'Formatting & ATS Parsability',
        score: formattingScore,
        status: formattingScore >= 80 ? 'Good' : 'Needs Improvement',
        feedback: 'Single-column text formatting parses reliably through automated enterprise applicant trackers.',
      },
    ];

    const strengths = [];
    if (detectedSkills.length > 0) strengths.push(`Found ${detectedSkills.length} key technical skills (${detectedSkills.slice(0, 4).join(', ')})`);
    if (hasEducation) strengths.push('Education credentials clearly stated');
    if (hasProjects) strengths.push('Projects section present with project highlights');
    if (hasContact) strengths.push('Contact information easily accessible at top');

    const weaknesses = [];
    if (!text.includes('%') && !text.includes('reduced') && !text.includes('improved') && !text.includes('increased')) {
      weaknesses.add ? weaknesses.add('Missing quantifiable achievements (e.g. "improved latency by 30%")') : weaknesses.push('Missing quantifiable achievements (e.g. "improved latency by 30%")');
    }
    if (detectedSkills.length < 5) {
      weaknesses.push('Technical keyword density could be improved for search indexing');
    }
    if (!hasSummary) {
      weaknesses.push('No professional summary or objective statement detected');
    }

    const recommendations = [
      'Use strong action verbs (Developed, Implemented, Designed, Engineered) at the beginning of each bullet point.',
      'Tailor skills section specifically to the job descriptions you apply to.',
      'Keep formatting in a clean, single-column hierarchy for optimal parsing across Taleo, Workday, and Greenhouse.',
    ];

    // Optionally save resume text to user's CareerProfile
    try {
      await CareerProfile.findOneAndUpdate(
        { userId: req.user.id },
        { resumeText: rawContent, resumeFileName: fileName || 'Uploaded_Resume.pdf', updatedAt: new Date() },
        { upsert: true }
      );
    } catch (e) {
      console.warn('Failed to auto-save resume text to profile:', e.message);
    }

    return res.json({
      success: true,
      analysis: {
        id: Date.now().toString(),
        fileName: fileName || 'Uploaded_Resume.pdf',
        overallScore,
        keywordScore,
        formattingScore,
        contentScore,
        readabilityScore,
        sectionCompletenessScore,
        sectionScores,
        strengths,
        weaknesses,
        missingSections,
        recommendations,
        detectedSkills,
        createdAt: new Date(),
      },
    });
  } catch (error) {
    console.error('scanResumeAts error:', error);
    return res.status(500).json({ success: false, message: 'Server error scanning resume' });
  }
};

// @desc    Match Resume against Job Description
// @route   POST /api/career/job-match
// @access  Private
const matchJobDescription = async (req, res) => {
  try {
    const { resumeText, jobDescription, companyName, jobTitle } = req.body;

    if (!jobDescription || jobDescription.trim().length === 0) {
      return res.status(400).json({ success: false, message: 'Please provide a job description to compare' });
    }

    let candidateText = (resumeText || '').toLowerCase();
    // If resume text wasn't passed directly, look up user's saved profile
    if (!candidateText || candidateText.trim().length === 0) {
      const profile = await CareerProfile.findOne({ userId: req.user.id });
      if (profile) {
        candidateText = `${profile.summary} ${profile.skills.join(' ')} ${profile.experience.join(' ')} ${profile.projects.join(' ')} ${profile.resumeText}`.toLowerCase();
      }
    }

    const jdText = jobDescription.toLowerCase();

    // Skill catalog for matching
    const catalog = [
      'python', 'java', 'javascript', 'typescript', 'dart', 'flutter', 'react', 'node', 'express',
      'sql', 'mysql', 'postgresql', 'mongodb', 'html', 'css', 'git', 'aws', 'docker', 'kubernetes',
      'rest api', 'graphql', 'firebase', 'c++', 'c#', 'machine learning', 'data structures',
      'algorithms', 'agile', 'scrum', 'linux', 'ci/cd', 'testing', 'unit testing'
    ];

    const requiredSkills = catalog.filter(s => jdText.includes(s));
    const matchedSkills = [];
    const missingSkills = [];

    requiredSkills.forEach(skill => {
      const formatted = skill.charAt(0).toUpperCase() + skill.slice(1);
      if (candidateText.includes(skill)) {
        matchedSkills.push(formatted);
      } else {
        missingSkills.push(formatted);
      }
    });

    const total = requiredSkills.length > 0 ? requiredSkills.length : 1;
    let matchScore = Math.round((matchedSkills.length / total) * 100);
    matchScore = Math.min(98, Math.max(25, matchScore));

    const recommendations = [];
    if (missingSkills.length > 0) {
      recommendations.push(`Add these target keywords to your resume if you have experience with them: ${missingSkills.slice(0, 4).join(', ')}.`);
    }
    recommendations.push('Emphasize accomplishments that mirror the main responsibilities mentioned in the job description.');
    recommendations.push('Use the exact phrasing from the job posting in your project and experience bullet points.');

    return res.json({
      success: true,
      match: {
        companyName: companyName || 'Target Company',
        jobTitle: jobTitle || 'Target Role',
        matchScore,
        matchedSkills,
        missingSkills,
        recommendations,
        analysisSummary: `Matched ${matchedSkills.length} of ${requiredSkills.length} detected job requirements (${matchScore}% match score).`,
      },
    });
  } catch (error) {
    console.error('matchJobDescription error:', error);
    return res.status(500).json({ success: false, message: 'Server error matching resume with job' });
  }
};

// @desc    LinkedIn Profile Optimizer
// @route   POST /api/career/linkedin-optimize
// @access  Private
const optimizeLinkedIn = async (req, res) => {
  try {
    const { headline = '', about = '', skills = [] } = req.body;

    const currentHeadline = headline.trim();
    const currentAbout = about.trim();
    const currentSkills = Array.isArray(skills) ? skills : [];

    const headlineLower = currentHeadline.toLowerCase();
    let headlineScore = 60;
    if (currentHeadline.length > 30 && (headlineLower.includes('|') || headlineLower.includes('developer') || headlineLower.includes('engineer'))) {
      headlineScore = 90;
    } else if (currentHeadline.length > 10) {
      headlineScore = 72;
    }

    let aboutScore = currentAbout.length > 180 ? 88 : (currentAbout.length > 60 ? 70 : 45);
    let skillsScore = Math.min(95, Math.max(35, currentSkills.length * 10));
    let overallScore = Math.round((headlineScore * 0.35) + (aboutScore * 0.35) + (skillsScore * 0.30));

    // Suggestions
    const suggestions = [];

    let suggestedHeadline = currentHeadline;
    if (!currentHeadline || currentHeadline.length < 35 || headlineLower.includes('student')) {
      suggestedHeadline = `${currentHeadline.replace(/student/i, 'Computer Science Engineering Graduate')} | Flutter & Full-Stack Developer | Building Scalable Cloud & AI Solutions`;
      suggestions.push({
        field: 'Headline',
        current: currentHeadline || 'Student',
        suggested: suggestedHeadline,
        rationale: 'Including target roles, tech stacks, and domain specialization in the headline boosts recruiter search impressions by up to 70%.',
      });
    }

    let suggestedAbout = currentAbout;
    if (!currentAbout || currentAbout.length < 150) {
      suggestedAbout = `Hi there! I am a passionate software developer specializing in cross-platform mobile engineering with Flutter, Node.js backend systems, and modern cloud technologies.\n\nKey Competencies:\n• Mobile & Full-Stack Development (Flutter, Dart, Node.js, Express, MongoDB)\n• Scalable REST APIs, Cloud Databases & Clean Architecture\n• Problem Solving & Data Structures\n\nI love building impactful digital products that solve real-world problems. Let's connect!`;
      suggestions.push({
        field: 'About / Summary',
        current: currentAbout || 'Short intro',
        suggested: suggestedAbout,
        rationale: 'A structured "About" section with an engaging hook, core skills bullets, and call-to-action keeps recruiters reading.',
      });
    }

    return res.json({
      success: true,
      analysis: {
        overallScore,
        headlineScore,
        aboutScore,
        skillsScore,
        suggestedHeadline,
        suggestedAbout,
        suggestions,
      },
    });
  } catch (error) {
    console.error('optimizeLinkedIn error:', error);
    return res.status(500).json({ success: false, message: 'Server error optimizing LinkedIn profile' });
  }
};

// @desc    AI Cover Letter Generator
// @route   POST /api/career/cover-letter
// @access  Private
const generateCoverLetter = async (req, res) => {
  try {
    const { companyName = '', jobTitle = '', jobDescription = '', tone = 'confident' } = req.body;

    const profile = await CareerProfile.findOne({ userId: req.user.id });
    const candidateName = profile?.fullName || req.user.name || 'Candidate';
    const email = profile?.email || req.user.email || '';
    const phone = profile?.phone || req.user.phone || '';
    const skillsList = profile?.skills?.length ? profile.skills.slice(0, 5).join(', ') : 'Flutter, Full-Stack Development, and Cloud Services';
    const company = companyName.trim() || 'Hiring Team';
    const role = jobTitle.trim() || 'Software Developer';

    let content = '';

    if (tone === 'concise') {
      content = `Dear ${company} Hiring Team,\n\nPlease accept my application for the ${role} position. With hands-on experience in ${skillsList}, I am eager to contribute directly to ${company}'s development roadmap.\n\nThroughout my work, I have focused on building performant software applications, adhering to clean architecture, and delivering user-friendly digital experiences. I am excited by ${company}'s impact in the industry and am confident that my background in modern software engineering aligns well with your team's goals.\n\nThank you for your time and consideration. I welcome the opportunity to discuss my qualifications in detail.\n\nSincerely,\n${candidateName}\n${email} | ${phone}`;
    } else if (tone === 'friendly') {
      content = `Dear ${company} Team,\n\nI was thrilled to see the opening for the ${role} position! As a software engineer passionate about creating smooth, high-impact digital products, I would love the opportunity to bring my enthusiasm for ${skillsList} to your engineering team.\n\nI thrive in fast-paced, collaborative environments and enjoy turning complex challenges into clean, accessible user experiences. What stands out to me about ${company} is your commitment to technical innovation and quality engineering.\n\nI would be excited to connect and explore how my energy and technical background can support your goals.\n\nWarm regards,\n${candidateName}\n${email} | ${phone}`;
    } else if (tone === 'formal') {
      content = `Dear Hiring Manager,\n\nI am writing to formally submit my candidacy for the position of ${role} at ${company}. Having established a comprehensive technical foundation in ${skillsList}, I am well-prepared to uphold your organization's highest standards of software engineering excellence.\n\nMy experience spans end-to-end development, architectural design, and reliable system deployment. The requirements for the ${role} role correspond closely with my professional capabilities, and I am keen to contribute to ${company}'s strategic objectives.\n\nThank you for reviewing my application. I look forward to the privilege of an interview.\n\nRespectfully,\n${candidateName}\n${email} | ${phone}`;
    } else {
      // Confident (Default)
      content = `Dear Hiring Manager at ${company},\n\nI am excited to apply for the ${role} position at ${company}. With proven hands-on experience developing robust applications using ${skillsList}, I am confident in my ability to deliver immediate value to your engineering team.\n\nMy portfolio encompasses full-lifecycle development, responsive cross-platform architectures, and clean API integration. I have consistently delivered scalable features on schedule while maintaining high code quality and test coverage. Joining ${company} represents an exciting opportunity to apply my skills to solve meaningful problems at scale.\n\nI look forward to discussing how my experience and technical mindset can help drive ${company}'s upcoming milestones.\n\nSincerely,\n${candidateName}\n${email} | ${phone}`;
    }

    return res.json({
      success: true,
      coverLetter: {
        companyName: company,
        jobTitle: role,
        tone,
        content,
        createdAt: new Date(),
      },
    });
  } catch (error) {
    console.error('generateCoverLetter error:', error);
    return res.status(500).json({ success: false, message: 'Server error generating cover letter' });
  }
};

// @desc    Get Job Feed & Recommendations
// @route   GET /api/career/jobs
// @access  Private
const getJobsFeed = async (req, res) => {
  try {
    const profile = await CareerProfile.findOne({ userId: req.user.id });
    const userRole = profile?.preferredRole || 'Developer';

    const jobs = [
      {
        id: 'job-1',
        title: 'Junior Flutter & Mobile Developer',
        company: 'Zoho Corporation',
        location: 'Chennai / Coimbatore (Hybrid)',
        salary: '₹6,50,000 - ₹9,00,000 / yr',
        type: 'Full-Time',
        riskLevel: 'SAFE',
        matchScore: 94,
        description: 'Seeking a proactive Flutter developer with strong Dart skills, state management experience (Provider/Bloc), and REST API integration knowledge.',
        requirements: ['Flutter', 'Dart', 'REST API', 'Git', 'Clean Architecture'],
        postedDate: '2 days ago',
        verified: true,
      },
      {
        id: 'job-2',
        title: 'Full-Stack Software Engineer',
        company: 'Freshworks Inc.',
        location: 'Bengaluru / Remote',
        salary: '₹8,00,000 - ₹12,00,000 / yr',
        type: 'Full-Time',
        riskLevel: 'SAFE',
        matchScore: 89,
        description: 'Join our product engineering team to build scalable microservices with Node.js, Express, and modern React/Flutter client interfaces.',
        requirements: ['Node.js', 'Express', 'MongoDB', 'REST API', 'Docker'],
        postedDate: '1 day ago',
        verified: true,
      },
      {
        id: 'job-3',
        title: 'AI & Mobile Application Intern',
        company: 'ThoughtWorks',
        location: 'Coimbatore / Remote',
        salary: '₹35,000 / month Stipend',
        type: 'Internship',
        riskLevel: 'SAFE',
        matchScore: 92,
        description: 'Hands-on internship designing AI-assisted user experiences, computer vision integrations, and high-performance cross-platform applications.',
        requirements: ['Python', 'Flutter', 'Machine Learning Basics', 'Problem Solving'],
        postedDate: 'Just now',
        verified: true,
      },
      {
        id: 'job-4',
        title: 'Associate Cloud & Backend Engineer',
        company: 'TCS Digital',
        location: 'Coimbatore / Kochi / Hybrid',
        salary: '₹7,00,000 - ₹9,50,000 / yr',
        type: 'Full-Time',
        riskLevel: 'SAFE',
        matchScore: 84,
        description: 'Develop enterprise cloud services, security policies, and high-throughput data processing endpoints with Node.js and MongoDB.',
        requirements: ['Node.js', 'SQL', 'MongoDB', 'Cloud Fundamentals', 'Git'],
        postedDate: '3 days ago',
        verified: true,
      },
    ];

    return res.json({
      success: true,
      count: jobs.length,
      jobs,
    });
  } catch (error) {
    console.error('getJobsFeed error:', error);
    return res.status(500).json({ success: false, message: 'Server error retrieving job feed' });
  }
};

// @desc    JobShield AI Assistant Chat
// @route   POST /api/career/ai-chat
// @access  Private
const aiChat = async (req, res) => {
  try {
    const { message } = req.body;
    if (!message || message.trim().length === 0) {
      return res.status(400).json({ success: false, message: 'Please provide a message' });
    }

    const lower = message.toLowerCase().trim();
    let reply = '';
    let category = 'general';

    if (lower.includes('scan') || lower.includes('scam') || lower.includes('fraud') || lower.includes('fake') || lower.includes('telegram') || lower.includes('check')) {
      category = 'fraud_detection';
      reply = '🛡️ **JobShield Fraud Intelligence:**\nTo verify whether a job is safe:\n1. Check if the recruiter communicates from an official domain rather than free webmail (@gmail.com).\n2. Never accept job interviews conducted exclusively via Telegram, WhatsApp, or Google Chat.\n3. Legitimate employers NEVER ask for upfront registration fees, training fees, or send checks to buy equipment.\n\nUse our **Scan Job** feature above to automatically evaluate any job link, screenshot, or recruiter message!';
    } else if (lower.includes('interview') || lower.includes('practice') || lower.includes('coach') || lower.includes('question')) {
      category = 'interview_coach';
      reply = '🎤 **Interview Preparation Advice:**\nHead over to the **Interview Coach** section! We have 5 essential beginner-friendly questions ready for you:\n1. Tell me about yourself.\n2. What are your strengths and weaknesses?\n3. Why should we hire you?\n4. Why are you interested in this job?\n5. Where do you see yourself in five years?\n\nYou can type your answers and receive instant constructive AI feedback and improvement suggestions.';
    } else if (lower.includes('resume') || lower.includes('ats') || lower.includes('cv')) {
      category = 'ats_resume';
      reply = '📄 **ATS Resume Advice:**\nTo maximize your ATS match score:\n• Keep formatting in a clean, single-column layout without tables or text boxes.\n• Use standard headings (Summary, Experience, Education, Technical Skills, Projects).\n• Include quantifiable metrics (e.g. "reduced load time by 35%").\n\nRun your resume through our **ATS Resume Scanner** to get a full compatibility breakdown!';
    } else if (lower.includes('cover letter') || lower.includes('letter')) {
      category = 'cover_letter';
      reply = '✍️ **Cover Letter Guidance:**\nOur **AI Cover Letter Generator** creates tailored letters in 4 distinct tones (Confident, Concise, Friendly, and Formal). It automatically pulls your candidate profile skills and targets the company\'s specific job description!';
    } else if (lower.includes('linkedin') || lower.includes('profile')) {
      category = 'linkedin';
      reply = '💼 **LinkedIn Optimization:**\nA multi-part headline (e.g. "Software Developer | Flutter & Node.js | Building Scalable Systems") improves recruiter search discoverability by over 70%. Check out our **LinkedIn Profile Optimizer** in the Career section to refine your summary and headline!';
    } else if (lower.includes('tracker') || lower.includes('applied') || lower.includes('status')) {
      category = 'tracker';
      reply = '📊 **Application Pipeline:**\nUse the **Job Tracker** to organize your applications across statuses: Applied, Interview, Selected, and Rejected. Your updates persist in the database across refreshes and logins!';
    } else {
      category = 'general';
      reply = `Hello! I am JobShield AI, your recruitment fraud detection and career intelligence assistant.\n\nI can help you with:\n1. 🔍 **Scan a Job**: Detect fraudulent offers, advance-fee scams, and brand impersonation.\n2. 📄 **ATS Scanner & Match**: Optimize your resume for automated applicant tracking systems.\n3. 🎤 **Interview Coach**: Practice the 5 core interview questions with instant feedback.\n4. 📊 **Job Tracker**: Manage your applications pipeline from Applied to Offer.\n\nWhat would you like to explore today?`;
    }

    return res.json({
      success: true,
      reply,
      category,
      timestamp: new Date(),
    });
  } catch (error) {
    console.error('aiChat error:', error);
    return res.status(500).json({ success: false, message: 'Server error processing AI assistant query' });
  }
};

module.exports = {
  getCareerProfile,
  updateCareerProfile,
  scanResumeAts,
  matchJobDescription,
  optimizeLinkedIn,
  generateCoverLetter,
  getJobsFeed,
  aiChat,
};
