# frozen_string_literal: true

# The 7 published AU PS example bundles vendored by scripts/fetch_example_bundles.rb
# into spec/fixtures/bundles/examples/, shared across all spec/regression/ specs.
module RegressionBundleCases
  FIXTURES_DIR = File.expand_path('../../fixtures/bundles/examples', __dir__).freeze

  ALL = [
    { name: 'aups-basicsummary',
      file: 'aups-basicsummary.json',
      url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-basicsummary.json' },
    { name: 'aups-gpvisit-retrieval',
      file: 'aups-gpvisit-retrieval.json',
      url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-gpvisit-retrieval.json' },
    { name: 'aups-noknownx',
      file: 'aups-noknownx.json',
      url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-noknownx.json' },
    { name: 'aups-patient-story',
      file: 'aups-patient-story.json',
      url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-patient-story.json' },
    { name: 'aups-referral-endoconsult-autogen',
      file: 'aups-referral-endoconsult-autogen.json',
      url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-referral-endoconsult-autogen.json' },
    { name: 'aups-referral-endoconsult-curated',
      file: 'aups-referral-endoconsult-curated.json',
      url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-referral-endoconsult-curated.json' },
    { name: 'aups-section-emptyreason',
      file: 'aups-section-emptyreason.json',
      url: 'https://build.fhir.org/ig/hl7au/au-fhir-ps/Bundle-aups-section-emptyreason.json' }
  ].freeze

  def self.fixture_path(filename)
    File.join(FIXTURES_DIR, filename)
  end
end
