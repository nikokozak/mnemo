# Spaced Rep System

*A series of components allowing for the creation of spaced repetition services.*

With the goal of... 

*Making it easy to create and distribute spaced repetition aided lessons and content.*

More to the point... 

Make long-term memory an accessible resource. 

## Who?

- Individuals
- Institutions
- Creators 
- Students

## What?

- Create and share content (courses)
- Revision schedules (personalized)

## How?

- Spaced repetition algo.
- Questions and testing.

## Where?

- Cloud
- Object Storage

## Atomic Business Verbs & Nouns

- User: Any and all users of the system.
- Learner: The base user of the system. 
- Professor: Users that have been labeled professors by Institutions.
- Institution: A verified institution in the real world with special privileges in the system.
- Admin: A system administrator or developer.

- Content: The sum of all Content Blocks that make up a specific "course" of knowledge.
- Content Block: A discrete piece of knowledge. A Content Block is made up of one or more static components and a testable.
    - A static Paragraph (text)
    - A static Image
    - An Open-ended question or
    - A Multiple-Choice Question or 
    - A fill in the blank or
    - A flash card
- Media: Photos, videos, or other documents embedded in a Content Block.

- Study: The act of going through all Content Blocks, including those that aren't Testeable. Progression is tracked.
- Review: The act of going through Testeable Content Blocks (TCBs).


## Use Cases

- Non-user can sign up to system. X
- User can request to be verified as Institution. X
- User can create content with integrated Knowledge Tests. X
- User can publish content. X
- User can un-publish content. X
- User can remove content. X
- User can consume content progressively, whether their own or other's. X
- User can access metrics for their created content. X
- User is notified once content is ready for review. X
- User can review content. X
- User can purchase and/or enroll in content created by other users. X
- Institution can add users as professors. X
- Institution can enroll non-users in courses. X

## Volatility

- Type of user (Individuals, Institutions, etc.) [Clients] 
- Content created (courses, video, flash cards, notes, etc.) [Content Manager]
- Answer validation (who is right?, how do we check?, separate code envs?) [Validation Engine]
- Spaced rep algo. More/less complex. [Scheduling Engine]
- Payments and membership. [Membership Manager]
- Authorization and security. [Authorization Utility]
- Questions and test types. [Content Manager]
- Internationalization. [Internationalization Utility]
- Frontend customization. [Clients]
- Storage - auth/user state/object storage. [Access]
- Marketplace (finding and selling content) [Marketplace Manager]
- User notification. [Notification Utility]
- Timing mechanism. [Timing Utility]

## Tentative Services

- Marketplace Client
- User Client
- Institutional Client
- Admin Cl ient
-------
- Marketplace Manager
- Content Manager
- Membership Manager
-------
- Scheduling Engine
- Validation Engine
-------
- Timing Utility
- Notification Utility
- Authorization Utility
- Internalization Utility
--------
- Credentials Access
- User Access
- Insitution Access
- Content Access
- Schedule Access
- Payment Access
