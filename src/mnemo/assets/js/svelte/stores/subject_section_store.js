import { writable } from 'svelte/store';

const subjectSections = () => new Array();

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
const block = () => {
    return {
        // _sidx is just a dumb counter that serves to index sections
        // in the #each loop. 
        _sidx: blockSidx++,
        _editing: true,
        testable: false,
    }
}

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

const addBlock = (update_fn) => {
    return (sectionIdx = null) => {
        update_fn(sectionArray => {
            if (sectionArray.length == 0 || sectionIdx == null) {
                const newSection = section();
                newSection.blocks.push(block());
                sectionArray.push(newSection);
            } else {
                const section = sectionArray[sectionIdx];
                section.blocks.push(block());
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

function createsubjectSectionsStore() {

    const { subscribe, set, update } = writable(subjectSections());

    return {
        subscribe,
        addSection: addSection(update),
        removeSection: removeSection(update),
        addBlock: addBlock(update),
        removeBlock: removeBlock(update),
        saveBlock: saveBlock(update),
        editBlock: editBlock(update),
        set,
    }
}

export const sectionStore = createsubjectSectionsStore();
