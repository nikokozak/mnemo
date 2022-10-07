<script>
    import debounce from 'lodash/debounce';
    import { Circle } from 'svelte-loading-spinners';
    import { doPost } from '../utils.js';

    export let subject

    let saving = false;

    const handleInput = debounce(e => {
        saving = true;
        doPost('/api/subject/save', subject);
        saving = false;
    }, 500);

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
