<script>
    import { onMount } from 'svelte';
    import { Circle } from 'svelte-loading-spinners';
    import debounce from 'lodash/debounce';

    /** DATA **/

    export let subject = {};
    let sections = [];
    $: sections_empty = sections.length == 0;
    let blocks = [{}];
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

        const block = {
            subject_id: subject.id,
            testable: false,
            type,
            inner_content: [],
            _editing: true,
        }

        if (sections_empty && section_idx === null) {
            createSection();
            let section = sections[0];
            section.blocks = [...section.blocks, block];
            sections = sections;
        } else {
            let section = sections[section_idx];
            section.blocks = [...section.blocks, block];
            sections = sections;
        }
    }

    function saveBlock(sidx, bidx) {
        let section = sections[sidx];
        let block = section.blocks[bidx];
        block._editing = false;
        section.blocks = section.blocks;
        sections = sections;
        editing_block = false;
    }

    function deleteBlock(sidx, bidx) {
        let section = sections[sidx];
        section.blocks.splice(bidx, 1);
        section.blocks = section.blocks;
        sections = sections;
        editing_block = false;
    }

    function editBlock(sidx, bidx) {
        let section = sections[sidx];
        let block = section.blocks[bidx];
        block._editing = true;
        section.blocks = section.blocks;
        sections = sections;
        editing_block = true;
    }

    function toggleTestableBlock(sidx, bidx) {
        let section = sections[sidx];
        let block = section.blocks[bidx];
        block.testable = !block.testable;
        section.blocks = section.blocks;
        sections = sections;
    }

    function addInnerTextContent(sidx, bidx) {
        const textBlock = {
            type: "text",
            data: "Some text goes here"
        }
        
        let section = sections[sidx];
        let block = section.blocks[bidx];
        block.inner_content = [...block.inner_content, textBlock];
        section.blocks = section.blocks;
        sections = sections;
    }

    function addInnerImageContent(sidx, bidx) {
        const imageBlock = {
            type: "image",
            data: "href_to_img"
        }

        let section = sections[sidx];
        let block = section.blocks[bidx];
        block.inner_content = [...block.inner_content, imageBlock];
        section.blocks = section.blocks;
        sections = sections;
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

    async function doGet() {
        const res = await fetch('api/content_manager/users', {
            method: 'GET',
        })

        return await res.json()
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

        {#each section.blocks as block, bidx}
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
                {#each block.inner_content as content}
                    <div>
                        Hello
                    </div>
                {/each}
                <!-- End Inner Block Content -->

                <!-- Inner Block Controls -->
                <div class="flex justify-around">
                    <button on:click={() => addInnerTextContent(idx, bidx)} class="flex text-xs border rounded-lg py-2 px-4">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 mr-2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25H12" />
                        </svg>
                        <p>Add Text</p>
                    </button>
                    <button on:click={() => addInnerImageContent(idx, bidx)} class="flex text-xs border rounded-lg py-2 px-4">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 mr-2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 15.75l5.159-5.159a2.25 2.25 0 013.182 0l5.159 5.159m-1.5-1.5l1.409-1.409a2.25 2.25 0 013.182 0l2.909 2.909m-18 3.75h16.5a1.5 1.5 0 001.5-1.5V6a1.5 1.5 0 00-1.5-1.5H3.75A1.5 1.5 0 002.25 6v12a1.5 1.5 0 001.5 1.5zm10.5-11.25h.008v.008h-.008V8.25zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z" />
                        </svg>
                        <p>Add Image</p>
                    </button>
                </div>
                <!-- End Inner Block Controls -->

                <!-- Block Controls -->
                <div class="flex justify-between text-xs border-t mt-4"> 
                    {#if block._editing}
                        <div on:click={() => deleteBlock(idx, bidx)} class="border-r w-1/2 flex pl-6 py-2">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 mr-2">
                                <path fill-rule="evenodd" d="M8.75 1A2.75 2.75 0 006 3.75v.443c-.795.077-1.584.176-2.365.298a.75.75 0 10.23 1.482l.149-.022.841 10.518A2.75 2.75 0 007.596 19h4.807a2.75 2.75 0 002.742-2.53l.841-10.52.149.023a.75.75 0 00.23-1.482A41.03 41.03 0 0014 4.193V3.75A2.75 2.75 0 0011.25 1h-2.5zM10 4c.84 0 1.673.025 2.5.075V3.75c0-.69-.56-1.25-1.25-1.25h-2.5c-.69 0-1.25.56-1.25 1.25v.325C8.327 4.025 9.16 4 10 4zM8.58 7.72a.75.75 0 00-1.5.06l.3 7.5a.75.75 0 101.5-.06l-.3-7.5zm4.34.06a.75.75 0 10-1.5-.06l-.3 7.5a.75.75 0 101.5.06l.3-7.5z" clip-rule="evenodd" />
                            </svg>
                            Delete Block
                        </div>
                        <div on:click={() => saveBlock(idx, bidx)} class="w-1/2 flex pl-6 py-2">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 mr-2">
                                <path fill-rule="evenodd" d="M4.5 2A1.5 1.5 0 003 3.5v13A1.5 1.5 0 004.5 18h11a1.5 1.5 0 001.5-1.5V7.621a1.5 1.5 0 00-.44-1.06l-4.12-4.122A1.5 1.5 0 0011.378 2H4.5zM10 8a.75.75 0 01.75.75v1.5h1.5a.75.75 0 010 1.5h-1.5v1.5a.75.75 0 01-1.5 0v-1.5h-1.5a.75.75 0 010-1.5h1.5v-1.5A.75.75 0 0110 8z" clip-rule="evenodd" />
                            </svg>
                            Save Block
                        </div>
                {:else}
                    <div on:click={() => editBlock(idx, bidx)} class="border-r w-1/2 flex pl-6 py-2">
                        Edit Block
                    </div>
                    <div on:click={() => toggleTestableBlock(idx, bidx)} class="border-r w-1/2 pl-6 py-2">Testable? {block.testable}</div>
                {/if}
                </div>
                <!-- End Block Controls -->
            </div>
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
