---
name: f2r-spike
description: "SFCC-205 Figma-to-React spike (F2R) scope, collaborators, and the handover workflow being hardened"
metadata: 
  node_type: memory
  type: project
  originSessionId: f9935096-201c-46d8-bf06-233aead37fb8
  modified: 2026-07-22T02:48:40.742Z
---

SFCC-205 "Figma to React Setup" is a Jira **Spike** (project SFCC on zimmermannworkboard.atlassian.net, label Squad-A), assigned to Marcel, reported by Hazel Marie Cacalda. Referred to as "F2R."

It is NOT a greenfield pipeline build. It refines/hardens the existing design-to-build handover so specs, tokens, the component contract, and prototypes reach engineering unambiguous and ready to build against.

Focus (confirmed 2026-07-22): hardening the **Figma-to-code handover workflow itself** (design-side pipeline: specs, tokens, component contract, prototypes), NOT the Web-Components-to-React conversion step. Keep the ticket framework-neutral: avoid framing it as "web components -> React." Keep it generic, no named people (unlike some other SFCC spikes). Marcel considers the ticket "just a formality."

Anchored in Marcel's own confirmatory audit: **FIGMA-TO-CODE-WORKFLOW-AUDIT.md** (repo root, dated 2026-07-20). Key audit themes to work from: no responsive capture (0 clamp/min/max, accidental desktop-first), no handover quality gate (validate.mjs only checks atomic taxonomy), provenance/source-of-truth gaps (Figma not required/verified, PAT unset, token base from a file named "MCP-Test--Don-t-Use"), 12 of 27 components have no spec, WCAG AA asserted but not decomposed, contract inaccuracies. Highest-leverage fix per audit section 7: fix the pipeline/process gates + the design<->engineering feedback loop.

Collaborators (context only, keep OUT of ticket text): Marcel + Tim lead; Ajay Murthy and Han Lee support. Delivered via working sessions. See [[user_role]].

Board spike house style: Objective / Background / Tasks / Definition of Done. Timeboxed. DoD is a documented artefact shared with the squad (often a Confluence page). Reference examples: SFCC-120, SFCC-121, SFCC-122, SFCC-123.

Plan agreed 2026-07-22: draft ticket body here, Marcel reviews, then push to SFCC-205 (description only) via Jira MCP after approval. Do not edit the live ticket without approval.
