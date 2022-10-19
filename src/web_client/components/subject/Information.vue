<template>
    <div class="mb-8">
        <div class="flex justify-between">
            <h1 class="text-sm text-gray-400">subject information</h1>
            <ScaleLoader v-show="updating" height="20px" width="4px" class="mt-20" />
        </div>
        <hr class="border-gray-400">

        <input 
            type="text" 
            v-model="subject.title"
            @input="handleInput"
            class="text-xl border-none pl-0 text-black text-semibold underline underline-offset-8 mt-8 w-full" />

        <textarea 
            style="resize:none" 
            v-model="subject.description"
            @input="handleInput"
            placeholder="An optional description of what your subject is about." 
            class="border-none pl-0 mt-4 text-black text-sm underline underline-offset-4 w-full" />

        <div class="block h-20 w-5/6 border mt-4 rounded-lg border-dashed border-gray-700 p-6">
            <p class="text-xs text-slate-500">
                An optional thumbnail (click here to add or change)
            </p>
        </div>
    </div>
</template>

<script setup>
import ScaleLoader from 'vue-spinner/src/ScaleLoader.vue';
import { debounce } from 'lodash';
import { ref, reactive } from 'vue';

const props = defineProps(['subject']);
const subjectId = props.subject.id;
const student = "nikokozak@gmail.com";

const updating = ref(false);

const handleInput = debounce(function() {
    updating.value = true; 
    useSimpleFetch(`/api/subjects`, {
        method: 'PUT',
        body: { subject: subject.value }
    }).then(response => {
        console.log(`successfully updated ${subjectId}`);
        updating.value = false;
    })
}, 500);
</script>
