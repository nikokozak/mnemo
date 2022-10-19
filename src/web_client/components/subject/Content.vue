<template>
    <div>
        <div class="flex justify-between">
            <h1 class="text-sm text-gray-400">subject content</h1>
        </div>
        <hr class="border-gray-400">

        <template v-for="section in sections">
            <div>
                <SubjectSection 
                    :section="section"
                    @delete="removeSectionFromLocalState" />
            </div>
        </template>
        <button @click="createSection" class="border py-2 px-4 rounded-lg mt-4">Create a new Section</button>

    </div>
</template>

<script setup>
import { ref, reactive } from 'vue';

const props = defineProps(['subject']);
const subjectId = props.subject.id;
const sections = ref(props.subject.sections)
const student = "nikokozak@gmail.com";

function createSection() {
    useSimpleFetch(`/api/section`, {
        method: 'POST',
        body: { subject_id: subjectId }
    }).then(response => {
        sections.value.push(response);
        console.log(`created new section ${response.id}`);
    });
}

function removeSectionFromLocalState(sectionId) {
    const sectionIdx = sections.value.findIndex(section => section.id == sectionId);
    sections.value.splice(sectionIdx, 1);
}
</script>
