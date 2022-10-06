<script>
    import { createEventDispatcher } from 'svelte';
    import TextContent from './inner_content/_text_content.svelte';
    import ImageContent from './inner_content/_image_content.svelte';
    import MCQuestionsContent from './inner_content/_mc_questions_content.svelte';

    const dispatch = createEventDispatcher();

    // _underscored variables denote vars that are relevant only to the frontend client.
    export let _block_idx = 0;
    export let _block;
    export const type = "static";

    let answer;
    let question;
    let inner_content;
    let editing;
    let testable;

    $: inner_content = _block.inner_content;
    $: question = _block.inner_content.question;
    $: answer = _block.inner_content.answer;

</script>

<div class="border rounded-lg mt-2">
    <!-- Block Type Title -->
    <div class="flex m-4 text-md">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="mr-2 w-6 h-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25H12" />
        </svg>
        <h1>Multiple Choice Question</h1>
    </div>
    <hr>

    <MCQuestionsContent _inner_content={_block.inner_content} />

    <!-- Block Controls -->
    <div class="flex justify-between text-xs border-t mt-4"> 
        {#if _block._editing}
            <div on:click={() => dispatch('remove')} class="border-r w-1/2 flex pl-6 py-2">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 mr-2">
                    <path fill-rule="evenodd" d="M8.75 1A2.75 2.75 0 006 3.75v.443c-.795.077-1.584.176-2.365.298a.75.75 0 10.23 1.482l.149-.022.841 10.518A2.75 2.75 0 007.596 19h4.807a2.75 2.75 0 002.742-2.53l.841-10.52.149.023a.75.75 0 00.23-1.482A41.03 41.03 0 0014 4.193V3.75A2.75 2.75 0 0011.25 1h-2.5zM10 4c.84 0 1.673.025 2.5.075V3.75c0-.69-.56-1.25-1.25-1.25h-2.5c-.69 0-1.25.56-1.25 1.25v.325C8.327 4.025 9.16 4 10 4zM8.58 7.72a.75.75 0 00-1.5.06l.3 7.5a.75.75 0 101.5-.06l-.3-7.5zm4.34.06a.75.75 0 10-1.5-.06l-.3 7.5a.75.75 0 101.5.06l.3-7.5z" clip-rule="evenodd" />
                </svg>
                Delete Block
            </div>
            <div on:click={() => _block._editing = false} class="w-1/2 flex pl-6 py-2">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 mr-2">
                    <path fill-rule="evenodd" d="M4.5 2A1.5 1.5 0 003 3.5v13A1.5 1.5 0 004.5 18h11a1.5 1.5 0 001.5-1.5V7.621a1.5 1.5 0 00-.44-1.06l-4.12-4.122A1.5 1.5 0 0011.378 2H4.5zM10 8a.75.75 0 01.75.75v1.5h1.5a.75.75 0 010 1.5h-1.5v1.5a.75.75 0 01-1.5 0v-1.5h-1.5a.75.75 0 010-1.5h1.5v-1.5A.75.75 0 0110 8z" clip-rule="evenodd" />
                </svg>
                Save Block
            </div>
        {:else}
            <div on:click={() => _block._editing = true} class="border-r w-1/2 flex pl-6 py-2">
                Edit Block
            </div>
            <div on:click={_block.testable = !_block.testable} class="border-r w-1/2 pl-6 py-2">Testable? {_block.testable}</div>
        {/if}
    </div>
    <!-- End Block Controls -->
</div>
