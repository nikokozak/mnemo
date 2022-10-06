<script>
    import { sectionStore } from '../stores/section_store.js';

    export let _section_idx;
    let editing_block = false;
    let section;
    $: blocks = $sectionStore[_section_idx].blocks;
</script>

    <div class="mt-4">
    <!-- Section Title -->
    <div class="flex justify-between">
    <input type="text" bind:value={$sectionStore[_section_idx].title} class="text-md text-semibold underline underline-offset-6 border-0 p-0 mb-4" placeholder="Optional Section Title" />
    <svg on:click={() => sectionStore.removeSection(_section_idx)} xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width={1.5} stroke="currentColor" class="gray-400 w-4 h-4 mt-1">
        <path strokeLinecap="round" strokeLinejoin="round" d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0" />
    </svg>
    </div>

    <!-- End Section Title -->

    <!-- Keep in mind that by binding this to the block above,
    we lose all info originally in the block above, but keep the reference
    to its place in the array. If this is bound to the parent object 
    (i.e. the original "block", we cannot pass any original info down to 
        the Component. Instead, we have to bind to a "ref" property inside the 
        object, which will allow us to pull info from the original block, like
        its ID for mounting the sub-block -->
        {#each $blocks as block, bidx (block._sidx)}
           <svelte:component 
                this={block._componentType}
                _block_idx={bidx}
                bind:_block={block}
                on:remove={blocks.removeBlock(bidx)}
            />
        {/each}

        {#if !editing_block}
        <button on:click={() => blocks.addMCQuestionContentBlock()} class="block py-2 px-4 border rounded-lg mt-4 text-xs">
        Create a new Content Block
        </button>
        {/if}
</div>
