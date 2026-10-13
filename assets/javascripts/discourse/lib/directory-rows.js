import { MENTORING_LABELS } from "discourse/plugins/discourse-professional-network/discourse/lib/mentoring";
import {
  AVAILABILITY_LABELS,
  BUSINESS_LABELS,
  EXPERIENCE_LEVEL_LABELS,
} from "discourse/plugins/discourse-professional-network/discourse/lib/options";

const VISIBLE_SKILLS = 4;

export function buildDirectoryRows(profiles) {
  return profiles.map((result) => {
    const profile = result.profile || {};
    const aspirations = result.aspirations || {};
    const skills = profile.skills || [];
    const fieldsOfExpertise = profile.fields_of_expertise || [];

    const badges = [];
    if (result.public_profile === false) {
      badges.push("Unpublished");
    }
    if (profile.open_to_work) {
      badges.push("Open to work");
    }
    if (profile.hiring) {
      badges.push("Hiring");
    }
    if (profile.open_to_collaboration) {
      badges.push("Open to collaboration");
    }
    if (profile.open_to_speaking) {
      badges.push("Available for speaking");
    }
    if (profile.open_to_volunteering) {
      badges.push("Open to volunteering");
    }
    if (profile.open_to_relocation) {
      badges.push("Open to relocation");
    }
    if (profile.open_to_consulting) {
      badges.push("Open to consulting");
    }
    if ((profile.services || []).length) {
      badges.push("Offers services");
    }
    const mentoringInterests = aspirations.mentoring_interests || [];
    if (mentoringInterests.includes("mentoring_opportunity")) {
      badges.push("Mentoring available");
    } else if (mentoringInterests.length) {
      badges.push("Seeking a mentor");
    }
    if ((aspirations.business_interests || []).length) {
      badges.push("Business opportunities");
    }

    const links = [
      profile.linkedin_url && {
        label: "LinkedIn",
        url: profile.linkedin_url,
      },
      profile.website && { label: "Website", url: profile.website },
      profile.github_url && { label: "GitHub", url: profile.github_url },
      profile.twitter_url && {
        label: "X / Twitter",
        url: profile.twitter_url,
      },
      profile.portfolio_url && {
        label: "Portfolio",
        url: profile.portfolio_url,
      },
      profile.calendar_url && {
        label: "Book a meeting",
        url: profile.calendar_url,
      },
      profile.business_username && {
        label: "Business profile",
        url: `/u/${encodeURIComponent(profile.business_username)}`,
      },
    ].filter(Boolean);

    return {
      username: result.username,
      name: profile.name || result.username,
      headline: profile.headline,
      company: profile.company,
      city: profile.city,
      country: profile.country,
      experienceLabel:
        EXPERIENCE_LEVEL_LABELS[profile.experience_level] ||
        profile.experience_level,
      availabilityLabel:
        AVAILABILITY_LABELS[profile.availability] || profile.availability,
      membershipType: profile.membership_type,
      badges,
      visibleSkills: skills.slice(0, VISIBLE_SKILLS),
      hiddenSkillCount: Math.max(skills.length - VISIBLE_SKILLS, 0),
      fieldsOfExpertise,
      timezone: result.timezone,
      about: profile.about,
      industryRole: [profile.current_role, profile.industry]
        .filter(Boolean)
        .join(" · "),
      canHelpWith: profile.can_help_with,
      lookingFor: profile.looking_for,
      idealConnection: profile.ideal_connection,
      languages: profile.languages || [],
      certifications: profile.certifications || [],
      links,
      aspirationField: aspirations.field,
      aspirationSubfield: aspirations.subfield,
      mentoringInterestLabels: (aspirations.mentoring_interests || []).map(
        (value) => MENTORING_LABELS[value] || value
      ),
      businessInterestLabels: (aspirations.business_interests || []).map(
        (value) => BUSINESS_LABELS[value] || value
      ),
    };
  });
}
