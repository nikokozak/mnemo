import { writable } from 'svelte/store';
import { createBlockStore } from './block_store.js';

// sections data struct
const sections = () => new Array();

let sectionSidx = 0;
const section = () => { 
    return {
        // _sidx is just a dumb counter that serves to index sections
        // in the #each loop.
        _sidx: sectionSidx++,
        id: null,
        subjectId: null,
        title: null, 
        blocks: createBlockStore(),
    }
};

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

function createSectionStore() {
    const { subscribe, set, update } = writable(sections());

    return {
        subscribe,
        set,
        addSection: addSection(update),
        removeSection: removeSection(update)
    }
}

export const sectionStore = createSectionStore();
