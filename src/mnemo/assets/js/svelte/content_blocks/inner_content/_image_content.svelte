<script>
    import { createEventDispatcher } from 'svelte';

    const dispatch = createEventDispatcher();

    export const type = 'image';
    export let data = 'https://unsplash.com/photos/Fo5dTm6ID1Y/download?ixid=MnwxMjA3fDB8MXxzZWFyY2h8Mnx8aGlzdG9yeXxlbnwwfHx8fDE2NjUwMTEwMDA&force=true&w=500';
     

    function handleInput() {
        dispatch('input', { 
            type, 
            data 
        })
    }
    
</script>

<img class="w-3/4 mx-4 mb-4 rounded-lg" src={data} />
