export function useEditBlockHelpers(emitter) {
    const deleteBlock = (block) => {
        useDeleteBlock(block).then(_response => {
            console.log(`deleted ${block.type} block ${block.id}`);
            emitter('delete', block.value.id);
        })
    }

    const saveBlock = (block) => {
        useSaveBlock(block).then(_response => {
            console.log(`saved ${block.type} block ${block.id}`);
            emitter('save');
        })
    }

    return {
        deleteBlock,
        saveBlock
    }
}
