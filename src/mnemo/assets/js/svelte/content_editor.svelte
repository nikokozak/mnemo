<script>
    import { onMount } from 'svelte';

    export let subject = {};
    let delete_route = "/content/delete/" + subject.id;

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
</script> 

<h1 class="text-sm text-gray-400">subject information</h1>
<hr class="border-gray-400">

<input 
    type="text" 
    bind:value={subject.title} 
    class="text-xl border-none pl-0 text-black text-semibold underline underline-offset-8 mt-8"/>

<textarea 
    style="resize:none" 
    bind:value={subject.description} 
    placeholder="An optional description of what your subject is about." 
    class="border-none pl-0 mt-4 text-black text-sm underline underline-offset-4"/>

<div class="block h-20 w-5/6 border mt-8 rounded-lg border-dashed border-gray-700 p-6">
    <p class="text-xs text-slate-500">
        An optional thumbnail (click here to add or change)
    </p>
</div>

<h1 class="text-sm text-gray-400 mt-12">subject options</h1>
<hr class="border-gray-400">

<a href={delete_route} class="block py-2 px-4 border border-red-400 rounded-lg mt-4 w-40">
    Delete Subject
</a>

<h1 class="text-sm text-gray-400 mt-12">subject content</h1>
<hr class="border-gray-400">
