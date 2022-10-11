<template>
    <div>
        <div class="flex justify-between">
            <h1 class="text-sm text-gray-400">subject content</h1>
        </div>
        <hr class="border-gray-400">

        <template v-if="!pending">
            <template v-for="section in sections">
                <div>
                    <SubjectSection 
                        :section="section"
                        @delete="refresh" />
                </div>
            </template>
            <button @click="createSection" class="border py-2 px-4 rounded-lg mt-4">Create a new Section</button>
        </template>
        <ScaleLoader v-else height="20px" width="4px" class="mt-20" />
    </div>
</template>

<script setup>
import ScaleLoader from 'vue-spinner/src/ScaleLoader.vue';
import { ref, reactive } from 'vue';

const props = defineProps(['subjectId']);
const subjectId = props.subjectId;
const student = "nikokozak@gmail.com";
const { data: sections, pending, refresh } = await useFetchAPI(`/api/subjects/${subjectId}/sections`);

function createSection() {
    useSimpleFetch(`/api/section`, {
        method: 'POST',
        body: { subject_id: subjectId }
    }).then(response => {
        sections.value.push(response);
        //refresh();
        console.log(`created new section ${response.id}`);
    });
}
</script>
