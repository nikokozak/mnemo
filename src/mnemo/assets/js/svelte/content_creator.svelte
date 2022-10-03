<script>
    import { onMount } from 'svelte';

    let email = null;

    let userList = [];

    async function submitEmail() { 
        console.log("submitting " + email);
        
        const response = await doPost({email: email})

        userList = response.userList;
    }

    async function doGet() {
        const res = await fetch('api/content_manager/users', {
            method: 'GET',
        })

        return await res.json()
    }

    async function doPost(data = {}) {
        const res = await fetch('api/content_manager/add_user', {
            method: 'POST',
            body: JSON.stringify(data),
            headers: {
                'Content-Type': 'application/json',
            }
        })

        return await res.json()
    }

    onMount(async () => {
        const response = await doGet();
        userList = response.userList;
    })
</script> 

<input type="text" bind:value={email} placeholder="Your email here" />
<button class="bg-sky-500 p-2 rounded-lg text-white" on:click={submitEmail}>Submit Email</button>

<ul>
{#each userList as user}
    <li>{user.email}</li> 
{/each}
</ul>
