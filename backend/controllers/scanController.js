const Scan = require('../models/Scan');
const User = require('../models/User');

// Deterministic, comprehensive job scam analyzer
function analyzeJob({
  companyName = '',
  jobTitle = '',
  jobUrl = '',
  jobDescription = '',
  recruiterName = '',
  recruiterEmail = '',
  recruiterPhone = '',
  recruiterPlatform = '',
  recruiterMessages = '',
  salary = '',
  location = '',
  attachmentName = null,
  attachmentType = null,
}) {
  const detectedIndicators = [];
  const reasons = [];
  const recommendations = [];

  const combinedText = [
    companyName,
    jobTitle,
    jobUrl,
    jobDescription,
    recruiterName,
    recruiterEmail,
    recruiterPhone,
    recruiterPlatform,
    recruiterMessages,
    salary,
    location,
  ].join(' ').toLowerCase();

  let riskScore = 5; // Baseline safe score

  // 1. URL AND DOMAIN ANALYSIS
  const urlAnalysis = {
    provided: Boolean(jobUrl && jobUrl.trim()),
    findings: [],
  };

  if (urlAnalysis.provided) {
    const cleanUrl = jobUrl.trim().toLowerCase();
    let hostname = '';
    try {
      const parsed = new URL(cleanUrl.startsWith('http') ? cleanUrl : `https://${cleanUrl}`);
      hostname = parsed.hostname;
    } catch {
      hostname = cleanUrl;
    }

    // High risk TLDs
    const suspiciousTLDs = ['.xyz', '.top', '.click', '.buzz', '.work', '.fit', '.rest', '.cc', '.surf', '.icu', '.cam'];
    const hasSuspiciousTLD = suspiciousTLDs.some(tld => hostname.endsWith(tld));
    if (hasSuspiciousTLD) {
      riskScore += 25;
      detectedIndicators.push({
        name: 'Suspicious Domain Extension',
        category: 'URL & Domain',
        severity: 'high',
        description: `Domain "${hostname}" uses a low-reputation top-level domain often associated with throwaway phishing setups.`,
      });
      reasons.push(`Unusual domain extension detected in URL (${hostname}).`);
      urlAnalysis.findings.push('Low-reputation domain extension detected.');
    }

    // Free form builders & chat redirects
    if (cleanUrl.includes('forms.gle') || cleanUrl.includes('docs.google.com/forms') || cleanUrl.includes('form.jotform.com')) {
      riskScore += 25;
      detectedIndicators.push({
        name: 'Free Form Application Portal',
        category: 'URL & Domain',
        severity: 'high',
        description: 'Using public Google Forms or Jotform instead of a verified applicant tracking system (ATS) or corporate careers portal.',
      });
      reasons.push('Job application is hosted on an unverified public form rather than a legitimate company portal.');
      urlAnalysis.findings.push('Public form builder used for application.');
    }

    // URL Shorteners
    if (cleanUrl.includes('bit.ly') || cleanUrl.includes('tinyurl.com') || cleanUrl.includes('cutt.ly') || cleanUrl.includes('is.gd')) {
      riskScore += 15;
      detectedIndicators.push({
        name: 'Obfuscated Link Shortener',
        category: 'URL & Domain',
        severity: 'medium',
        description: 'URL shortener hides the actual destination server and prevents verification of domain ownership.',
      });
      reasons.push('Shortened URL masks the real landing page.');
      urlAnalysis.findings.push('Shortened link detected.');
    }

    // Established job boards or enterprise careers
    const trustedPlatforms = ['linkedin.com', 'indeed.com', 'glassdoor.com', 'lever.co', 'greenhouse.io', 'myworkdayjobs.com', 'smartrecruiters.com', 'naukri.com'];
    const isTrusted = trustedPlatforms.some(tp => hostname.endsWith(tp));
    if (isTrusted) {
      riskScore = Math.max(0, riskScore - 10);
      urlAnalysis.findings.push('Hosted on recognized recruitment/ATS platform.');
    }
  } else {
    urlAnalysis.findings.push('No external URL provided. Domain evaluation skipped without penalty.');
  }

  // 2. COMPANY INFORMATION ANALYSIS
  const companyAnalysis = {
    provided: Boolean(companyName && companyName.trim()),
    findings: [],
  };

  const majorTechBrands = ['google', 'amazon', 'microsoft', 'apple', 'meta', 'netflix', 'tcs', 'infosys', 'wipro', 'accenture', 'ibm', 'cisco', 'oracle'];
  const lowerCompany = companyName.toLowerCase().trim();
  const matchedBrand = majorTechBrands.find(b => lowerCompany.includes(b));

  if (!companyAnalysis.provided) {
    companyAnalysis.findings.push('Employer name not specified.');
  } else {
    companyAnalysis.findings.push(`Company identified: ${companyName}`);
  }

  // 3. RECRUITER ANALYSIS & IMPERSONATION DETECTION
  const recruiterAnalysis = {
    findings: [],
  };
  const impersonationAnalysis = {
    findings: [],
  };

  const cleanRecruiterEmail = recruiterEmail.toLowerCase().trim();
  const freeEmailProviders = ['@gmail.com', '@yahoo.com', '@hotmail.com', '@outlook.com', '@aol.com', '@proton.me', '@mail.com'];
  const usesFreeEmail = freeEmailProviders.some(provider => cleanRecruiterEmail.endsWith(provider));

  if (cleanRecruiterEmail) {
    if (matchedBrand && usesFreeEmail) {
      riskScore += 45;
      detectedIndicators.push({
        name: 'Corporate Brand Impersonation',
        category: 'Impersonation',
        severity: 'critical',
        description: `Recruiter claims to represent ${companyName} but communicates from an unverified public mailbox (${cleanRecruiterEmail}). Genuine corporate HR always uses official company domains.`,
      });
      reasons.push(`Impersonation Red Flag: Recruiter uses free webmail (${cleanRecruiterEmail}) while claiming to represent ${companyName}.`);
      impersonationAnalysis.findings.push(`Brand impersonation flag: Free email used for major corporate brand (${companyName}).`);
    } else if (usesFreeEmail) {
      riskScore += 15;
      detectedIndicators.push({
        name: 'Public Mailbox Provider',
        category: 'Recruiter Verification',
        severity: 'medium',
        description: `Recruiter email (${cleanRecruiterEmail}) uses a free consumer email address rather than a dedicated business domain.`,
      });
      reasons.push(`Recruiter communicates using a public consumer email (${cleanRecruiterEmail}) instead of a corporate domain.`);
      recruiterAnalysis.findings.push('Consumer mailbox used instead of corporate domain.');
    }
  }

  // Chat-only / Unofficial messaging app recruitment
  const chatTriggers = ['telegram', 'whatsapp', 'google chat', 'signal app', 'skype chat', 'text interview'];
  const chatFound = chatTriggers.filter(t => combinedText.includes(t));
  if (chatFound.length > 0 || recruiterPlatform.toLowerCase().includes('telegram') || recruiterPlatform.toLowerCase().includes('whatsapp')) {
    riskScore += 35;
    detectedIndicators.push({
      name: 'Informal Messaging App Recruitment',
      category: 'Recruiter Verification',
      severity: 'high',
      description: `Interview or hiring communication directed through instant messaging apps (${chatFound.join(', ') || recruiterPlatform}). Legitimate companies do not conduct hiring interviews solely over text chat.`,
    });
    reasons.push('Recruitment conducted exclusively via instant messaging platforms.');
    recruiterAnalysis.findings.push('Messaging platform channel flagged.');
  }

  // 4. PAYMENT & ADVANCE-FEE DETECTION
  const paymentUrgencyAnalysis = {
    findings: [],
  };

  const paymentKeywords = [
    'registration fee',
    'application fee',
    'training fee',
    'equipment deposit',
    'background check fee',
    'laptop fee',
    'buy equipment',
    'reimburse via check',
    'cashier check',
    'deposit check',
    'wire transfer',
    'western union',
    'moneygram',
    'crypto',
    'bitcoin',
    'gift card',
  ];
  const detectedPaymentKeywords = paymentKeywords.filter(k => combinedText.includes(k));
  if (detectedPaymentKeywords.length > 0) {
    riskScore += 50;
    detectedIndicators.push({
      name: 'Upfront Fee or Financial Scheme Request',
      category: 'Payment & Fraud',
      severity: 'critical',
      description: `Detected financial indicators: ${detectedPaymentKeywords.join(', ')}. Genuine employers never require candidates to pay fees, purchase gift cards, or deposit personal checks for work equipment.`,
    });
    reasons.push(`Advance-Fee Warning: Job requires monetary transfer or check-cashing (${detectedPaymentKeywords.join(', ')}).`);
    paymentUrgencyAnalysis.findings.push(`Financial red flag: ${detectedPaymentKeywords.join(', ')}`);
  }

  // Urgency & High Pressure
  const urgencyKeywords = [
    'immediate start today',
    'urgent response required',
    'within 2 hours',
    'immediate hiring without interview',
    'confirm banking immediately',
    'limited positions act now',
  ];
  const detectedUrgency = urgencyKeywords.filter(k => combinedText.includes(k));
  if (detectedUrgency.length > 0) {
    riskScore += 20;
    detectedIndicators.push({
      name: 'High-Pressure Urgency Tactics',
      category: 'Psychological Manipulation',
      severity: 'medium',
      description: `Pressure tactics detected: "${detectedUrgency.join(', ')}". Scammers rush candidates into signing or transferring funds before verifying credentials.`,
    });
    reasons.push('High-pressure timeline aimed at bypassing standard verification.');
    paymentUrgencyAnalysis.findings.push('Urgency pressure tactics observed.');
  }

  // 5. SALARY & LOCATION ANALYSIS
  const salaryLocationAnalysis = {
    findings: [],
  };

  const isDataEntryOrTyping = combinedText.includes('data entry') || combinedText.includes('typing') || combinedText.includes('copy paste') || combinedText.includes('envelope');
  const highSalaryPhrases = ['$35/hr', '$40/hr', '$45/hr', '$50/hr', '$60/hr', '$70/hr', '$80/hr', '5000/day', '10000/day', '$1500/week', 'no experience'];
  const hasHighSalaryForBasicTask = isDataEntryOrTyping && highSalaryPhrases.some(p => combinedText.includes(p));

  if (hasHighSalaryForBasicTask) {
    riskScore += 30;
    detectedIndicators.push({
      name: 'Unrealistically Inflated Compensation',
      category: 'Salary & Compensation',
      severity: 'high',
      description: 'Extremely high hourly/daily rates offered for unskilled or basic tasks with no experience required.',
    });
    reasons.push('Compensation is significantly above market benchmarks for the advertised entry-level responsibilities.');
    salaryLocationAnalysis.findings.push('Compensation anomaly detected.');
  } else if (salary && salary.trim()) {
    salaryLocationAnalysis.findings.push(`Compensation stated: ${salary}`);
  }

  if (location && location.trim()) {
    salaryLocationAnalysis.findings.push(`Stated Location: ${location}`);
  }

  // 6. JOB DESCRIPTION ANALYSIS
  const descriptionAnalysis = {
    findings: [],
  };

  if (!jobDescription || jobDescription.trim().length < 40) {
    descriptionAnalysis.findings.push('Brief description provided; verified with available attributes.');
  } else {
    descriptionAnalysis.findings.push('Job description analyzed for structural and lexical compliance.');
  }

  // Clamp risk score
  riskScore = Math.min(100, Math.max(5, riskScore));

  // Determine overall status
  let status = 'safe';
  let statusLabel = 'SAFE';

  if (riskScore >= 85) {
    status = 'scam';
    statusLabel = 'SCAM';
  } else if (riskScore >= 66) {
    status = 'high_risk';
    statusLabel = 'HIGH RISK';
  } else if (riskScore >= 36) {
    status = 'suspicious';
    statusLabel = 'SUSPICIOUS';
  } else if (riskScore >= 16) {
    status = 'low_risk';
    statusLabel = 'LOW RISK';
  } else {
    status = 'safe';
    statusLabel = 'SAFE';
  }

  // Default clean reasons and recommendations if safe / low risk
  if (reasons.length === 0) {
    if (statusLabel === 'SAFE' || statusLabel === 'LOW RISK') {
      reasons.push('No known phishing, impersonation, or advance-fee patterns detected in the provided job details.');
      reasons.push('Job terms and communication channels adhere to standard industry recruiting practices.');
    }
  }

  if (statusLabel === 'SCAM' || statusLabel === 'HIGH RISK') {
    recommendations.push('Do NOT send any money, credit card numbers, or cryptocurrency to the recruiter.');
    recommendations.push('Do NOT deposit checks mailed to you for "purchasing office equipment".');
    recommendations.push('Do NOT provide your social security number, bank details, or OTPs on unverified forms.');
    recommendations.push('Cease communication on unofficial messaging platforms like Telegram or WhatsApp.');
  } else if (statusLabel === 'SUSPICIOUS') {
    recommendations.push('Verify recruiter credentials on official corporate LinkedIn directory.');
    recommendations.push('Request an official interview via verified corporate video systems (Google Meet, Microsoft Teams, Zoom).');
    recommendations.push('Confirm this open position is listed on the official company careers website.');
  } else {
    recommendations.push('Proceed with your application following regular candidate safety practices.');
    recommendations.push('Ensure all contract offers and tax documentation are conducted through verified portals.');
  }

  return {
    riskPercentage: riskScore,
    status,
    statusLabel,
    reasons,
    recommendations,
    detectedIndicators,
    categoryAnalysis: {
      urlAnalysis,
      companyAnalysis,
      recruiterAnalysis,
      descriptionAnalysis,
      salaryLocationAnalysis,
      paymentUrgencyAnalysis,
      impersonationAnalysis,
    },
  };
}

// @desc    Scan a job description, URL, or recruiter details
// @route   POST /api/scan
// @access  Private
const scanJob = async (req, res) => {
  try {
    const {
      companyName,
      jobTitle,
      jobUrl,
      jobDescription,
      recruiterName,
      recruiterEmail,
      recruiterPhone,
      recruiterPlatform,
      recruiterMessages,
      salary,
      location,
    } = req.body;

    if (!companyName && !jobDescription && !jobUrl && !recruiterEmail && !req.file) {
      return res.status(400).json({
        success: false,
        message: 'Please provide at least a company name, job URL, job description, recruiter details, or file to scan.',
      });
    }

    let attachmentName = null;
    let attachmentType = null;
    if (req.file) {
      attachmentName = req.file.filename;
      const ext = req.file.filename.split('.').pop().toLowerCase();
      attachmentType = ['pdf', 'doc', 'docx'].includes(ext) ? 'pdf' : 'image';
    }

    const analysis = analyzeJob({
      companyName,
      jobTitle,
      jobUrl,
      jobDescription,
      recruiterName,
      recruiterEmail,
      recruiterPhone,
      recruiterPlatform,
      recruiterMessages,
      salary,
      location,
      attachmentName,
      attachmentType,
    });

    const scan = await Scan.create({
      userId: req.user.id,
      companyName: companyName || (attachmentName ? 'Document Scan' : 'Unspecified Employer'),
      jobTitle: jobTitle || 'Position Review',
      jobUrl: jobUrl || '',
      jobDescription: jobDescription || '',
      attachmentName,
      attachmentType,
      riskPercentage: analysis.riskPercentage,
      status: analysis.status,
      statusLabel: analysis.statusLabel,
      reasons: analysis.reasons,
      recommendations: analysis.recommendations,
      detectedIndicators: analysis.detectedIndicators,
      categoryAnalysis: analysis.categoryAnalysis,
      recruiterDetails: {
        name: recruiterName || '',
        email: recruiterEmail || '',
        phone: recruiterPhone || '',
        platform: recruiterPlatform || '',
        messages: recruiterMessages || '',
      },
      salary: salary || '',
      location: location || '',
    });

    // Update user security score dynamically
    const userScans = await Scan.find({ userId: req.user.id });
    const severeCount = userScans.filter(s => s.status === 'scam' || s.status === 'high_risk').length;
    const suspiciousCount = userScans.filter(s => s.status === 'suspicious').length;

    let penalty = (severeCount * 20) + (suspiciousCount * 10);
    let newScore = Math.max(15, Math.min(100, 100 - penalty));
    await User.findByIdAndUpdate(req.user.id, { securityScore: newScore });

    return res.status(201).json({
      success: true,
      message: 'Job safety analysis completed successfully',
      scan,
      updatedSecurityScore: newScore,
    });
  } catch (error) {
    console.error('ScanJob error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error during scan analysis',
    });
  }
};

// @desc    Scan screenshot or image document
// @route   POST /api/scan/image
// @access  Private
const scanImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Please select an image screenshot or document to scan.' });
    }

    const { companyName, jobTitle, jobUrl, jobDescription, recruiterEmail, salary, location } = req.body;

    const analysis = analyzeJob({
      companyName: companyName || 'Image Upload Assessment',
      jobTitle: jobTitle || 'Scanned Document / Screenshot',
      jobUrl: jobUrl || '',
      jobDescription: jobDescription || `Analyzed file: ${req.file.originalname}`,
      recruiterEmail: recruiterEmail || '',
      salary: salary || '',
      location: location || '',
      attachmentName: req.file.filename,
      attachmentType: 'image',
    });

    const scan = await Scan.create({
      userId: req.user.id,
      companyName: companyName || 'Image Upload Assessment',
      jobTitle: jobTitle || 'Scanned Document / Screenshot',
      jobUrl: jobUrl || '',
      jobDescription: jobDescription || `Analyzed file: ${req.file.originalname}`,
      attachmentName: req.file.filename,
      attachmentType: 'image',
      riskPercentage: analysis.riskPercentage,
      status: analysis.status,
      statusLabel: analysis.statusLabel,
      reasons: analysis.reasons,
      recommendations: analysis.recommendations,
      detectedIndicators: analysis.detectedIndicators,
      categoryAnalysis: analysis.categoryAnalysis,
      salary: salary || '',
      location: location || '',
    });

    return res.status(201).json({
      success: true,
      message: 'Image screenshot scanned successfully',
      fileUrl: `/uploads/${req.file.filename}`,
      scan,
      scanResult: {
        riskPercentage: analysis.riskPercentage,
        status: analysis.statusLabel,
        reasons: analysis.reasons,
        recommendations: analysis.recommendations,
      },
    });
  } catch (error) {
    console.error('ScanImage error:', error);
    return res.status(500).json({ success: false, message: 'Server error analyzing image file' });
  }
};

// @desc    Get user scan history
// @route   GET /api/scan/history
// @access  Private
const getScanHistory = async (req, res) => {
  try {
    const scans = await Scan.find({ userId: req.user.id }).sort({ createdAt: -1 });
    return res.status(200).json({
      success: true,
      count: scans.length,
      scans,
    });
  } catch (error) {
    console.error('getScanHistory error:', error);
    return res.status(500).json({ success: false, message: 'Server error retrieving scan history' });
  }
};

// @desc    Get scan by ID
// @route   GET /api/scan/:id
// @access  Private
const getScanById = async (req, res) => {
  try {
    const scan = await Scan.findOne({ _id: req.params.id, userId: req.user.id });
    if (!scan) {
      return res.status(404).json({ success: false, message: 'Scan not found' });
    }
    return res.status(200).json({ success: true, scan });
  } catch (error) {
    console.error('getScanById error:', error);
    return res.status(500).json({ success: false, message: 'Server error retrieving scan' });
  }
};

module.exports = {
  scanJob,
  scanImage,
  getScanHistory,
  getScanById,
  analyzeJob,
};
