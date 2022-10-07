<script>
    // SECTIONS
    // Parent to individual SECTIONs
    import Section from './section/_section.svelte';
    import { section } from '../schemas.js';

    export let sections = [];

    function addSection() {
        sections.push(section());
        sections = sections;
    }

    function removeSection(idx) {
        sections.splice(idx, 1);
        sections = sections;
    }
</script>

<h1 class="text-sm text-gray-400 mt-12">subject content</h1>
<hr class="border-gray-400">
<p class="text-xs text-gray-400 mt-2">Create content blocks - you can choose whether 
they are “testable” (this means you can review these
blocks), or if they’re just information you want to
provide your students (or yourself).<br><br>

You can also arrange them according to chapters or
sections, or simply create all of the blocks without a 
structure.</p>

{#each sections as section, idx (section._sidx)}
    <Section bind:section={section}
        _section_idx={idx}
        on:remove={() => removeSection(idx)}/>
{/each}

{#if sections.length == 0}
    <button on:click={() => addSection()} class="block py-2 px-4 border rounded-lg mt-4 text-xs">
        Create a new Content Block
    </button>
{/if}

{#if sections.length != 0}
    <p class="text-xs text-gray-400 mt-2">or...</p>

    <button on:click={() => addSection()} class="block py-2 px-4 border rounded-lg mt-4 text-xs">
        Create a new Section
    </button>
{/if}
