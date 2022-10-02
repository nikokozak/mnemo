<script>
    let email = null;

    let userList = [];

    async function submitEmail() { 
        console.log("submitting " + email);
        
        const response = await doPost({email: email})

        userList = [...userList, response.userList];
    }

    async function doPost(data = {}) {
        const res = await fetch('http://localhost:4000/api/content_manager/add_user', {
            method: 'POST',
            body: JSON.stringify(data),
            headers: {
                'Content-Type': 'application/json',
            }
        })

        return await res.json()
    }
</script> 

<input type="text" bind:value={email} placeholder="Your email here" />
<button class="bg-sky-500 p-2 rounded-lg text-white" on:click={submitEmail}>Submit Email</button>

<ul>
{#each userList as user}
    <li>{user}</li> 
{/each}
</ul>
