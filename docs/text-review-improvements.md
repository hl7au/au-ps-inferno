# AU PS Inferno — Test Text & UI Review

This note records the analysis of the consultant's wording review (`PS Inferno Text Review.xlsx`,
sheets **Bundle Validation** and **Bundle and Composition MS**), the general patterns extracted from
it, and how those patterns were extrapolated to the remaining sheets and implemented in code.

## Where the text lives

- **Group / test titles and descriptions** — `lib/au_ps_inferno/generator/suite_structure/definitions.rb`
  and `lib/au_ps_inferno/generator/test_config_registry/entries.rb`. These are inlined into the
  generated suite, so the suite must be regenerated (`make generate`) after changing them.
- **Result messages and statuses (info / warning / error / skip / omit / fail)** — the runtime
  modules under `lib/au_ps_inferno/utils/`. Shared, status-specific wording now lives in
  `lib/au_ps_inferno/utils/basic_test/ms_message_text_module.rb`.

## What the old text did wrong

1. **One message for every status.** The same string (e.g. *"List mandatory Must Support elements
   populated and missing"*) was emitted whether the test passed or failed, so the message never told
   the reader whether something was actually wrong.
2. **Misleading opening sentences.** Messages began with *"Must Support sub-elements correctly
   populated"* even when mandatory elements were missing, and *"Complex element X is not populated.
   Must Support sub-elements that would be validated: …"* read as a contradiction.
3. **Generic, non-actionable failure text.** *"Some of the elements are not populated. See the list
   of populated elements in messages tab."* states neither what failed nor what to do.
4. **No remediation guidance** for optional (SHOULD/MAY) gaps — a reader could not tell whether a
   warning was a problem or simply absent data.
5. **Inconsistent naming.** Section names were taken from the resource `title` instead of the
   canonical *"Patient Summary … Section (code)"*; profiles were referred to as *"AU PS Bundle"* in
   some places and *"AU Patient Summary"* in others.
6. **Wrong status semantics.** Optional reference groups (custodian, attester) used `skip` with the
   same message for *"not populated"* and *"does not resolve"*.

## The general patterns the new text follows

| # | Pattern | Rule |
|---|---------|------|
| A | **Status-specific messages** | Pass → affirmative confirmation ("All mandatory Must Support elements are correctly populated"). Error → states what is wrong ("At least one mandatory Must Support element is not populated"). Warning → states the optional gap **plus** remediation. |
| B | **Standard remediation sentence** | Every optional/SHOULD/MAY gap ends with: *"Provide further test data where the missing {thing} is populated or confirm that the system does not ever know a value for the {thing}."* |
| C | **Honest opening sentences** | The first line of a message always reflects the actual outcome; no "correctly populated" prefix on a failing result. |
| D | **Affirmative Status-Fail text** | The fail line names the failure ("Must Support sub-elements of a complex element are not correctly populated"), not "see the messages tab". |
| E | **Resource-oriented, spelled-out naming** | "Bundle resource", "AU Patient Summary", "profiles"/"conformance requirements"; consistent "Patient Summary … Section (code)" names everywhere. |
| F | **Mandatory vs optional legend** | ✅ Populated · ❌ Missing (mandatory) · ⚠️ Missing (optional); mandatory elements marked `(M)`. |
| G | **Correct status semantics** | Optional reference groups (custodian, attester) are `omit`ted when absent/unresolved; mandatory groups stay `skip`ped so the gap stays visible. |

## How the patterns were extrapolated to the other sheets

- **Composition Section** — section MS messages made status-specific and switched to canonical section
  names (`get_section_name`); the misleading "For section with any mandatory … missing" opener
  replaced; the "mandatory section" wording in the section-entry-profile fail messages made tier-neutral.
- **Subject / Author / Custodian / Attester** — sub-element messages made status-specific and the
  "Referenced subject" label fixed to the actual container; parent-not-populated text rewritten with
  remediation; identifier-slice messages given self-explanatory, status-specific intros; custodian and
  attester guards switched from `skip` to `omit`.
- **CapabilityStatement** — already concise and consistent; no wording changes required.
- **General** — the `$summary` `profile` input description clarified to say it is the profile
  parameter passed to the `$summary` operation.

## Notable behaviour fix

- The IPS Bundle validation profile is now pinned to the version the IG depends on
  (`Bundle-uv-ips|2.0.0`), so the conformance failure message reports the exact profile version.
