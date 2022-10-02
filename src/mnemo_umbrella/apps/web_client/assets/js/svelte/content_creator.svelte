<script>
    let email = null;

    let userList = [];

    function submitEmail() { 
        console.log("submitting " + email);
        userList = [...userList, email];
    }
</script> 

<input type="text" bind:value={email} placeholder="Your email here" />
<button class="bg-sky-500 p-2 rounded-lg text-white" on:click={submitEmail}>Submit Email</button>

<ul>
{#each userList as user}
    <li>{user}</li> 
{/each}
</ul>
