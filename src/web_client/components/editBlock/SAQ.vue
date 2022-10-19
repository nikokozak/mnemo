<template>
<div class="border rounded-lg mt-2 mb-4">
    <!-- Block Type Title -->
    <div class="flex m-4 text-md">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="mr-2 w-6 h-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 6.75h12M8.25 12h12m-12 5.25h12M3.75 6.75h.007v.008H3.75V6.75zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zM3.75 12h.007v.008H3.75V12zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm-.375 5.25h.007v.008H3.75v-.008zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z" />
        </svg>
        <h1>Single Answer Question</h1>
    </div>
    <hr>
    <!-- End Block Type Title -->

    <!-- Inner Question -->
    <div class="p-4">
        <h2>Question</h2>

        <div class="mt-4 w-full h-20 border border-gray-500 border-dashed rounded-lg"></div>

        <textarea v-model="block.mcq_question_text" class="w-full text-sm mt-4" placeholder="Your Question here."></textarea>
    </div>
    <!-- End Inner Question -->

    <hr>

    <!-- Inner Answers -->
    <div class="p-4">
        <h2>Possible Answers</h2>

        <template v-for="(choice, index) in block.saq_answer_choices">
            <div class="flex justify-between border rounded-lg text-xs mt-4 mr-4">
                <input v-model="choice.text" placeholder="An answer here" class="pl-2 py-2 w-full rounded-lg" />

                <div v-if="index > 0" class="pl-2 border-l justify-self-end w-8">
                        <svg @click="removeAnswerChoice(choice)" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="my-2 mr-0 w-4 h-4">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0" />
                        </svg>
                </div>
            </div>
        </template>
    </div>
    <!-- End Inner Question -->

    <!-- Inner Block Controls -->
    <div class="flex justify-around">
        <button @click="addAnswerChoice" class="flex text-xs border rounded-lg py-2 px-4">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 mr-2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25H12" />
            </svg>
            <p>Add another possible answer</p>
        </button>
    </div>
    <!-- End Inner Block Controls -->

    <!-- Block Controls -->
    <div class="flex justify-between text-xs border-t mt-4"> 
        <template v-if="editing"> 
            <div @click="deleteBlock" class="border-r w-1/2 flex pl-6 py-2">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 mr-2">
                    <path fill-rule="evenodd" d="M8.75 1A2.75 2.75 0 006 3.75v.443c-.795.077-1.584.176-2.365.298a.75.75 0 10.23 1.482l.149-.022.841 10.518A2.75 2.75 0 007.596 19h4.807a2.75 2.75 0 002.742-2.53l.841-10.52.149.023a.75.75 0 00.23-1.482A41.03 41.03 0 0014 4.193V3.75A2.75 2.75 0 0011.25 1h-2.5zM10 4c.84 0 1.673.025 2.5.075V3.75c0-.69-.56-1.25-1.25-1.25h-2.5c-.69 0-1.25.56-1.25 1.25v.325C8.327 4.025 9.16 4 10 4zM8.58 7.72a.75.75 0 00-1.5.06l.3 7.5a.75.75 0 101.5-.06l-.3-7.5zm4.34.06a.75.75 0 10-1.5-.06l-.3 7.5a.75.75 0 101.5.06l.3-7.5z" clip-rule="evenodd" />
                </svg>
                Delete Block
            </div>
            <div @click="saveBlock" class="w-1/2 flex pl-6 py-2">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4 mr-2">
                    <path fill-rule="evenodd" d="M4.5 2A1.5 1.5 0 003 3.5v13A1.5 1.5 0 004.5 18h11a1.5 1.5 0 001.5-1.5V7.621a1.5 1.5 0 00-.44-1.06l-4.12-4.122A1.5 1.5 0 0011.378 2H4.5zM10 8a.75.75 0 01.75.75v1.5h1.5a.75.75 0 010 1.5h-1.5v1.5a.75.75 0 01-1.5 0v-1.5h-1.5a.75.75 0 010-1.5h1.5v-1.5A.75.75 0 0110 8z" clip-rule="evenodd" />
                </svg>
                Save Block
            </div>
        </template>
        <template v-else>
            <div @click="editBlock" class="border-r w-1/2 flex pl-6 py-2">
                Edit Block
            </div>
            <div @click="toggleTestable" class="border-r w-1/2 pl-6 py-2">Testable? {{ block.testable }}</div>
        </template>
    </div>
    <!-- End Block Controls -->
</div>
</template>

<script setup>
import { ref } from 'vue';

const emit = defineEmits(['delete', 'save']);
const config = useRuntimeConfig();

const props = defineProps(['block']);
const block = ref(props.block);

const editing = ref(true);
// Avoids a warning being thrown??
// const key = "";

function addAnswerChoice() {
    block.value.saq_answer_choices.push({
        text: ""
    })
}

function removeAnswerChoice(choice) {
    const idx = block.value.saq_answer_choices.indexOf(choice, 1);
    block.value.saq_answer_choices.splice(idx, 1);
}

function deleteBlock() {
    useSimpleFetch(`/api/content_block/${block.value.id}`, {
        method: 'DELETE'
    }).then(response => {
        emit('delete');
    })
}

function saveBlock() {
    useSimpleFetch(`/api/content_block/${block.value.id}`, {
        method: 'PUT',
        body: { content_block: block.value }
    }).then(response => {
        console.log(`correctly saved content block ${block.value.id}`);
        emit('save');
    })
    editing.value = false;
}

function editBlock() {
    editing.value = true;
}

function toggleTestable() {
    block.value.testable = !block.value.testable;
}
</script>
