## Schemas

credentials {
    email,
    pass,
    role: admin | student | professor | institution
    }

student_properties {
    email,
    name,
    profile_pic,
    }

professor_properties {
    has_accepted_offer: boolean,
    subjects_as_professor
}

institution_properties {
    name,
    verification_status: pending | approved,
    short_name,
    website,
    logo
    }

student_progression {
    email,
    subject_id,
    enrollment_pending,
    completed_blocks: refs to blocks,
    completed_sections: refs to sections,
    block_cursor, (where you're looking at currently vs what you've completed)
    section_cursor
    }

scheduled_blocks {
    email,
    subject_id,
    block_id,
    review_at: Date,
    }

student_review_queue {
    email,
    subject_id,
    block_id
    }

student_completed_reviews {
    email,
    subject_id,
    block_id,
    succeeded: boolean,
    answers: [],
    attempts,
    time_taken: time,
    date_suggested: date,
    date_reviewed: date,
    }

subject {
    id,
    title,
    description,
    published,
    price,
    institution_only,
    created_at,
    updated_at,
    deleted_at,
    sections: section_refs,
    }

subject_sections {
    id,
    title,
    blocks: block_refs
}

content_blocks {
    id,
    subject_id, 
    section_id,
    testable, 
    order_in_section: 1
    type: mcp | fib | oa | static | flashcard
    media: {},
    block: (json)
    }

static_content_block_json {
    elements: [
        { type: text,
        data: "the text"
        } 
        { type: media,
        data: "media_id"
        }
    ]
}

