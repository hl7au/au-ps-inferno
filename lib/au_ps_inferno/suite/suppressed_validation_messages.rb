# frozen_string_literal: true

module AUPSTestKit
  # Known validation messages that are expected and should not fail AU PS tests.
  # Add entries here only once a specific message has been confirmed as a known,
  # acceptable issue (see https://github.com/hl7au/au-ps-inferno/issues/38) —
  # `type` is one of 'error', 'warning', 'info'; `pattern` is matched against the message text.
  module SuppressedValidationMessages
    LIST = [
      {
        type: 'error',
        pattern: %r{Unknown code '[^']+' in the CodeSystem 'http://pbs\.gov\.au/code/item'},
        reason: 'Expected error as the CodeSystem is defined without content included.'
      },
      {
        type: 'warning',
        pattern: /
          (The\ HTML\ fragment\ '(ip-statements|globals-table)\.xhtml'
          |An\ HTML\ fragment\ from\ the\ set\ \[cross-version-analysis\.xhtml,\ cross-version-analysis-inline\.xhtml\])
          \ is\ not\ included\ anywhere\ in\ the\ produced\ implementation\ guide
        /x,
        reason: 'These are warnings for publication artefacts not used in HL7 AU specifications at this time ' \
                'and are accepted by the AU FHIR WG.'
      },
      {
        type: 'warning',
        pattern: %r{
          Found\ multiple\ matching\ profiles\ among\ \d+\ choices:\s
          http://hl7\.org\.au/fhir/StructureDefinition/au-[a-z]+,\s
          http://hl7\.org/fhir/StructureDefinition/(Address|Identifier)
        }x,
        reason: 'INHERITED FROM AU BASE: Artefacts inherit multiple profiles for certain data types ' \
                '(e.g., Address, Identifier). The IG Publisher cannot match example instances to a single ' \
                'profile and generates these warnings. This behaviour is expected and consistent with the ' \
                'design of AU Base.'
      },
      {
        type: 'warning',
        pattern: /Best Practice Recommendation: In general, all observations should have a performer/,
        reason: 'Flags aspects of FHIR implementation of best practice. These warnings do not indicate an ' \
                'error in the specification, and ignore profiled requirements. These warnings were accepted ' \
                'in AU Core v1.0.0.'
      },
      {
        type: 'warning',
        pattern: %r{
          multiple\ different\ potential\ matches\ for\ the\ url\ '
          (http://hl7\.org/fhir/StructureDefinition/individual-recordedSexOrGender
          |http://terminology\.hl7\.org/ValueSet/v2-0092
          |http://terminology\.hl7\.org/ValueSet/v2-0116
          |http://terminology\.hl7\.org/ValueSet/recorded-sex-or-gender-type)'
        }x,
        reason: 'INHERITED FROM AU BASE: AU Base does not pin the version of these standard FHIR extensions ' \
                'sourced from the FHIR Extensions Pack.'
      },
      {
        type: 'warning',
        pattern: /A Reference without an actual reference or identifier should have a display/,
        reason: 'This example demonstrates how to represent missing data and therefore uses the Data Absent ' \
                'Reason extension as per AU Core rules. The IG Publisher triggers a warning because of this, ' \
                'but the example is intentionally designed to show the correct handling of missing data and ' \
                'does not indicate any issues with the IG.'
      },
      {
        type: 'warning',
        pattern: %r{
          Unknown\ code\ '[^']+'\ in\ the\ CodeSystem\ 'http://pbs\.gov\.au/code/item';\s
          The\ provided\ code\ 'http://pbs\.gov\.au/code/item\#[^']+'\ was\ not\ found\ in\ the\ value\ set\s
          'https://healthterminologies\.gov\.au/fhir/ValueSet/australian-medication[^']*'
        }x,
        reason: 'Expected warning as the AU Base PBS CodeSystem is defined without content included.'
      },
      {
        type: 'warning',
        pattern: %r{
          A\ definition\ for\ CodeSystem\ '(http://pbs\.gov\.au/code/item|http://www\.mims\.com\.au/codes)'\s
          could\ not\ be\ found,\ so\ the\ code\ cannot\ be\ validated
        }x,
        reason: 'INHERITED FROM AU BASE: These AU Base CodeSystems referenced do not include any codes in ' \
                'their definition so can not be validated.'
      },
      {
        type: 'warning',
        pattern: %r{
          No\ definition\ could\ be\ found\ for\ URL\ value\ '
          (http://pca\.digitalhealth\.gov\.au/id/pca-healthcare-service
          |http://hl7\.org\.au/id/abn
          |http://ns\.electronichealth\.net\.au/id/hi/hpio/1\.0
          |http://ns\.electronichealth\.net\.au/id/dva
          |http://ns\.electronichealth\.net\.au/id/hi/hpii/1\.0
          |http://ns\.electronichealth\.net\.au/id/medicare-provider-number)'
        }x,
        reason: 'The canonical URL for following identifier types currently resolves to a html page and not ' \
                'a FHIR artefact. See the list of AU Base identifier profiles for the corresponding data ' \
                'type profile.'
      },
      {
        type: 'warning',
        pattern: %r{
          No\ definition\ could\ be\ found\ for\ URL\ value\ '
          http://ns\.electronichealth\.net\.au/id/(hpio|abn)-scoped/
        }x,
        reason: 'Examples of ABN or HPIO scoped identifier system URLs do not have formal definition as ' \
                'they are examples.'
      },
      {
        type: 'warning',
        pattern: %r{
          Unable\ to\ check\ whether\ the\ code\ is\ in\ the\ value\ set\s
          'http://terminology\.hl7\.org\.au/ValueSet/(pbs-item|mims)\|[^']*'\s
          because\ the\ code\ system\ http://snomed\.info/sct\ was\ not\ found
        }x,
        reason: 'INHERITED FROM AU BASE: Example codes are tested against bound terminology (MIMS/PBS). ' \
                'These AU Base CodeSystems referenced do not include any codes in their definition so can ' \
                'not be validated.'
      },
      {
        type: 'warning',
        pattern: %r{
          Resolved\ system\ http://pbs\.gov\.au/code/item\ \([^)]*\),\ but\ the\ definition\ doesn't\ include\s
          any\ codes,\ so\ the\ code\ has\ not\ been\ validated
        }x,
        reason: 'INHERITED FROM AU BASE: Example codes are tested against bound terminology (MIMS/PBS). ' \
                'These AU Base CodeSystems referenced do not include any codes in their definition so can ' \
                'not be validated.'
      },
      {
        type: 'warning',
        pattern: %r{
          Unable\ to\ check\ whether\ the\ code\ is\ in\ the\ value\ set\s
          'http://terminology\.hl7\.org\.au/ValueSet/pbs-item\|[^']*'\s
          because\ the\ code\ system\ http://pbs\.gov\.au/code/item\ was\ not\ found
        }x,
        reason: 'INHERITED FROM AU BASE: Example codes from the code systems supplied are tested against an ' \
                "example binding terminology. IG publisher identifies this as '' (no ValueSet); and the " \
                'code can not be validated.'
      },
      {
        type: 'warning',
        pattern: %r{
          The\ provided\ code\ 'http://snomed\.info/sct\#\d+'\ was\ not\ found\ in\ the\ value\ set\s
          'http://hl7\.org/fhir/ValueSet/observation-vitalsignresult\|[^']*'
        }x,
        reason: 'Example intentionally demonstrates inclusion of an allowed value that is not part of the ' \
                'defined slices.'
      },
      {
        type: 'warning',
        pattern: %r{No definition could be found for URL value 'mllp://[^']*\.example\.com[^']*'},
        reason: 'Examples of Endpoint address URLs do not have formal definition as they are examples.'
      },
      {
        type: 'warning',
        pattern: %r{
          Unable\ to\ check\ whether\ the\ code\ is\ in\ the\ value\ set\s
          'http://terminology\.hl7\.org\.au/ValueSet/v3-ServiceDeliveryLocationRoleType-extended\|[^']*'\s
          because\ the\ code\ system\ (http://terminology\.hl7\.org/CodeSystem/v3-RoleCode|http://snomed\.info/sct)\s
          was\ not\ found
        }x,
        reason: 'This is a tooling environment warning indicating the ValueSet and CodeSystem cannot be ' \
                'found in tx.hl7.org.au. Resolution in tx.hl7.org.au is in progress.'
      },
      {
        type: 'warning',
        pattern: %r{
          A\ definition\ for\ CodeSystem\ '(http://terminology\.hl7\.org/CodeSystem/v3-RoleCode|http://snomed\.info/sct)'\s
          version\ 'null'\ could\ not\ be\ found,\ so\ the\ code\ cannot\ be\ validated\.\ Valid\ versions:
        }x,
        reason: 'This is a tooling environment warning indicating the ValueSet and CodeSystem cannot be ' \
                'found in tx.hl7.org.au. Resolution in tx.hl7.org.au is in progress.'
      },
      {
        type: 'info',
        pattern: %r{Reference to draft ValueSet http://hl7\.org/fhir/ValueSet/(device-action|condition-severity)\|4\.0\.1},
        reason: 'INHERITED FROM FHIR STANDARD: Some FHIR standard ValueSets are published as draft.'
      },
      {
        type: 'info',
        pattern: %r{Reference to deprecated ValueSet http://hl7\.org/fhir/5\.0/ValueSet/jurisdiction\|5\.0\.0},
        reason: 'INHERITED FROM FHIR STANDARD: Some FHIR standard ValueSets are deprecated.'
      },
      {
        type: 'info',
        pattern: /The discriminator type 'pattern' is deprecated in R5\+/,
        reason: 'These issues are known FHIR standard and Extension Pack future version and current ' \
                'deprecations.'
      },
      {
        type: 'info',
        pattern: %r{
          The\ extension\ http://hl7\.org/fhir/StructureDefinition/(elementdefinition-maxValueSet|regex)\|\S*\s
          is\ deprecated
        }x,
        reason: 'These issues are known FHIR standard and Extension Pack future version and current ' \
                'deprecations.'
      },
      {
        type: 'info',
        pattern: %r{
          This\ element\ does\ not\ match\ any\ known\ slice\ defined\ in\ the\ profile\s
          http://hl7\.org\.au/fhir/core/StructureDefinition/au-core-(patient|practitionerrole)\|
        }x,
        reason: 'Example intentionally demonstrates inclusion of an allowed value that is not part of the ' \
                'defined slices.'
      },
      {
        type: 'info',
        pattern: %r{
          This\ element\ does\ not\ match\ any\ known\ slice\ defined\ in\ the\ profile\s
          http://hl7\.org\.au/fhir/core/StructureDefinition/au-core-smokingstatus\|
        }x,
        reason: 'Generated due to the profile approach that mixes slice and pattern. The AU Core profile ' \
                'is valid and the code is valid according to the profile but is defined using pattern and ' \
                'is outside the slice definition.'
      },
      {
        type: 'info',
        pattern: %r{
          This\ element\ does\ not\ match\ any\ known\ slice\ defined\ in\ the\ profile\s
          (http://hl7\.org/fhir/StructureDefinition/bp\|4\.0\.1
          |http://hl7\.org\.au/fhir/core/StructureDefinition/au-core-heartrate\|)
        }x,
        reason: 'Generated due to inherited slicing in the base profile. The AU Core profile remains valid ' \
                'without redeclaring the slicing discriminator.'
      },
      {
        type: 'info',
        pattern: %r{
          This\ element\ does\ not\ match\ any\ known\ slice\ defined\ in\ the\ profile\s
          http://hl7\.org/fhir/StructureDefinition/capabilitystatement-search-parameter-combination\|
        }x,
        reason: 'Information about the use of standard CapabilityStatementExpectation extension in ' \
                'additional contexts to fully express intended capabilities; see FHIR-12419.'
      },
      {
        type: 'info',
        pattern: %r{
          This\ element\ does\ not\ match\ any\ known\ slice\ defined\ in\ the\ profile\s
          http://hl7\.org/fhir/StructureDefinition/obligation\|
        }x,
        reason: 'The use of the obligation extension generates multiple slicing information messages in ' \
                'the snapshot. This extension is reused across many resources leading to repeated ' \
                'validation messages that do not appear to indicate an actual problem. Other IGs that are ' \
                'using obligations (e.g. IPS, IPA, EPS) show the same set of QA "element does not match any ' \
                'known slice" slicing information messages that have been accepted for publication.'
      },
      {
        type: 'info',
        pattern: /
          The\ string\ value\ contains\ text\ that\ looks\ like\ embedded\ HTML\ tags\.\ If\ this\ content\ is\s
          rendered\ to\ HTML\ without\ appropriate\ post-processing,\ it\ may\ be\ a\ security\ risk
        /x,
        reason: 'INHERITED FROM FHIR STANDARD: Generated due to the FHIR R4 MedicationDispense mapping for ' \
                'v2 - daysSupply, which contains a string resembling embedded HTML tags.'
      },
      {
        type: 'info',
        pattern: /
          None\ of\ the\ codings\ provided\ are\ in\ the\ value\ set\ .*\s
          and\ a\ coding\ is\ recommended\ to\ come\ from\ this\ value\ set
        /x,
        reason: 'The tooling is generating messages when a code is not present in all slices or all ' \
                'additional bindings. This message is generated even where the code is valid against the ' \
                'profile binding rules.'
      },
      {
        type: 'info',
        pattern: /could usefully have an OID assigned \(OIDs are easy to assign/,
        reason: 'The IG Publisher automatically generates this information for resources without an OID. ' \
                'It is not required and does not indicate an issue with the IPS content.'
      }
    ].freeze
  end
end
