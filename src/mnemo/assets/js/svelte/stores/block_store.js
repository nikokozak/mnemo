import { writable } from 'svelte/store';
import { createInnerContentStore } from '../stores/inner_content_store.js';
import StaticContentBlock from '../content_blocks/_static_block.svelte';
import MCQuestionContentBlock from '../content_blocks/_mc_question_block.svelte';

// sections data struct
const blocks = () => new Array();

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
        inner_content: createInnerContentStore()
    }
}

const addStaticContentBlock = (update_fn) => {
    return () => {
        update_fn(blockArray => {
            blockArray.push(staticContentBlock());
            return blockArray;
        })
    }
}

const addMCQuestionContentBlock = (update_fn) => {
    return () => {
        update_fn(blockArray => {
            console.log(blockArray);
            blockArray.push(mcQuestionContentBlock());
            return blockArray;
        })
    }
}

const removeBlock = (update_fn) => {
    return (blockIdx) => {
        update_fn(blockArray => {
            blockArray.splice(blockIdx, 1);
            return blockArray;
        })
    }
}

export function createBlockStore() {
    const { subscribe, set, update } = writable(blocks());
        
    return {
        subscribe,
        set,
        removeBlock: removeBlock(update),
        addStaticContentBlock: addStaticContentBlock(update),
        addMCQuestionContentBlock: addMCQuestionContentBlock(update),
    }
}
