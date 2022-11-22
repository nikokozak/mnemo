# Mnemo TODO

Yesterday:
    - Created BlockEngine next_block, which returns a tuple with either
    {"subject", block} if the next block comes from the subject sequence of blocks, or
    {"review", block} if the next block comes from the scheduled blocks of the user.

- Make text inputs intuitive visually
- Think about how to tie in temporally - ease of use.

- don't need block cursor type anymore (in Enrollment), next_block is separate
- COMPLETELY UNLINK socket block and enrollment block logic.
- ATM static block "has not mastered" requires three tries to continue.

- Base Schema
 - Add "reviewed-today", "percentage-completed" to enrollment. Ensure "block_cursor_type" is 
   persisted.
 - Add "latest-block" field (we'll implement this logic later).

- Viewer
  - Implements different logic depending on whether the current block_cursor in the enrollment
    is a "review" block or a "subject" block. If it's a review block, we don't consume it as per usual, rather we complete it, re-schedule it, remove it from the review queue, and add to the reviewed-today count in enrollment.
    If reviewed-today is past a certain limit, BLOCKENGINE should only pick blocks from the subject.
    - Add block_type to socket in viewer to differentiate action.
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
- New "Enrollments" should load all cards into the student review queue
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
