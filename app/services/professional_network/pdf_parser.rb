# frozen_string_literal: true
require "open3"
require "tempfile"

module ProfessionalNetwork
  class PdfParser
    MONTHS = /(?:January|February|March|April|May|June|July|August|September|October|November|December)/i
    DATE_RANGE = /\A(#{MONTHS.source})\s+\d{4}\s*-\s*(?:Present|#{MONTHS.source}\s+\d{4})/i
    ISSUED_DATE = /\AIssued\s+#{MONTHS.source}\s+\d{4}/i

    # Main-body section headings we actively parse into a bucket.
    MAIN_HEADINGS = {
      "Experience" => "experience",
      "Education" => "education",
      "Licenses & Certifications" => "certifications",
    }.freeze

    # Other LinkedIn PDF section headings we don't parse. Seeing one must
    # stop accumulation into whatever section was previously active --
    # otherwise e.g. "Honors & Awards" lines silently leak into Education.
    STOP_HEADINGS = [
      "Honors & Awards",
      "Volunteering",
      "Skills",
      "Recommendations",
      "Courses",
      "Projects",
      "Publications",
      "Languages",
      "Organizations",
      "Patents",
      "Test Scores",
      "Interests",
    ].freeze

    def self.extract_pdf(io)
      Tempfile.create(["professional-profile", ".pdf"]) do |file|
        file.binmode
        IO.copy_stream(io, file)
        file.flush
        out, err, status = Open3.capture3("pdftotext", "-layout", "-nopgbrk", "-enc", "UTF-8", file.path, "-")
        raise ArgumentError, "PDF extraction failed: #{err.to_s[0, 120]}" unless status.success?
        out
      end
    end

    def self.parse(text)
      lines = text.gsub("\r", "").lines.map { |l| l.rstrip }
      # LinkedIn's PDF has a sidebar on the first page. Extract right column
      # independently to prevent certifications being mistaken for employers.
      first_page = lines.take_while { |l| !l.match?(/Page 1 of \d+/) }
      right = first_page.map { |l| l.length > 37 ? l[37..].to_s.strip : "" }.reject(&:empty?)
      left = first_page.map { |l| l[0, 36].to_s.strip }.reject(&:empty?)
      rest = lines.drop(first_page.length + 1).map(&:strip).reject { |l| l.empty? || l.match?(/\APage \d+ of \d+\z/) }
      main = right + rest
      name = right.first.to_s
      headline = right[1..].take_while { |l| l != "Experience" && !l.match?(/\A.+, .+, (Germany|Albania|USA|United States)\z/) }.join(" ")
      location = right.find { |l| l.match?(/,\s*.+,\s*(Germany|Albania|USA|United States)\z/i) }
      linkedin = left.join(" ").match(%r{(?:https?://)?(?:www\.)?linkedin\.com/in/[a-z0-9_-]+}i)&.to_s
      linkedin = linkedin&.sub(/\A(?:https?:\/\/)?/, "https://")
      sections = { "experience" => [], "education" => [], "certifications" => [] }
      current = nil
      main.each do |line|
        if MAIN_HEADINGS.key?(line)
          current = MAIN_HEADINGS[line]
        elsif STOP_HEADINGS.include?(line)
          current = nil
        elsif current
          sections[current] << line
        end
      end
      skills = collect_sidebar(left, "Top Skills", "Certifications")
      certs = (collect_sidebar(left, "Certifications", nil) + parse_certifications(sections["certifications"])).uniq
      {
        "name" => name,
        "headline" => headline,
        "location" => location,
        "linkedin_url" => linkedin,
        "skills" => skills,
        "certifications" => certs,
        "experience" => parse_experience(sections["experience"]),
        "education" => parse_education(sections["education"])
      }
    end

    def self.collect_sidebar(lines, start_heading, end_heading)
      start = lines.index(start_heading)
      return [] unless start
      tail = lines[(start + 1)..]
      tail = tail.take_while { |line| line != end_heading } if end_heading
      tail.reject { |line| line == "Contact" || line.include?("LinkedIn") || line.start_with?("www.") }
    end

    def self.parse_experience(lines)
      # Preserve all source lines for review; split at recognizable date ranges.
      results = []
      lines.each_with_index do |line, i|
        next unless line.match?(DATE_RANGE)
        role = lines[i - 1]
        employer = lines[i - 2]
        next if role.nil? || employer.nil?
        years = line.scan(/\b(?:19|20)\d{2}\b/).map(&:to_i)
        current = line.match?(/Present/i)
        results << {
          "title" => role,
          "organization" => employer,
          "location" => "",
          "start_year" => years.first,
          "end_year" => current ? nil : years.last,
          "is_current" => current,
          "description" => "",
          "needs_review" => true,
        }
      end
      results
    end

    def self.parse_education(lines)
      # Entries are variable-length: a (possibly wrapped) school name,
      # followed by a degree/field line that carries the year range. Anchor
      # each entry on that year-range line instead of assuming a fixed
      # 2-line pair, so a wrapped school name doesn't get split into its
      # own bogus entry.
      entries = []
      chunk = []
      lines.each do |line|
        chunk << line
        next unless line.match?(/\b(?:19|20)\d{2}\b/)
        school = chunk[0..-2].join(" ")
        degree_line = chunk.last
        chunk = []
        next if school.empty?
        years = degree_line.scan(/\b(?:19|20)\d{2}\b/).map(&:to_i)
        degree = degree_line.sub(/\s*\((?:19|20)\d{2}\s*-\s*(?:19|20)\d{2}\)\s*\z/, "")
        entries << {
          "school" => school,
          "degree" => degree,
          "field" => "",
          "start_year" => years.first,
          "end_year" => years.last,
          "needs_review" => true,
        }
      end
      entries
    end

    def self.parse_certifications(lines)
      # Entries are a (possibly wrapped) certification name, an issuing
      # organization, then a fixed "Issued <Month> <Year>" line. Anchor on
      # that line rather than a fixed slice count, so a wrapped name
      # doesn't get split into its own bogus entry.
      entries = []
      chunk = []
      lines.each do |line|
        next if line.match?(/\ACredential ID/i)
        chunk << line
        next unless line.match?(ISSUED_DATE)
        issuer = chunk.length >= 2 ? chunk[-2] : nil
        title = (issuer ? chunk[0..-3] : chunk[0..-2]).join(" ")
        chunk = []
        next if title.empty?
        entries << (issuer ? "#{title} · #{issuer}" : title)
      end
      entries << chunk.join(" ") unless chunk.empty?
      entries
    end
  end
end
