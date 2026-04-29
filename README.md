# CCO United — Community Asset Directory

A publicly accessible Salesforce Experience Cloud (LWR) site for browsing community assets across local CCO groups. Guest visitors can drill down from national organization → local group → asset category → assets, or search and filter across the full directory without logging in.

---

## Overview

| Item | Detail |
|---|---|
| Platform | Salesforce Experience Cloud (LWR — Lightning Web Runtime) |
| Auth | Guest access — no login required |
| Target org type | Developer Edition or Scratch Org |
| API Version | 63.0 |
| License | MIT |

---

## Data Model

```
National_Organization__c
  └── Local_Community_Group__c   (Master-Detail)
        └── Asset_Category__c    (Lookup, required)
              └── Asset__c       (Lookup, required)
```

**`Asset__c` type picklist values:** Physical · Skill · Credential · Interest · Person · Partner

**`Asset__c` status picklist values:** Available · Seasonal · Unavailable

---

## Project Structure

```
force-app/main/default/
  classes/
    CCOAssetDirectoryController.cls        Apex controller (without sharing, read-only)
    CCOAssetDirectoryControllerTest.cls    Apex test class (≥90% coverage)
  lwc/
    ccoAssetDirectory/    Top-level container, owns navigation state
    ccoBreadcrumb/        Navigation trail
    ccoHero/              Hero banner (configurable title, subtitle, background image)
    ccoSearchBar/         Debounced search input
    ccoFilterPanel/       Group + type filter dropdowns
    ccoLocalGroupGrid/    Wires getLocalGroups(), renders group cards
    ccoLocalGroupCard/    Single group tile with color band
    ccoCategoryGrid/      Wires getCategoriesByGroup(), renders category cards
    ccoCategoryCard/      Single category tile with asset count badge
    ccoAssetGrid/         Wires getAssetsByCategory() or searchAndFilterAssets()
    ccoAssetCard/         Asset card with type badge, tags, contact, file link
  objects/                Custom object + field metadata (4 objects)
  permissionsets/
    CCO_Asset_Directory.permissionset-meta.xml   Admin/data-loader CRUD access
    CCO_Guest_Access.permissionset-meta.xml      Guest read-only + Apex access
  staticresources/
    ccoStyles/cco-main.css                       Design system CSS
data/
  cco-seed-plan.json       sf data import tree plan
  National_Organization__c.json
  Local_Community_Group__c.json
  Asset_Category__c.json
  Asset__c.json            Keys CCO seed data (~53 assets, 15 categories)
config/
  project-scratch-def.json
sfdx-project.json
```

---

## Prerequisites

- [Salesforce CLI v2](https://developer.salesforce.com/tools/salesforcecli) (`sf` commands)
- A Salesforce Dev Hub org (for scratch orgs) **or** a Developer Edition org
- Node.js 18+ (if running Jest unit tests)

---

## Deployment

### Option A — Scratch Org

```bash
# Authenticate Dev Hub
sf org login web --alias MyDevHub --set-default-dev-hub

# Create scratch org
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias cco-united-dev \
  --duration-days 30 \
  --set-default

# Deploy metadata
sf project deploy start --source-dir force-app --target-org cco-united-dev

# Assign permission set
sf org assign permset --name CCO_Asset_Directory --target-org cco-united-dev

# Load seed data
sf data import tree --plan data/cco-seed-plan.json --target-org cco-united-dev

# Open org
sf org open --target-org cco-united-dev
```

### Option B — Developer Edition or Sandbox

```bash
sf org login web --alias MyCCOOrg
sf project deploy start --source-dir force-app --target-org MyCCOOrg
sf org assign permset --name CCO_Asset_Directory --target-org MyCCOOrg
sf data import tree --plan data/cco-seed-plan.json --target-org MyCCOOrg
```

---

## Manual Org Setup (post-deploy)

These steps must be completed in the Setup UI after deployment:

1. **Enable Digital Experiences** — Setup → Digital Experiences → Settings → Enable
2. **Create LWR site** — Setup → Digital Experiences → All Sites → New → Build Your Own (LWR) → name it "CCO United"
3. **Guest Profile FLS** — Setup → Profiles → "CCO United Profile" → grant Read on all 4 custom objects and their fields
4. **Assign guest permission set** — assign `CCO_Guest_Access` to the site's guest user
5. **Enable guest access** — Experience Builder → Settings → General → allow guest users
6. **Add component** — drag `ccoAssetDirectory` onto the Home page in Experience Builder
7. **Publish site**

---

## Running Tests

```bash
# Apex tests
sf apex run test \
  --class-names CCOAssetDirectoryControllerTest \
  --target-org cco-united-dev \
  --result-format human \
  --output-dir test-results
```

---

## Experience Builder Configuration

The `ccoHero` and `ccoAssetDirectory` components expose configurable properties in Experience Builder:

| Property | Component | Description |
|---|---|---|
| Site Title | `ccoAssetDirectory` | Displayed in hero banner |
| Site Subtitle | `ccoAssetDirectory` | Displayed below title |
| Hero Background Image URL | `ccoHero` | Optional background photo (external URL) |

---

## Security Notes

- Apex controller uses `without sharing` — required for guest user context (no record ownership)
- All queries filter by `Status__c` to limit exposed records
- No DML in any controller method — strictly read-only
- `String.escapeSingleQuotes()` used on all dynamic SOQL inputs
- Guest profile has Read-only FLS; `CCO_Asset_Directory` permission set is for admins only

---

## Contributing

1. Fork the repo and create a feature branch
2. Deploy to a scratch org and test
3. Run Apex tests and verify ≥90% coverage
4. Open a pull request

---

## License

MIT — see [LICENSE](LICENSE)
