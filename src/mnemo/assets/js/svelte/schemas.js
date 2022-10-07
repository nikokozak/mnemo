import MCQuestionContentBlock from './content_editor/content_blocks/block_types/_mc_question_block.svelte';

// Naive counter to allow for keying in each loops
let sectionSidx = 0;
export function section(props = {}) {
    return {
        _sidx: sectionSidx++,
        id: props.id || null,
        subjectId: props.subjectId || null,
        title: props.title || null,
        blocks: props.blocks || []
    }
}

let contentBlockSidx = 0;
export function mcQuestionBlock(props = {}) {
    return {
        _sidx: contentBlockSidx++,
        id: props.id || null,
        type: props.type || "mc",
        _componentType: MCQuestionContentBlock,
        inner_content: props.inner_content || {
            answer: {
                choices: {
                    "a": "A choice here",
                    "b": "Another choice here"
                },
                correct: "b"
            },
            question: {
                text: "Some text here",
                image: ""
            }
        },
        editing: props.editing || true,
        testable: props.testable || false
    }
}
