import { writable } from 'svelte/store';
import StaticContentBlock from '../content_blocks/_static_block.svelte';
import MCQuestionContentBlock from '../content_blocks/_mc_question_block.svelte';
import TextContent from '../content_blocks/inner_content/_text_content.svelte';
import ImageContent from '../content_blocks/inner_content/_image_content.svelte';

const subjectSections = () => new Array();

// Schemas

let sectionSidx = 0;;
const section = () => { 
    return {
        // _sidx is just a dumb counter that serves to index sections
        // in the #each loop.
        _sidx: sectionSidx++,
        id: null,
        subjectId: null,
        title: null, 
        blocks: [],
    }
};

let blockSidx = 0;
const staticContentBlock = () => {
    return {
        // _sidx is just a dumb counter that serves to index sections
        // in the #each loop. 
        _sidx: blockSidx++,
        _componentType: StaticContentBlock,
        _editing: true,
        testable: false,
        inner_content: [],
    }
}

const mcQuestionContentBlock = () => {
    return {
        _sidx: blockSidx++,
        _editing: false, 
        _componentType: MCQuestionContentBlock,
        testable: false,
        inner_content: {
            question: {
                image: "",
                text: "A question related to the multiple choice answers below.",
            },
            answer: {
                choices: {
                    "a": "A first answer",
                    "b": "A second answer"
                },
                correct: "b"
            }
        }
    }
}

let innerContentSidx = 0;
const innerTextContent = () => {
    return {
        _sidx: innerContentSidx++,
        _componentType: TextContent,
        type: "text",
        data: undefined,
    }
}

const innerImageContent = () => {
    return {
        _sidx: innerContentSidx++,
        _componentType: ImageContent,
        type: "text",
        data: undefined,
    }
}

// Interface

const addSection = (update_fn) => {
    return () => {
        update_fn(sectionArray => {
            sectionArray.push(section())
            return sectionArray;
        });
    }
}

const removeSection = (update_fn) => {
    return (sectionIdx) => {
        update_fn(sectionArray => {
            sectionArray.splice(sectionIdx, 1)
            return sectionArray;
        });
    }
}

const addStaticContentBlock = (update_fn) => {
    return (sectionIdx = null) => {
        update_fn(sectionArray => {
            if (sectionArray.length == 0 || sectionIdx == null) {
                const newSection = section();
                newSection.blocks.push(staticContentBlock());
                sectionArray.push(newSection);
            } else {
                const section = sectionArray[sectionIdx];
                section.blocks.push(staticContentBlock());
//                _markChange(section);
            }
            return sectionArray;
        })
    }
}

const addMCQuestionContentBlock = (update_fn) => {
    return (sectionIdx = null) => {
        update_fn(sectionArray => {
            if (sectionArray.length == 0 || sectionIdx == null) {
                const newSection = section();
                newSection.blocks.push(mcQuestionContentBlock());
                sectionArray.push(newSection);
            } else {
                const section = sectionArray[sectionIdx];
                section.blocks.push(mcQuestionContentBlock());
//                _markChange(section);
            }
            return sectionArray;
        })
    }
}

const removeBlock = (update_fn) => {
    return (sectionIdx, blockIdx) => {
        update_fn(sectionArray => {
            const section = sectionArray[sectionIdx];
            section.blocks.splice(blockIdx, 1);
//            _markChange(section);
            return sectionArray;
        })
    }
}

const saveBlock = (update_fn) => {
    return (sectionIdx, blockIdx) => {
        update_fn(sectionArray => {
            const section = sectionArray[sectionIdx];
            const block = section.blocks[blockIdx];
            block._editing = false;
            return sectionArray;
        })
    }
}

const editBlock = (update_fn) => {
    return (sectionIdx, blockIdx) => {
        update_fn(sectionArray => {
            const section = sectionArray[sectionIdx];
            const block = section.blocks[blockIdx];
            block._editing = true;
            return sectionArray;
        })
    }
}

const addInnerTextContent = (update_fn) => {
    return (sectionIdx, staticContentBlockIdx) => {
        addInnerContent(update_fn, sectionIdx, staticContentBlockIdx, innerTextContent());
    }
}

const addInnerImageContent = (update_fn) => {
    return (sectionIdx, staticContentBlockIdx) => {
        addInnerContent(update_fn, sectionIdx, staticContentBlockIdx, innerImageContent());
    }
}

function addInnerContent(updateFn, sectionIdx, staticContentBlockIdx, content) {
    updateFn(sectionArray => {
        const section = sectionArray[sectionIdx];
        const staticContentBlock = section.blocks[staticContentBlockIdx];
        staticContentBlock.inner_content = [...staticContentBlock.inner_content, content];
        return sectionArray;
    })
}

function createsubjectSectionsStore() {

    const { subscribe, set, update } = writable(subjectSections());

    return {
        subscribe,
        addSection: addSection(update),
        removeSection: removeSection(update),
        addStaticContentBlock: addStaticContentBlock(update),
        addMCQuestionContentBlock: addMCQuestionContentBlock(update),
        removeBlock: removeBlock(update),
        saveBlock: saveBlock(update),
        editBlock: editBlock(update),
        addInnerTextContent: addInnerTextContent(update),
        addInnerImageContent: addInnerImageContent(update),
        set,
    }
}

export const sectionStore = createsubjectSectionsStore();
