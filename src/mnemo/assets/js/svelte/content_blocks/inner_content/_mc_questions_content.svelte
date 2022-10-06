<script>
    export let _inner_content;
    $: choices = $_inner_content.answer.choices;
    $: correct = $_inner_content.answer.correct;
</script>

<!-- Inner Block Content -->
<h1 class="text-md ml-4 mt-4">Question</h1>

<div class="w-4/5 h-20 bg-gray-100 rounded-lg border border-dashed mt-4 ml-4"></div>
<div contenteditable=true class="ml-4 mt-4 w-4/5 text-sm" bind:innerHTML={$_inner_content.question.text}></div>

<hr class="mt-4">

<h1 class="text-md ml-4 mt-4">Answers</h1>
<!-- End Inner Block Content -->

<div class="ml-4">
{#each Object.entries(choices) as [key, choice]}
    <div class="flex justify-between border rounded-lg px-4 text-xs mt-4 mr-4">
        <p class="pr-2 py-2 border-r">{key}</p>
        <p class="pl-2 py-2">{choice}</p>
        <div class="pl-2 border-l justify-self-end w-5">
            {#if correct == key}
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 mt-2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
            {:else}
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 mt-2"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z" clip-rule="evenodd" /></svg>
            {/if}
        </div>
    </div>
{/each}

<button on:click={() => _blockStore.addInnerTextContent(_section_idx, _block_idx)} class="flex text-xs border rounded-lg py-2 px-4 mt-4">
    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 mr-2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25H12" />
    </svg>
    <p>Add another answer</p>
</button>

</div>
