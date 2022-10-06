<script>
    import { sectionStore } from './stores/section_store.js';
    import { onMount } from 'svelte';
    import { Circle } from 'svelte-loading-spinners';
    import debounce from 'lodash/debounce';
    import StaticContentBlock from './content_blocks/_static_block.svelte';
    import Section from './content_blocks/_section.svelte';

    async function loadComponent() {
        return await import(`./content_blocks/_static_block.svelte`);
    }

    /** DATA **/

    export let subject = {};
    $: sections_empty = $sectionStore.length == 0;
    let delete_route = "/content/delete/" + subject.id;
    let saving = false;
    let editing_block = false;

    /** HANDLERS **/

    const handleInput = debounce(e => {
        saveContent();
    }, 500);

    /** FUNCTIONS **/

    async function saveContent() {
        saving = true;
        const res = await doPost(subject, "/api/content/save");
        saving = false;
        console.log(res)
    }

    async function doPost(data = {}, route) {
        const res = await fetch(route, {
            method: 'POST',
            body: JSON.stringify(data),
            headers: {
                'Content-Type': 'application/json',
            }
        })

        return await res.body
    }
</script> 

<div class="flex justify-between">
    <h1 class="text-sm text-gray-400">subject information</h1>
    {#if saving}
        <Circle size="15" unit="px"></Circle>
    {/if}
</div>
<hr class="border-gray-400">

<input 
    type="text" 
    bind:value={subject.title} 
    on:input={handleInput}
    class="text-xl border-none pl-0 text-black text-semibold underline underline-offset-8 mt-8"/>

<textarea 
    style="resize:none" 
    bind:value={subject.description} 
    on:input={handleInput}
    placeholder="An optional description of what your subject is about." 
    class="border-none pl-0 mt-4 text-black text-sm underline underline-offset-4"/>

<div class="block h-20 w-5/6 border mt-8 rounded-lg border-dashed border-gray-700 p-6">
    <p class="text-xs text-slate-500">
        An optional thumbnail (click here to add or change)
    </p>
</div>

<h1 class="text-sm text-gray-400 mt-12">subject content</h1>
<hr class="border-gray-400">
<p class="text-xs text-gray-400 mt-2">Create content blocks - you can choose whether 
they are “testable” (this means you can review these
blocks), or if they’re just information you want to
provide your students (or yourself).<br><br>

You can also arrange them according to chapters or
sections, or simply create all of the blocks without a 
structure.</p>

{#each $sectionStore as section, idx (section._sidx)}
    <Section _section_idx={idx} />
{/each}

{#if sections_empty}
    <button on:click={sectionStore.addSection} class="block py-2 px-4 border rounded-lg mt-4 text-xs">
    Create a new Content Block
</button>
{/if}

<p class="text-xs text-gray-400 mt-2">or...</p>

<button on:click={sectionStore.addSection} class="block py-2 px-4 border rounded-lg mt-4 text-xs">
    Create a new Section
</button>

<h1 class="text-sm text-gray-400 mt-12">subject options</h1>
<hr class="border-gray-400">

<a href={delete_route} class="block py-2 px-4 border border-red-400 rounded-lg mt-4 w-40 text-xs">
    Delete Subject
</a>
