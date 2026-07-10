
# AU PS Inferno Test Kit 

This is an [Inferno](https://inferno-framework.github.io/inferno-core/) test kit for the [AU PS Implementation Guide](http://hl7.org.au/fhir/ps/)

**Currently available versions:**
1. [1.0.0](https://hl7.org.au/fhir/ps/1.0.0)

## Use Inferno as a service
You can test your FHIR server using this link [https://inferno.hl7.org.au/test-kits/au-ps](https://inferno.hl7.org.au/test-kits/au-ps/)

## Run Inferno locally via Docker

It is highly recommended that you use Docker to run these tests. This test kit requires at least 10 GB of memory are available to Docker.
1. Clone this repo.
2. Run the setup script to initialize the database

```bash
make setup
```

3. Run project

```bash
make run
```

4. Navigate to http://localhost. The AU PS test suite will be available.

## How to Regenerate the Suite for a New IG Version

If a new AU PS IG release appears at http://hl7.org.au/fhir/ps/history.html, follow these steps to regenerate the suite:

1. Get the new IG package (`.tgz`) into `lib/au_ps_inferno/igs/`, either by downloading it from the release page yourself, or by fetching it via [fhir_packages_manager](https://github.com/projkov/fhir_packages_manager). Archives are named `<package>-<version>.tgz` (e.g. `hl7.fhir.au.ps-1.0.0.tgz`), the naming the tool itself uses to fetch and download packages:

   ```bash
   make list_ig_versions   # list all hl7.fhir.au.ps versions published on the registries
   make check_ig           # check whether the latest hl7.fhir.au.ps version is available
   make fetch_ig IG_PACKAGE_VERSION=X.Y.Z  # download hl7.fhir.au.ps@X.Y.Z into lib/au_ps_inferno/igs/
   make sync_igs           # download every non-ignored version from Simplifier not already in lib/au_ps_inferno/igs/
   ```

   Packages or versions listed in `fhir_packages_ignore.yml` are excluded from all four commands.
2. Commit and push it to `master`. Pushing a `.tgz` under `lib/au_ps_inferno/igs/` automatically triggers the Generate Suite workflow. You can also trigger it manually from the [workflow page](https://github.com/hl7au/au-ps-inferno/actions/workflows/generate-suite.yaml) (**Run workflow**).
3. The workflow generates a suite for every archive under `lib/au_ps_inferno/igs/` that is new or has changed since it was last generated (you can check this locally with `make pending`).
4. When the workflow completes, a Pull Request is created automatically for each generated archive. Review and merge it.

### What the pipeline does

1. The `detect` job runs `rake generator:pending` to list archives under `lib/au_ps_inferno/igs/` that are new or whose content changed since the last recorded generation (tracked in `lib/au_ps_inferno/igs/generated.yaml`);
2. For each pending archive, the `generate` job runs `make generate_and_fix`, which invokes the generator against that archive;
3. The generator extracts IG resources from the archive and, for any version other than the hand-authored `1.0.0` baseline, writes `lib/au_ps_inferno/generated/<ig_version>/metadata.yaml` plus a full generated test suite tree alongside it. Generation is a no-op for `1.0.0`, since that suite under `lib/au_ps_inferno/suite/` is hand-authored and never regenerated;
4. The archive's checksum and resulting IG version are recorded in `lib/au_ps_inferno/igs/generated.yaml`, so it won't be picked up as pending again unless it changes;
5. If there are any changes, a Pull Request is created automatically.

## Development workflow
This repository contains both the source code of the tests generator and the generated tests themselves.
Even a small change in the generator source causes a huge amount of changes in the generated tests.
As a result, when a pull request contains both changes in the generator and changes in the generated files,
it is almost impossible to review. 
Furthermore, there is no sense in reviewing the generated files at all, they are just artifacts that this repo produces.
They are placed in the same repo under source control just for simplicity reasons.
So, the development process should look like this.
When you change the source code of the generator and create a pull request, you SHALL NOT add generated tests in this pull request.
Once the code review is done, a person who merged the changes SHALL run the generator and update generated tests.
It may be a direct commit to the master branch. 

## Release management
When we would like to issue a new release, you need to update `VERSION` (the gem version, e.g. `'0.0.2'`) in `lib/au_ps_inferno/version.rb`.

Each AU PS IG version other than `1.0.0` generates its own suite and its own `lib/au_ps_inferno/generated/<ig_version>/metadata.yaml` (see [How to Regenerate the Suite for a New IG Version](#how-to-regenerate-the-suite-for-a-new-ig-version)), so there's no single global IG version constant to update for those — suites for different IG versions coexist and are all loaded automatically. `1.0.0` remains hand-authored under `lib/au_ps_inferno/suite/` and keeps using `IG_VERSION` in `lib/au_ps_inferno/version.rb` as before.

Then you need to create a tag for this version. The tag name should start with `v` and then contain a numeric version like this `v0.0.1`
Once a tag is created, you need to create a GitHub release for this newly published version.
The release creation triggers the pipeline that deploys a new version to the cloud environment.

## Contributing to Inferno and Reporting Issues

1. Discuss an issue in chat.fhir.org
If you have a question, feature request, or proposed change, the best place to start is Zulip i.e. the https://chat.fhir.org/#narrow/stream/179173-australia/topic/Inferno.20Test.20Kit.20feedback.20and.20queries

If you're unable to find an open request, please create a GitHub to:
contribute Test suites or Code to the repository: state your details and the nature of the changes to be contributed
suggest improvements or enhancements to the project

We appreciate your contributions to improving this test suite. **If you encounter any issues or have suggestions for enhancements, please follow the steps below to report them**:

1. **Search for Existing Issues**:
Before submitting a new issue, please check the [Issues section](https://github.com/hl7au/au-ps-inferno/issues) to see if the problem or suggestion has already been reported. If you find an existing issue, you can add your comments or additional information to it.
2. **Open a New Issue:**
If you do not find a similar issue, you can open a [new one](https://github.com/hl7au/au-ps-inferno/issues/new). Click on the New Issue button and provide details, e.g., for a bug report:
```
Title: A brief and descriptive title for the issue.
Description: A detailed description of the issue, including:
1. Steps to reproduce the issue.
2. Expected and actual behavior.
3. Screenshots or another related information (if applicable).
```
3. **Labeling:**
Help us categorize the issue by adding relevant labels (e.g., bug, enhancement, question). This helps us prioritize and address the issues more efficiently.

#### Resolving Issues
To support effective issue resolution, reporters may be engaged in the review process to help confirm that resolutions address their concerns. This can involve notifying the reporter when a fix is implemented and inviting them to validate the solution or provide feedback before the issue is formally closed.

#### Questions?
In addition to reporting issues on GitHub, you can also ask questions or report issues on Zulip (chat.fhir.org).
- Specific topic for HL7 AU Inferno Test Kit feedback and queries: [australia > Inferno Test Kit feedback and queries](https://chat.fhir.org/#narrow/channel/179173-australia/topic/Inferno.20Test.20Kit.20feedback.20and.20queries)
- General: [Inferno channel](https://chat.fhir.org/#narrow/channel/179309-inferno)

## How to Contribute to the HL7 AU Inferno AU PS Test Kit
If you would like to contribute to **hl7au/au-ps-inferno**, here’s how:

### 1. Communicate Before You Start
- Open a [GitHub issue](https://github.com/hl7au/au-ps-inferno/issues) to discuss your plans to help avoid duplication of effort, align and prioritise your contributions.
- Join the fortnightly HL7 AU Infrastructure and Tooling Community Meetings ([register here](https://confluence.hl7.org/display/HAFWG/Infrastructure+and+Tooling+Contact+List)) where we discuss and triage issues. Feel free to add your issue to the [meeting agenda](https://confluence.hl7.org/pages/viewpage.action?pageId=265492851#CommunityMeetingAgendaandMinutes-MeetingDetails) and we'll aim to discuss your issue/ proposed contribution when you are present at the meeting.
- Use Zulip to connect with the team and community asynchronously: 
  - Specific topic for HL7 AU Inferno Test Kit feedback and queries: [australia > Inferno Test Kit feedback and queries](https://chat.fhir.org/#narrow/channel/179173-australia/topic/Inferno.20Test.20Kit.20feedback.20and.20queries)
  - General: [Inferno channel](https://chat.fhir.org/#narrow/channel/179309-inferno)

### 2. Contribute Code
1. Fork this repository.
2. Create a branch and use the GitHub issue number followed by a meaningful description as the branch name for your contribution.
3. Make your contributions/ changes. Please DO NOT add generated tests as instructed in the [Development Workflow](https://github.com/hl7au/au-ps-inferno?tab=readme-ov-file#development-workflow) section of this README.
4. Submit a pull request (PR) for review.
5. Once the PR has been reviewed, feedback addressed collaboratively, and approved (by the designated HL7 AU project facilitator or their delegate - refer to the [HL7 AU Project Registry](https://confluence.hl7.org/display/HA/HL7+Australia+Project+Registry)), it may be merged into the main branch.

## Additional information
1. [Pre-requisites](/docs/pre-requisites.md)
2. [Validator instructions](/docs/validator_instructions.md)
3. [Changelog](CHANGELOG.md)

