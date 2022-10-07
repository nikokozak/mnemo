<script> 
    // SECTION
    // Parent to individual CONTENTBLOCKS

    import { mcQuestionBlock } from '../../schemas.js';
    import { createEventDispatcher } from 'svelte';

    const dispatch = createEventDispatcher();

    export let _section_idx;
    export let section;

    let editing_block = false;

    function removeBlock(idx) {
        section.blocks.splice(idx, 1);
        section.blocks = section.blocks;
    }

    function addMCQuestionContentBlock() {
        section.blocks.push(mcQuestionBlock())
        section.blocks = section.blocks;
    }
</script>

    <div class="mt-4">
    <!-- Section Title -->
    <div class="flex justify-between">
    <input type="text" bind:value={section.title} class="text-md text-semibold underline underline-offset-6 border-0 p-0 mb-4" placeholder="Optional Section Title" />
    <svg on:click={() => dispatch('remove')} xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width={1.5} stroke="currentColor" class="gray-400 w-4 h-4 mt-1">
        <path strokeLinecap="round" strokeLinejoin="round" d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0" />
    </svg>
</div>

    {#each section.blocks || [] as block, bidx (block._sidx)}
    <svelte:component this={block._componentType}
           bind:block={block}
           _block_idx={bidx}
           on:remove={() => removeBlock(bidx)}
       />
    {/each}

    {#if !editing_block}
    <button on:click={addMCQuestionContentBlock} class="block py-2 px-4 border rounded-lg mt-4 text-xs">
        Create a new Content Block
    </button>
    {/if}
</div>
