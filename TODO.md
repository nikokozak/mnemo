# Mnemo TODO

- Student Home should be a liveview.
  - Checks the Student Review Queue for reviewable cards.
  - Tells you there are # cards to review in the future.
- Standardize how we store answer attempts (ideally in JSON).
  - View should implement a translator into BAFS (Block Answer Format Standard)
  - This BAFS is what is passed to the block checking engine
  - This BAFS is also what is passed to changesets to store (attempts can therefore be counted)
  - BAFS should be able to store "static" i.e. yes/no answers, as well as complex answers.
- New "Enrollments" should load all cards into the student review queue
- Photo uploads for cards
- "Edit" mode for editBlocks, where we can move or delete blocks of content, including picks and
  the block itself.
- Quantum scheduler.
- Make schedule of features, looking into December.
- Ideate marketing materials/strategy (signups, landing page, etc.).
- Refac / Design elements in viewer / editor (centralize markup of things like buttons through tailwind classes, general structure).
- Documentation / Tests for managers.
- Test for liveview.
- Script for running "project" in dev mode (i.e. ensure postgres started, web_client & mnemo all started)
- OAuth integration. (front/back)
- CircleCI build system (actually fix, automate so deployments are working, demoable)
