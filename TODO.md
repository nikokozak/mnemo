# Mnemo TODO

- Update Viewer and Editor, test to make sure nothing is broken, re: {"study" | "review", block}
- Photo Uploads
- Drag & Drop Editing
- Ident w/Roles
- Profile page
- Enrollment for Professors, Institutions
- Email Reminders
- Marketing materials

- Make text inputs intuitive visually
- Think about how to tie in temporally - ease of use.

- COMPLETELY UNLINK socket block and enrollment block logic.
- ATM static block "has not mastered" requires three tries to continue.

- Viewer
    - Viewer informs us if we're reviewing or studying.
    - Student home shows us how many cards to review we have today, and what percentage of the 
      deck we've studied.

- Student Home should be a liveview.
  - Checks the Student Review Queue for reviewable cards.
  - Tells you there are # cards to review in the future.
- Standardize how we store answer attempts (ideally in JSON).
  - View should implement a translator into BAFS (Block Answer Format Standard)
  - This BAFS is what is passed to the block checking engine
  - This BAFS is also what is passed to changesets to store (attempts can therefore be counted)
  - BAFS should be able to store "static" i.e. yes/no answers, as well as complex answers.
- Photo uploads for cards
- "Edit" mode for editBlocks, where we can move or delete blocks of content, including picks and
  the block itself.
- Quantum scheduler.
  - Takes all scheduled cards from yesterday into today, before inserting more into review queue.
- Make schedule of features, looking into December.
- Ideate marketing materials/strategy (signups, landing page, etc.).
- Refac / Design elements in viewer / editor (centralize markup of things like buttons through tailwind classes, general structure).
- Documentation / Tests for managers.
- Test for liveview.
- Script for running "project" in dev mode (i.e. ensure postgres started, web_client & mnemo all started)
- OAuth integration. (front/back)
- CircleCI build system (actually fix, automate so deployments are working, demoable)
