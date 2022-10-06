<script>
    import { createEventDispatcher } from 'svelte';

    const dispatch = createEventDispatcher();

    export const type = 'text';
    export let data = 'Some text content';

    function handleInput() {
        dispatch('input', { 
            type, 
            data 
        })
    }
    
</script>

<div class="mx-4 text-sm mb-4"
    contenteditable="true"
    bind:innerHTML={data}
    on:input={() => handleInput}>
</div>
