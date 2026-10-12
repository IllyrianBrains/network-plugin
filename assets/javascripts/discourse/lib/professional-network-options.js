function labelsFor(options) {
  return Object.fromEntries(options.map(({ value, label }) => [value, label]));
}

export const AVAILABILITY_OPTIONS = [
  { value: "full_time", label: "Available full-time" },
  { value: "part_time", label: "Available part-time / side projects" },
  { value: "not_available", label: "Not currently available" },
];

export const BUSINESS_OPTIONS = [
  { value: "cofounder_intro", label: "Introduction to a co-founder" },
  {
    value: "client_partner_intro",
    label: "Introduction to clients / partners",
  },
  { value: "job_opportunities", label: "Job opportunities" },
  { value: "hiring_candidates", label: "Candidates to hire" },
  { value: "project_funding", label: "Funding for a project / business" },
  { value: "investment_opportunities", label: "Investment opportunities" },
];

export const CONTACT_OPTIONS = [
  { value: "discourse", label: "Discourse message" },
  { value: "linkedin", label: "LinkedIn message" },
  { value: "email", label: "Email" },
];

export const EXPERIENCE_LEVEL_OPTIONS = [
  { value: "student", label: "Student" },
  { value: "junior", label: "Junior (1–3 years)" },
  { value: "mid", label: "Mid-level (4–6 years)" },
  { value: "senior", label: "Senior (7–10 years)" },
  { value: "expert", label: "Expert (10+ years)" },
];

export const MEETING_OPTIONS = [
  { value: "online", label: "Online" },
  { value: "in_person", label: "In person" },
  { value: "either", label: "Online or in person" },
];

export const RETURN_COUNTRY_OPTIONS = [
  { value: "albania", label: "Albania" },
  { value: "kosovo", label: "Kosovo" },
];

export const RETURN_PLAN_OPTIONS = [
  { value: "yes", label: "Yes" },
  { value: "maybe", label: "Maybe, later" },
  { value: "no", label: "Not for now" },
  { value: "already_there", label: "Already living there" },
];

export const AVAILABILITY_LABELS = labelsFor(AVAILABILITY_OPTIONS);
export const BUSINESS_LABELS = labelsFor(BUSINESS_OPTIONS);
export const CONTACT_LABELS = labelsFor(CONTACT_OPTIONS);
export const EXPERIENCE_LEVEL_LABELS = labelsFor(EXPERIENCE_LEVEL_OPTIONS);
export const MEETING_LABELS = labelsFor(MEETING_OPTIONS);
