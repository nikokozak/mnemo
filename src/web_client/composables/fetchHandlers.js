import { unref } from 'vue';

export async function useSaveBlock(block) {
    block = unref(block)

    return useSimpleFetch(`/api/blocks/${block.id}`, {
        method: 'PATCH',
        body: block
    })
}

export async function useDeleteBlock(block) {
    block = unref(block)

    return useSimpleFetch(`/api/blocks/${block.id}`, {
        method: 'DELETE'
    })
}
