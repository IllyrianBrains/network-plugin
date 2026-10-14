# frozen_string_literal: true

require "rails_helper"

# Per AGENTS.md: uploaded PDFs are untrusted input (PdfParser shells out to
# pdftotext), so #create's validation gates -- magic-byte sniffing and the
# size bounds -- are what stand between an arbitrary upload and that shell
# call. These only exercise the gates themselves, not a real PDF parse, so
# they don't depend on pdftotext being installed in the test environment.
RSpec.describe ProfessionalNetwork::ImportsController do
  fab!(:user)

  def pdf_file(content)
    file = Tempfile.new(["profile", ".pdf"])
    file.binmode
    file.write(content)
    file.rewind
    fixture_file_upload(file.path, "application/pdf")
  end

  describe "POST /network/imports.json" do
    it "requires a signed-in member" do
      post "/network/imports.json", params: { file: pdf_file("%PDF-#{"x" * 200}") }

      expect(response.status).to eq(403)
    end

    it "rejects a file whose content doesn't start with the PDF magic bytes" do
      sign_in(user)

      post "/network/imports.json", params: { file: pdf_file("not actually a pdf #{"x" * 200}") }

      expect(response.status).to eq(400)
      expect(ProfessionalNetwork::ImportDraft.where(user_id: user.id)).to be_empty
    end

    it "rejects a file below the minimum size, even with valid magic bytes" do
      sign_in(user)

      post "/network/imports.json", params: { file: pdf_file("%PDF-") }

      expect(response.status).to eq(400)
    end

    it "rejects a file over the configured maximum size" do
      sign_in(user)
      SiteSetting.professional_network_max_pdf_mb = 0

      post "/network/imports.json", params: { file: pdf_file("%PDF-#{"x" * 200}") }

      expect(response.status).to eq(400)
    end
  end

  describe "other actions" do
    let!(:draft) do
      ProfessionalNetwork::ImportDraft.create!(
        user_id: user.id, website_key: "default", status: "pending", data: { "name" => "Ada" },
      )
    end

    it "does not let another member read, update, or confirm someone else's draft" do
      sign_in(Fabricate(:user))

      get "/network/imports/#{draft.id}.json"
      expect(response.status).to eq(404)

      put "/network/imports/#{draft.id}.json", params: { data: { name: "Hijacked" } }
      expect(response.status).to eq(404)

      post "/network/imports/#{draft.id}/confirm.json"
      expect(response.status).to eq(404)

      expect(draft.reload.data["name"]).to eq("Ada")
    end
  end
end
