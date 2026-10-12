# frozen_string_literal: true
require "open3"
require "tempfile"

module ProfessionalNetwork
  class PdfParser
    MONTHS = /(?:January|February|March|April|May|June|July|August|September|October|November|December)/i
    DATE_RANGE = /\A(#{MONTHS.source})\s+\d{4}\s*-\s*(?:Present|#{MONTHS.source}\s+\d{4})/i
    HEADINGS = %w[Experience Education Certifications]

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
      sections = { "experience" => [], "education" => [] }
      current = nil
      main.each do |line|
        if line == "Experience"
          current = "experience"
        elsif line == "Education"
          current = "education"
        elsif current
          sections[current] << line
        end
      end
      skills = collect_sidebar(left, "Top Skills", "Certifications")
      certs = collect_sidebar(left, "Certifications", nil)
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
      entries = []
      lines.each_slice(2) do |school, degree_line|
        next if school.to_s.empty?
        years = degree_line.to_s.scan(/\b(?:19|20)\d{2}\b/).map(&:to_i)
        degree = degree_line.to_s.sub(/\s*\((?:19|20)\d{2}\s*-\s*(?:19|20)\d{2}\)\s*\z/, "")
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
  end
end
