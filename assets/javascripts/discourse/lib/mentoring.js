export const MENTORING_OPTIONS = [
  { value: "mentor_connection", label: "Connect with a mentor" },
  { value: "career_coaching", label: "Career coaching / advice" },
  { value: "mentoring_opportunity", label: "Open to mentoring others" },
];

export const MENTORING_LABELS = {
  mentor_connection: "Looking to connect with a mentor",
  career_coaching: "Looking for career coaching / advice",
  mentoring_opportunity: "Open to mentoring others",
};

export const MENTORING_TYPE_OPTIONS = [
  { value: "project_guidance", label: "Project-oriented guidance" },
  { value: "career_orientation", label: "Career orientation" },
  { value: "technical_skills", label: "Technical skill teaching" },
  { value: "workshops", label: "Workshops" },
];

export const MENTORING_TYPE_LABELS = Object.fromEntries(
  MENTORING_TYPE_OPTIONS.map(({ value, label }) => [value, label])
);
