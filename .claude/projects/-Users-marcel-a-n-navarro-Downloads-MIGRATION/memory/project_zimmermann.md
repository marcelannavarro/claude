---
name: project-zimmermann
description: "Zimmermann SFCC Commerce Migration project context — scope, timeline, stack, key integrations"
metadata: 
  node_type: memory
  type: project
  originSessionId: 2101df98-f38e-4d61-b30c-185b4ec543c6
---

**Project:** Zimmermann Commerce Migration (Stage 2B), Opp 0012534895. Magento → Salesforce Commerce Cloud PWA Kit.

**Why:** Zimmermann (luxury AU fashion brand) migrating from Magento to SFCC for global digital modernisation. Fixed-price AUD $2.9M.

**Timeline:** WC 6 Jul 2026 → Feb 2027. Go-live Jan 2027 (AU canary, then all regions ~1 week later).

**Stack:** Salesforce PWA Kit on MRT (React 18, Chakra UI, React Router v6, TanStack Query, TypeScript strict, Storybook 8, Vitest, Playwright). Overrides pattern — no fork of `@salesforce/retail-react-app`.

**Scope:** 7 storefronts across 6 regions (AU, UK, US, EU domestic, EU international, HK, ME). 11 active locales, 4 languages. International checkout via Global-e; domestic via SFCC.

**Key integrations (15+):** SFCC, MuleSoft (middleware for OMS/CRM/fulfilment), Contentful (CMS), Adyen (payments), Global-e (intl checkout), Omneo (CRM/loyalty), NewStore (OMS), AP21 (product master), Narvar (tracking/returns), GiveX (gift card), Didomi (consent), GTM via Addingwell, Google Maps, reCAPTCHA, Booxi (boutique appointments).

**Key open items (as of 2026-07-08):** 40 items across 18 integrations — most critical are Omneo (3 hard blockers, no credentials yet), MuleSoft OpenAPI spec, Booxi API spec, Adyen merchant IDs, Didomi notice IDs. Full list in Zimmermann/Architecture/openItems.md.

**Two squads:**
- Squad A: Cart, Checkout, Order confirmation, My Account, Z.immerse (starts WC 27 Jul)
- Squad B: Home, PDP, PLP, Search, Wishlist, Store Locator, Z.immerse (starts Aug)

**CI/CD:** GitFlow, 6-tier topology (Local → Dev → SIT → Stage → UAT → Prod). Digital SIT gate (Vitest, Playwright P0, Lighthouse ≥0.80 perf / ≥0.90 a11y, bundle-size, API contract tests).

**How to apply:** When discussing frontend decisions for Zimmermann, keep in mind the two-squad shared-codebase constraint, the integration seams (MuleSoft boundary, SFCC SCAPI vs MRT-direct calls), and the fixed-price deadline. "Flag, don't invent" on open integration items.
