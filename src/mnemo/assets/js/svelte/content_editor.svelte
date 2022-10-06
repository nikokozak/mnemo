<script>
    import { onMount } from 'svelte';
    import { Circle } from 'svelte-loading-spinners';
    import debounce from 'lodash/debounce';
    import StaticContentBlock from './content_blocks/_static_block.svelte';

    async function loadComponent() {
        return await import(`./content_blocks/_static_block.svelte`);
    }

    /** DATA **/

    export let subject = {};
    let sections = [];
    $: sections_empty = sections.length == 0;
    let delete_route = "/content/delete/" + subject.id;
    let saving = false;
    let editing_block = false;

    /** HANDLERS **/

    const handleInput = debounce(e => {
        saveContent();
    }, 500);

    /** FUNCTIONS **/

    function createBlock(section_idx = null, type = "static") {
        editing_block = true;

        console.log(section_idx)
        if (sections_empty && section_idx === null) {
            createSection();
            addBlockToSection(0, type);
        } else {
            addBlockToSection(section_idx, type);
        }
    }

    function addBlockToSection(section_idx, block_type) {
        const section = sections[section_idx];
        section.blocks = [...section.blocks, {id: section.blocks.length}];
        sections = sections;
    }

    function saveBlock(sidx, bidx) {
        editing_block = false;
    }

    function deleteBlock(sidx, bidx) {
        const section = sections[sidx];
        section.blocks.splice(bidx, 1);
        section.blocks = section.blocks;
        sections = sections;
        editing_block = false;
    }

    function editBlock(sidx, bidx) {
        editing_block = true;
    }

    function createSection() {
        const section = {
            id: null,
            subject_id: subject.id,
            title: null,
            blocks: []
        }

        sections = [...sections, section];
    }

    function deleteSection(section_index) {
        sections.splice(section_index, 1);
        sections = sections;
    }

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

{#each sections as section, idx}
    <div class="mt-4">
        <!-- Section Title -->
        <div class="flex justify-between">
            <input type="text" bind:value={section.title} class="text-md text-semibold underline underline-offset-6 border-0 p-0 mb-4" placeholder="Optional Section Title" />
            <svg on:click={() => deleteSection(idx)} xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width={1.5} stroke="currentColor" class="gray-400 w-4 h-4 mt-1">
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
        {#each section.blocks as block, bidx (block.id)}
            <StaticContentBlock 
                on:save={() => saveBlock(idx, bidx)}
                on:delete={() => deleteBlock(idx, bidx)}
            />
        {/each}
 
        {#if !editing_block}
        <button on:click={() => createBlock(idx)} class="block py-2 px-4 border rounded-lg mt-4 text-xs">
            Create a new Content Block
        </button>
        {/if}
    </div>
{/each}

{#if sections_empty}
<button on:click={() => createBlock()} class="block py-2 px-4 border rounded-lg mt-4 text-xs">
    Create a new Content Block
</button>
{/if}

<p class="text-xs text-gray-400 mt-2">or...</p>

<button on:click={createSection} class="block py-2 px-4 border rounded-lg mt-4 text-xs">
    Create a new Section
</button>

<h1 class="text-sm text-gray-400 mt-12">subject options</h1>
<hr class="border-gray-400">

<a href={delete_route} class="block py-2 px-4 border border-red-400 rounded-lg mt-4 w-40 text-xs">
    Delete Subject
</a>
