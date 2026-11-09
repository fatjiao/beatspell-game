# Beatspell development instructions

- Start with `docs/PROJECT_HANDOFF.md` and `docs/GAMEPLAY.md`. Current work is the rhythm spell Boss demo; keep its 16-bit pixel direction and continuous global beat ring.
- The user requires a detailed gameplay document to be maintained alongside future development. In every batch that changes controls, timing, spells, combat numbers, Boss patterns, tutorials, settings or scoring, update the affected gameplay sections and numeric reference in the same delivery. Keep proposed mechanics visibly separate from implemented rules.
- Local gameplay copy: `docs/GAMEPLAY.md`. Online Page: `https://chatgpt.com/space/page_3464b9beb91481919abe7d81d68d2251`; Page ID: `page_3464b9beb91481919abe7d81d68d2251`.
- Read the online Page before updates, preserve the user's edits and comments, apply guarded changes, and verify the save. Keep online and repository gameplay rules aligned. If the Page is unavailable, finish the local copy, record the unsynced changes in the handoff, and report the gap; do not create duplicate Pages or claim synchronization succeeded.
- Update `CHANGELOG.md` and `docs/PROJECT_HANDOFF.md` when the delivered behavior/version changes. Verify meaningful gameplay changes with the existing Godot tests and scene flow checks. Documentation-only updates do not require a game rebuild.
- Commit the gameplay documentation and handoff references with the development work so another computer can continue maintaining the same online Page. This is a per-delivery workflow, not a scheduled background task.
