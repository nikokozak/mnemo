<script>
    import { sectionStore } from '../stores/subject_section_store.js';
    import TextContent from './inner_content/_text_content.svelte';
    import ImageContent from './inner_content/_image_content.svelte';

    // _underscored variables denote vars that are relevant only to the frontend client.
    export let _block_idx = 0;
    export let _section_idx = 0;
    export const type = "static";

    $: testable = $sectionStore[_section_idx].blocks[_block_idx].testable;
    $: editing = $sectionStore[_section_idx].blocks[_block_idx]._editing;
    $: inner_content = $sectionStore[_section_idx].blocks[_block_idx].inner_content;

    function toggleTestable() {
        $sectionStore[_section_idx].blocks[_block_idx].testable = !$sectionStore[_section_idx].blocks[_block_idx].testable
    }
</script>

<div class="border rounded-lg mt-2">
    <!-- Block Type Title -->
    <div class="flex m-4 text-md">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="mr-2 w-6 h-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25H12" />
        </svg>
        <h1>Static Text and Images</h1>
    </div>
    <!-- End Block Type Title -->

    <!-- Inner Block Content -->
    {#each inner_content as content (content._sidx)}
        <svelte:component this={content._componentType} bind:data={content.data} />
    {/each}
    <!-- End Inner Block Content -->

    <!-- Inner Block Controls -->
    <div class="flex justify-around">
        <button on:click={() => sectionStore.addInnerTextContent(_section_idx, _block_idx)} class="flex text-xs border rounded-lg py-2 px-4">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 mr-2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25H12" />
            </svg>
            <p>Add Text</p>
        </button>
        <button on:click={() => sectionStore.addInnerImageContent(_section_idx, _block_idx)} class="flex text-xs border rounded-lg py-2 px-4">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 mr-2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 15.75l5.159-5.159a2.25 2.25 0 013.182 0l5.159 5.159m-1.5-1.5l1.409-1.409a2.25 2.25 0 013.182 0l2.909 2.909m-18 3.75h16.5a1.5 1.5 0 001.5-1.5V6a1.5 1.5 0 00-1.5-1.5H3.75A1.5 1.5 0 002.25 6v12a1.5 1.5 0 001.5 1.5zm10.5-11.25h.008v.008h-.008V8.25zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z" />
            </svg>
            <p>Add Image</p>
        </button>
    </div>
    <!-- End Inner Block Controls -->

    <!-- Block Controls -->
    <div class="flex justify-between text-xs border-t mt-4"> 
        {#if editing}
            <div on:click={() => sectionStore.removeBlock(_section_idx, _block_idx)} class="border-r w-1/2 flex pl-6 py-2">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 mr-2">
                    <path fill-rule="evenodd" d="M8.75 1A2.75 2.75 0 006 3.75v.443c-.795.077-1.584.176-2.365.298a.75.75 0 10.23 1.482l.149-.022.841 10.518A2.75 2.75 0 007.596 19h4.807a2.75 2.75 0 002.742-2.53l.841-10.52.149.023a.75.75 0 00.23-1.482A41.03 41.03 0 0014 4.193V3.75A2.75 2.75 0 0011.25 1h-2.5zM10 4c.84 0 1.673.025 2.5.075V3.75c0-.69-.56-1.25-1.25-1.25h-2.5c-.69 0-1.25.56-1.25 1.25v.325C8.327 4.025 9.16 4 10 4zM8.58 7.72a.75.75 0 00-1.5.06l.3 7.5a.75.75 0 101.5-.06l-.3-7.5zm4.34.06a.75.75 0 10-1.5-.06l-.3 7.5a.75.75 0 101.5.06l.3-7.5z" clip-rule="evenodd" />
                </svg>
                Delete Block
            </div>
            <div on:click={() => sectionStore.saveBlock(_section_idx, _block_idx)} class="w-1/2 flex pl-6 py-2">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 mr-2">
                    <path fill-rule="evenodd" d="M4.5 2A1.5 1.5 0 003 3.5v13A1.5 1.5 0 004.5 18h11a1.5 1.5 0 001.5-1.5V7.621a1.5 1.5 0 00-.44-1.06l-4.12-4.122A1.5 1.5 0 0011.378 2H4.5zM10 8a.75.75 0 01.75.75v1.5h1.5a.75.75 0 010 1.5h-1.5v1.5a.75.75 0 01-1.5 0v-1.5h-1.5a.75.75 0 010-1.5h1.5v-1.5A.75.75 0 0110 8z" clip-rule="evenodd" />
                </svg>
                Save Block
            </div>
        {:else}
            <div on:click={() => sectionStore.editBlock(_section_idx, _block_idx)} class="border-r w-1/2 flex pl-6 py-2">
                Edit Block
            </div>
            <div on:click={toggleTestable} class="border-r w-1/2 pl-6 py-2">Testable? {testable}</div>
        {/if}
    </div>
    <!-- End Block Controls -->
</div>
